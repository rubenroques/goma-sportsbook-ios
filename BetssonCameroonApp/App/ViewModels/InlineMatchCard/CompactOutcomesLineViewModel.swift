import GomaUI
import ServicesProvider
import Combine
import UIKit
import GomaLogger

/// Production implementation of CompactOutcomesLineViewModelProtocol
/// Manages a single line of 2-3 outcomes for inline match cards
final class CompactOutcomesLineViewModel: CompactOutcomesLineViewModelProtocol {

    // MARK: - Dependencies
    private let marketId: String
    private let servicesProvider = Env.servicesProvider

    // MARK: - Subjects
    private let displayStateSubject: CurrentValueSubject<CompactOutcomesLineDisplayState, Never>
    private let leftOutcomeViewModelSubject: CurrentValueSubject<OutcomeItemViewModelProtocol?, Never>
    private let middleOutcomeViewModelSubject: CurrentValueSubject<OutcomeItemViewModelProtocol?, Never>
    private let rightOutcomeViewModelSubject: CurrentValueSubject<OutcomeItemViewModelProtocol?, Never>
    private let outcomeSelectionDidChangeSubject: PassthroughSubject<CompactOutcomeSelectionEvent, Never>

    private var cancellables = Set<AnyCancellable>()
    private var childCancellables = Set<AnyCancellable>()

    // MARK: - Child ViewModels
    private var outcomeViewModels: [OutcomeType: OutcomeItemViewModel] = [:]

    // MARK: - Protocol Properties

    public var displayStatePublisher: AnyPublisher<CompactOutcomesLineDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: CompactOutcomesLineDisplayState {
        displayStateSubject.value
    }

    public var leftOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> {
        leftOutcomeViewModelSubject.eraseToAnyPublisher()
    }

    public var middleOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> {
        middleOutcomeViewModelSubject.eraseToAnyPublisher()
    }

    public var rightOutcomeViewModelPublisher: AnyPublisher<OutcomeItemViewModelProtocol?, Never> {
        rightOutcomeViewModelSubject.eraseToAnyPublisher()
    }

    public var currentLeftOutcomeViewModel: OutcomeItemViewModelProtocol? {
        leftOutcomeViewModelSubject.value
    }

    public var currentMiddleOutcomeViewModel: OutcomeItemViewModelProtocol? {
        middleOutcomeViewModelSubject.value
    }

    public var currentRightOutcomeViewModel: OutcomeItemViewModelProtocol? {
        rightOutcomeViewModelSubject.value
    }

    public var outcomeSelectionDidChangePublisher: AnyPublisher<CompactOutcomeSelectionEvent, Never> {
        outcomeSelectionDidChangeSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(marketId: String, initialDisplayState: CompactOutcomesLineDisplayState) {
        self.marketId = marketId
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.leftOutcomeViewModelSubject = CurrentValueSubject(nil)
        self.middleOutcomeViewModelSubject = CurrentValueSubject(nil)
        self.rightOutcomeViewModelSubject = CurrentValueSubject(nil)
        self.outcomeSelectionDidChangeSubject = PassthroughSubject()

        // Create initial outcome view models
        createOutcomeViewModels(from: initialDisplayState)

        // Setup market subscription
        setupMarketSubscription()
    }

    // MARK: - Protocol Methods

    func onOutcomeSelected(outcomeId: String, outcomeType: OutcomeType) {
        GomaLogger.debug(.ui, category: "COMPACT_OUTCOMES", "Outcome selected: \(outcomeId)")
    }

    func onOutcomeDeselected(outcomeId: String, outcomeType: OutcomeType) {
        GomaLogger.debug(.ui, category: "COMPACT_OUTCOMES", "Outcome deselected: \(outcomeId)")
    }

    func setOutcomeSelected(outcomeType: OutcomeType) {
        outcomeViewModels[outcomeType]?.setSelected(true)
    }

    func setOutcomeDeselected(outcomeType: OutcomeType) {
        outcomeViewModels[outcomeType]?.setSelected(false)
    }

    /// Updates selection states based on betslip contents
    func updateSelectionStates(selectedOfferIds: Set<String>) {
        let currentState = displayStateSubject.value

        // Update left outcome selection
        if let leftOutcome = currentState.leftOutcome,
           let bettingOfferId = leftOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            if leftOutcome.isSelected != shouldBeSelected {
                outcomeViewModels[.left]?.setSelected(shouldBeSelected)
            }
        }

        // Update middle outcome selection
        if let middleOutcome = currentState.middleOutcome,
           let bettingOfferId = middleOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            if middleOutcome.isSelected != shouldBeSelected {
                outcomeViewModels[.middle]?.setSelected(shouldBeSelected)
            }
        }

