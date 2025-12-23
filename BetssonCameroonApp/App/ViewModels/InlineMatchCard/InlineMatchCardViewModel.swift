import Combine
import UIKit
import GomaUI
import ServicesProvider
import GomaLogger

/// Production implementation of InlineMatchCardViewModelProtocol
/// Manages a compact inline match card with header, outcomes, and score display
final class InlineMatchCardViewModel: InlineMatchCardViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<InlineMatchCardDisplayState, Never>
    private let headerViewModelSubject: CurrentValueSubject<CompactMatchHeaderViewModelProtocol, Never>
    private let outcomesViewModelSubject: CurrentValueSubject<CompactOutcomesLineViewModelProtocol, Never>
    private let scoreViewModelSubject: CurrentValueSubject<InlineScoreViewModelProtocol?, Never>

    // MARK: - Match Data
    private let matchId: String
    private let sportId: String
    private let homeParticipantName: String
    private let awayParticipantName: String
    private let competitionName: String
    private let marketTypeId: String
    private let matchDate: Date?

    // MARK: - Child ViewModels (concrete types for internal access)
    private let headerViewModel: CompactMatchHeaderViewModel
    private let outcomesViewModel: CompactOutcomesLineViewModel
    private var scoreViewModel: InlineScoreViewModel?

    // MARK: - Live Data
    private var liveDataCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Protocol Properties (Publishers)

    public var displayStatePublisher: AnyPublisher<InlineMatchCardDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var headerViewModelPublisher: AnyPublisher<CompactMatchHeaderViewModelProtocol, Never> {
        headerViewModelSubject.eraseToAnyPublisher()
    }

    public var outcomesViewModelPublisher: AnyPublisher<CompactOutcomesLineViewModelProtocol, Never> {
        outcomesViewModelSubject.eraseToAnyPublisher()
    }

    public var scoreViewModelPublisher: AnyPublisher<InlineScoreViewModelProtocol?, Never> {
        scoreViewModelSubject.eraseToAnyPublisher()
    }

    // MARK: - Protocol Properties (Synchronous)

    public var currentDisplayState: InlineMatchCardDisplayState {
        displayStateSubject.value
    }

    public var currentHeaderViewModel: CompactMatchHeaderViewModelProtocol {
        headerViewModelSubject.value
    }

    public var currentOutcomesViewModel: CompactOutcomesLineViewModelProtocol {
        outcomesViewModelSubject.value
    }

    public var currentScoreViewModel: InlineScoreViewModelProtocol? {
        scoreViewModelSubject.value
    }

    // MARK: - Initialization

    init(match: Match, market: Market, marketTypeId: String) {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "Creating VM for match: \(match.homeParticipant.name)-\(match.awayParticipant.name)")

        // Store match identifiers
        self.matchId = match.id
        self.sportId = match.sport.id
        self.homeParticipantName = match.homeParticipant.name
        self.awayParticipantName = match.awayParticipant.name
        self.competitionName = match.competitionName
        self.marketTypeId = marketTypeId
        self.matchDate = match.date

        // Create initial display state
        let initialDisplayState = InlineMatchCardDisplayState(
            matchId: match.id,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            isLive: match.status.isLive
        )

        // Create child view models
        self.headerViewModel = CompactMatchHeaderViewModel.create(from: match)
        self.outcomesViewModel = CompactOutcomesLineViewModel.create(from: market)

        // Create score view model only for live matches
        if match.status.isLive {
            self.scoreViewModel = InlineScoreViewModel(from: match)
        } else {
            self.scoreViewModel = nil
        }

        // Initialize subjects
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.headerViewModelSubject = CurrentValueSubject(headerViewModel)
        self.outcomesViewModelSubject = CurrentValueSubject(outcomesViewModel)
        self.scoreViewModelSubject = CurrentValueSubject(scoreViewModel)

        // Setup bindings
        setupOutcomeSelectionBindings()

        // Start live data subscription
        subscribeToLiveData()
    }

    // MARK: - Cleanup
    deinit {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "DEINIT - matchId: \(matchId)")
        liveDataCancellable = nil
        cancellables.removeAll()
    }

    // MARK: - Protocol Methods

    func onCardTapped() {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "Card tapped for match: \(matchId)")
    }

    func onOutcomeSelected(outcomeId: String) {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "Outcome selected: \(outcomeId)")

        // Find the outcome data from the current display state
        let currentState = outcomesViewModel.currentDisplayState
        let outcome = findOutcome(withId: outcomeId, in: currentState)

        guard let outcome = outcome else {
            GomaLogger.error(.ui, category: "INLINE_CARD", "Could not find outcome with id: \(outcomeId)")
            return
        }

        let bettingTicket = BettingTicket(
            id: outcome.bettingOfferId ?? outcomeId,
            outcomeId: outcomeId,
            marketId: "", // We don't have market ID directly, but bettingOfferId is primary
            matchId: matchId,
            marketTypeId: marketTypeId,
            decimalOdd: Double(outcome.value) ?? 0.0,
            isAvailable: true,
            matchDescription: "\(homeParticipantName) - \(awayParticipantName)",
            marketDescription: "", // Compact card doesn't show market name
            outcomeDescription: outcome.title,
            homeParticipantName: homeParticipantName,
            awayParticipantName: awayParticipantName,
            sportIdCode: nil,
            competition: competitionName,
            date: matchDate
        )

        Env.betslipManager.addBettingTicket(bettingTicket)
    }

    func onOutcomeDeselected(outcomeId: String) {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "Outcome deselected: \(outcomeId)")

        let currentState = outcomesViewModel.currentDisplayState
        let outcome = findOutcome(withId: outcomeId, in: currentState)

        guard let outcome = outcome else { return }

        let bettingTicket = BettingTicket(
            id: outcome.bettingOfferId ?? outcomeId,
            outcomeId: outcomeId,
            marketId: "",
            matchId: matchId,
            decimalOdd: Double(outcome.value) ?? 0.0,
            isAvailable: true,
            matchDescription: "\(homeParticipantName) - \(awayParticipantName)",
            marketDescription: "",
            outcomeDescription: outcome.title,
            homeParticipantName: homeParticipantName,
            awayParticipantName: awayParticipantName,
            sportIdCode: nil,
            competition: competitionName,
            date: matchDate
        )

        Env.betslipManager.removeBettingTicket(bettingTicket)
    }

    func onMoreMarketsTapped() {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "More markets tapped for match: \(matchId)")
    }

    // MARK: - Private Methods

    private func findOutcome(withId id: String, in state: CompactOutcomesLineDisplayState) -> OutcomeItemData? {
        if state.leftOutcome?.id == id {
            return state.leftOutcome
        }
        if state.middleOutcome?.id == id {
            return state.middleOutcome
        }
        if state.rightOutcome?.id == id {
            return state.rightOutcome
        }
        return nil
    }

    private func setupOutcomeSelectionBindings() {
        // Observe outcome selection changes and forward to betslip
        outcomesViewModel.outcomeSelectionDidChangePublisher
            .sink { [weak self] event in
                if event.isSelected {
                    self?.onOutcomeSelected(outcomeId: event.outcomeId)
                } else {
                    self?.onOutcomeDeselected(outcomeId: event.outcomeId)
                }
            }
            .store(in: &cancellables)

        // Observe betslip changes to update selection states
        Env.betslipManager.bettingTicketsPublisher
            .map { tickets in
                Set(tickets.compactMap { $0.id })
            }
            .removeDuplicates()
            .sink { [weak self] selectedOfferIds in
                self?.outcomesViewModel.updateSelectionStates(selectedOfferIds: selectedOfferIds)
            }
            .store(in: &cancellables)
    }

    // MARK: - Live Data Subscription

    private func subscribeToLiveData() {
        GomaLogger.debug(.ui, category: "INLINE_CARD", "Starting live data subscription for match: \(matchId)")

        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchId)
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] completion in
                GomaLogger.debug(.ui, category: "INLINE_CARD", "Live data subscription completed: \(completion) for match: \(self?.matchId ?? "unknown")")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }

                switch subscribableContent {
                case .connected(let subscription):
                    GomaLogger.debug(.ui, category: "INLINE_CARD", "Live data connected: \(subscription.id) for match: \(self.matchId)")

                case .contentUpdate(let eventLiveData):
                    GomaLogger.debug(.ui, category: "INLINE_CARD", "Live data update received for match: \(self.matchId)")
                    self.updateFromLiveData(eventLiveData)

                case .disconnected:
                    GomaLogger.debug(.ui, category: "INLINE_CARD", "Live data disconnected for match: \(self.matchId)")
                }
            })
    }

    private func updateFromLiveData(_ eventLiveData: EventLiveData) {
        // Update score view model
        updateScoreViewModel(from: eventLiveData)

        // Update header view model
        updateHeaderViewModel(from: eventLiveData)

        // Update display state if live status changed
        updateDisplayState(from: eventLiveData)
    }

    private func updateScoreViewModel(from eventLiveData: EventLiveData) {
        if scoreViewModel == nil {
            // Create score VM if we now have live data
            scoreViewModel = InlineScoreViewModel(columns: [], isVisible: true)
            scoreViewModelSubject.send(scoreViewModel)
        }

        scoreViewModel?.update(from: eventLiveData, sportId: sportId)
    }

    private func updateHeaderViewModel(from eventLiveData: EventLiveData) {
        headerViewModel.update(from: eventLiveData)
    }

    private func updateDisplayState(from eventLiveData: EventLiveData) {
        let isLive: Bool
        if let status = eventLiveData.status {
            isLive = status.isInProgress
        } else {
            isLive = displayStateSubject.value.isLive
        }

        if isLive != displayStateSubject.value.isLive {
            let newState = InlineMatchCardDisplayState(
                matchId: matchId,
                homeParticipantName: homeParticipantName,
                awayParticipantName: awayParticipantName,
                isLive: isLive
            )
            displayStateSubject.send(newState)
        }
    }
}

// MARK: - Factory Methods
extension InlineMatchCardViewModel {

    /// Creates an InlineMatchCardViewModel from Match and first relevant Market
    static func create(from match: Match, markets: [Market], marketTypeId: String) -> InlineMatchCardViewModel? {
        guard let firstMarket = markets.first else {
            GomaLogger.debug(.ui, category: "INLINE_CARD", "No markets available for match: \(match.id)")
            return nil
        }

        return InlineMatchCardViewModel(match: match, market: firstMarket, marketTypeId: marketTypeId)
    }
}