        // Update right outcome selection
        if let rightOutcome = currentState.rightOutcome,
           let bettingOfferId = rightOutcome.bettingOfferId {
            let shouldBeSelected = selectedOfferIds.contains(bettingOfferId)
            if rightOutcome.isSelected != shouldBeSelected {
                outcomeViewModels[.right]?.setSelected(shouldBeSelected)
            }
        }
    }

    // MARK: - Private Methods

    private func setupMarketSubscription() {
        GomaLogger.debug(.realtime, category: "COMPACT_OUTCOMES", "Subscribing to market updates for MARKET:\(marketId)")

        servicesProvider.subscribeToEventOnListsMarketUpdates(withId: marketId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        GomaLogger.error(.realtime, category: "COMPACT_OUTCOMES", "Subscription failed for MARKET:\(self?.marketId ?? "unknown"): \(error)")
                        self?.handleMarketSuspension()
                    }
                },
                receiveValue: { [weak self] serviceProviderMarket in
                    GomaLogger.info(.realtime, category: "COMPACT_OUTCOMES", "Received market update for MARKET:\(self?.marketId ?? "unknown")")
                    self?.processMarketUpdate(serviceProviderMarket)
                }
            )
            .store(in: &cancellables)
    }

    private func processMarketUpdate(_ serviceProviderMarket: ServicesProvider.Market?) {
        guard let serviceProviderMarket = serviceProviderMarket else {
            handleMarketSuspension()
            return
        }

        let market = ServiceProviderModelMapper.market(fromServiceProviderMarket: serviceProviderMarket)

        if !market.isAvailable {
            handleMarketSuspension()
            return
        }

        updateOutcomesFromMarket(market)
    }

    private func updateOutcomesFromMarket(_ market: Market) {
        let outcomes = market.outcomes

        guard !outcomes.isEmpty else {
            handleMarketSuspension()
            return
        }

        // Determine display mode
        let displayMode: CompactOutcomesDisplayMode = outcomes.count >= 3 ? .triple : .double

        // Create outcome data
        let leftOutcome = !outcomes.isEmpty ? createOutcomeData(from: outcomes[0]) : nil
        let middleOutcome = outcomes.count >= 3 ? createOutcomeData(from: outcomes[1]) : nil
        let rightOutcome: OutcomeItemData?
        if outcomes.count >= 3 {
            rightOutcome = createOutcomeData(from: outcomes[2])
        } else if outcomes.count > 1 {
            rightOutcome = createOutcomeData(from: outcomes[1])
        } else {
            rightOutcome = nil
        }

        // Update display state
        let newDisplayState = CompactOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )

        // Update or create outcome view models
        updateOutcomeViewModels(newDisplayState: newDisplayState, fromMarket: market)

        displayStateSubject.send(newDisplayState)
    }

    private func createOutcomeData(from outcome: Outcome) -> OutcomeItemData {
        OutcomeItemData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable,
            previousValue: nil,
            changeTimestamp: nil
        )
    }

    private func updateOutcomeViewModels(newDisplayState: CompactOutcomesLineDisplayState, fromMarket market: Market) {
        // Clear old child subscriptions
        childCancellables.removeAll()

        // Create/update left outcome VM
        if let leftOutcome = newDisplayState.leftOutcome {
            if let existingVM = outcomeViewModels[.left] {
                // Re-subscribe to existing VM after clearing cancellables
                subscribeToOutcomeEvents(outcomeVM: existingVM, outcomeType: .left)
            } else if let matchingOutcome = market.outcomes.first(where: { $0.id == leftOutcome.id }) {
                let vm = OutcomeItemViewModel.create(from: matchingOutcome)
                outcomeViewModels[.left] = vm
                leftOutcomeViewModelSubject.send(vm)
                subscribeToOutcomeEvents(outcomeVM: vm, outcomeType: .left)
            }
        } else {
            outcomeViewModels.removeValue(forKey: .left)
            leftOutcomeViewModelSubject.send(nil)
        }

        // Create/update middle outcome VM
        if let middleOutcome = newDisplayState.middleOutcome {
            if let existingVM = outcomeViewModels[.middle] {
                // Re-subscribe to existing VM after clearing cancellables
                subscribeToOutcomeEvents(outcomeVM: existingVM, outcomeType: .middle)
            } else if let matchingOutcome = market.outcomes.first(where: { $0.id == middleOutcome.id }) {
                let vm = OutcomeItemViewModel.create(from: matchingOutcome)
                outcomeViewModels[.middle] = vm
                middleOutcomeViewModelSubject.send(vm)
                subscribeToOutcomeEvents(outcomeVM: vm, outcomeType: .middle)
            }
        } else {
            outcomeViewModels.removeValue(forKey: .middle)
            middleOutcomeViewModelSubject.send(nil)
        }

        // Create/update right outcome VM
        if let rightOutcome = newDisplayState.rightOutcome {
            if let existingVM = outcomeViewModels[.right] {
                // Re-subscribe to existing VM after clearing cancellables
                subscribeToOutcomeEvents(outcomeVM: existingVM, outcomeType: .right)
            } else if let matchingOutcome = market.outcomes.first(where: { $0.id == rightOutcome.id }) {
                let vm = OutcomeItemViewModel.create(from: matchingOutcome)
                outcomeViewModels[.right] = vm
                rightOutcomeViewModelSubject.send(vm)
                subscribeToOutcomeEvents(outcomeVM: vm, outcomeType: .right)
            }
        } else {
            outcomeViewModels.removeValue(forKey: .right)
            rightOutcomeViewModelSubject.send(nil)
        }
    }

    private func createOutcomeViewModels(from displayState: CompactOutcomesLineDisplayState) {
        if let leftOutcome = displayState.leftOutcome {
            let leftVM = OutcomeItemViewModel.create(
                outcomeId: leftOutcome.id,
                bettingOfferId: leftOutcome.bettingOfferId,
                title: leftOutcome.title,
                odds: Double(leftOutcome.value) ?? 1.0,
                isAvailable: !leftOutcome.isDisabled
            )
            outcomeViewModels[.left] = leftVM
            leftOutcomeViewModelSubject.send(leftVM)
            subscribeToOutcomeEvents(outcomeVM: leftVM, outcomeType: .left)
        }

        if let middleOutcome = displayState.middleOutcome {
            let middleVM = OutcomeItemViewModel.create(
                outcomeId: middleOutcome.id,
                bettingOfferId: middleOutcome.bettingOfferId,
                title: middleOutcome.title,
                odds: Double(middleOutcome.value) ?? 1.0,
                isAvailable: !middleOutcome.isDisabled
            )
            outcomeViewModels[.middle] = middleVM
            middleOutcomeViewModelSubject.send(middleVM)
            subscribeToOutcomeEvents(outcomeVM: middleVM, outcomeType: .middle)
        }

        if let rightOutcome = displayState.rightOutcome {
            let rightVM = OutcomeItemViewModel.create(
                outcomeId: rightOutcome.id,
                bettingOfferId: rightOutcome.bettingOfferId,
                title: rightOutcome.title,
                odds: Double(rightOutcome.value) ?? 1.0,
                isAvailable: !rightOutcome.isDisabled
            )
            outcomeViewModels[.right] = rightVM
            rightOutcomeViewModelSubject.send(rightVM)
            subscribeToOutcomeEvents(outcomeVM: rightVM, outcomeType: .right)
        }
    }

    private func subscribeToOutcomeEvents(outcomeVM: OutcomeItemViewModel, outcomeType: OutcomeType) {
        // Subscribe to selection change events (proper MVVM - parent observes child)
        outcomeVM.selectionDidChangePublisher
            .sink { [weak self] event in
                let parentEvent = CompactOutcomeSelectionEvent(
                    outcomeId: event.outcomeId,
                    bettingOfferId: event.bettingOfferId,
                    outcomeType: outcomeType,
                    isSelected: event.isSelected,
                    timestamp: event.timestamp
                )
                self?.outcomeSelectionDidChangeSubject.send(parentEvent)
            }
            .store(in: &childCancellables)
    }

    private func handleMarketSuspension() {
        // Create locked state for all outcomes
        let lockedOutcome = OutcomeItemData(
            id: "locked",
            bettingOfferId: nil,
            title: "-",
            value: "-",
            oddsChangeDirection: .none,
            displayState: .locked,
            previousValue: nil,
            changeTimestamp: nil
        )

        let currentMode = displayStateSubject.value.displayMode
        let suspendedState = CompactOutcomesLineDisplayState(
            displayMode: currentMode,
            leftOutcome: lockedOutcome,
            middleOutcome: currentMode == .triple ? lockedOutcome : nil,
            rightOutcome: lockedOutcome
        )

        outcomeViewModels.removeAll()
        leftOutcomeViewModelSubject.send(nil)
        middleOutcomeViewModelSubject.send(nil)
        rightOutcomeViewModelSubject.send(nil)

        displayStateSubject.send(suspendedState)
    }

    // MARK: - Cleanup
    deinit {
        cancellables.removeAll()
        childCancellables.removeAll()
        outcomeViewModels.removeAll()
    }
}

// MARK: - Factory Methods
extension CompactOutcomesLineViewModel {

    /// Creates a CompactOutcomesLineViewModel from a Market
    static func create(from market: Market) -> CompactOutcomesLineViewModel {
        let displayState = createDisplayState(from: market)
        return CompactOutcomesLineViewModel(marketId: market.id, initialDisplayState: displayState)
    }

    private static func createDisplayState(from market: Market) -> CompactOutcomesLineDisplayState {
        guard market.isAvailable && !market.outcomes.isEmpty else {
            return CompactOutcomesLineDisplayState(
                displayMode: .double,
                leftOutcome: nil,
                rightOutcome: nil
            )
        }

        let outcomes = market.outcomes
        let displayMode: CompactOutcomesDisplayMode = outcomes.count >= 3 ? .triple : .double

        let leftOutcome = !outcomes.isEmpty ? createOutcomeData(from: outcomes[0]) : nil
        let middleOutcome = outcomes.count >= 3 ? createOutcomeData(from: outcomes[1]) : nil
        let rightOutcome: OutcomeItemData?
        if outcomes.count >= 3 {
            rightOutcome = createOutcomeData(from: outcomes[2])
        } else if outcomes.count > 1 {
            rightOutcome = createOutcomeData(from: outcomes[1])
        } else {
            rightOutcome = nil
        }

        return CompactOutcomesLineDisplayState(
            displayMode: displayMode,
            leftOutcome: leftOutcome,
            middleOutcome: middleOutcome,
            rightOutcome: rightOutcome
        )
    }

    private static func createOutcomeData(from outcome: Outcome) -> OutcomeItemData {
        OutcomeItemData(
            id: outcome.id,
            bettingOfferId: outcome.bettingOffer.id,
            title: outcome.translatedName,
            value: OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd),
            oddsChangeDirection: .none,
            isSelected: false,
            isDisabled: !outcome.bettingOffer.isAvailable,
            previousValue: nil,
            changeTimestamp: nil
        )
    }
}
