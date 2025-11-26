import Combine
import UIKit
import GomaUI
import ServicesProvider
import GomaLogger

final class TallOddsMatchCardViewModel: TallOddsMatchCardViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TallOddsMatchCardDisplayState, Never>
    fileprivate let matchHeaderViewModelSubject: CurrentValueSubject<MatchHeaderViewModelProtocol, Never>
    fileprivate let marketInfoLineViewModelSubject: CurrentValueSubject<MarketInfoLineViewModelProtocol, Never>
    fileprivate let marketOutcomesViewModelSubject: CurrentValueSubject<MarketOutcomesMultiLineViewModelProtocol, Never>
    fileprivate let scoreViewModelSubject: CurrentValueSubject<ScoreViewModelProtocol?, Never>

    // MARK: - Current Values (Synchronous Access for TableView)
    public var currentDisplayState: TallOddsMatchCardDisplayState {
        return displayStateSubject.value
    }

    public var currentMatchHeaderViewModel: MatchHeaderViewModelProtocol {
        return matchHeaderViewModelSubject.value
    }

    public var currentMarketInfoLineViewModel: MarketInfoLineViewModelProtocol {
        return marketInfoLineViewModelSubject.value
    }

    public var currentMarketOutcomesViewModel: MarketOutcomesMultiLineViewModelProtocol {
        return marketOutcomesViewModelSubject.value
    }

    public var currentScoreViewModel: ScoreViewModelProtocol? {
        return scoreViewModelSubject.value
    }

    // MARK: - Publishers (Asynchronous Updates)
    public var displayStatePublisher: AnyPublisher<TallOddsMatchCardDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    public var matchHeaderViewModelPublisher: AnyPublisher<MatchHeaderViewModelProtocol, Never> {
        return matchHeaderViewModelSubject.eraseToAnyPublisher()
    }

    public var marketInfoLineViewModelPublisher: AnyPublisher<MarketInfoLineViewModelProtocol, Never> {
        return marketInfoLineViewModelSubject.eraseToAnyPublisher()
    }

    public var marketOutcomesViewModelPublisher: AnyPublisher<MarketOutcomesMultiLineViewModelProtocol, Never> {
        return marketOutcomesViewModelSubject.eraseToAnyPublisher()
    }

    public var scoreViewModelPublisher: AnyPublisher<ScoreViewModelProtocol?, Never> {
        return scoreViewModelSubject.eraseToAnyPublisher()
    }

    // MARK: - Match Data
    private let matchId: String
    private let sportId: String
    private let homeParticipantName: String
    private let awayParticipantName: String
    private let competitionName: String
    private let marketTypeId: String
    private let matchDate: Date?

    // MARK: - Live Data Properties
    private var liveDataCancellable: AnyCancellable?
    private var currentEventLiveData: EventLiveData?
    private var cancellables = Set<AnyCancellable>()

    var matchCardContext: MatchCardContext

    // MARK: - Initialization
    init(
        match: Match,
        relevantMarkets: [Market],
        marketTypeId: String,
        matchCardContext: MatchCardContext = .lists
    ) {
        GomaLogger.debug(.ui, category: "TALL_CARD", "Creating VM for match: \(match.homeParticipant.name)-\(match.awayParticipant.name)")

        // Debug: Log all Sport properties to diagnose sport ID issue
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "Creating ViewModel for: \(match.homeParticipant.name) - \(match.awayParticipant.name)")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   Sport Name: \(match.sport.name)")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   Sport.id: '\(match.sport.id)'")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   Sport.alphaId: '\(match.sport.alphaId ?? "nil")'")
        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   Sport.numericId: '\(match.sport.numericId ?? "nil")'")

        // Store match identifiers
        self.matchId = match.id
        self.sportId = match.sport.id
        self.homeParticipantName = match.homeParticipant.name
        self.awayParticipantName = match.awayParticipant.name
        self.competitionName = match.competitionName
        self.marketTypeId = marketTypeId
        self.matchDate = match.date
        self.matchCardContext = matchCardContext

        GomaLogger.debug(.realtime, category: "SPORT_DEBUG", "   Stored sportId: '\(self.sportId)'")

        // Create initial display state from match
        let initialDisplayState = TallOddsMatchCardDisplayState(
            matchId: match.id,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            isLive: match.status.isLive
        )

        // Create MatchHeaderData
        let matchHeaderData = MatchHeaderData(
            id: match.id,
            competitionName: match.competitionName,
            countryFlagImageName: Self.extractCountryFlag(from: match),
            sportIconImageName: Self.extractSportIcon(from: match),
            isFavorite: false,
            matchTime: Self.formatMatchTime(from: match),
            isLive: match.status.isLive
        )

        // Create MarketInfoData
        let firstMarket = relevantMarkets.first
        let marketInfoData = MarketInfoData(
            marketName: firstMarket?.marketTypeName ?? firstMarket?.name ?? "Markets",
            marketCount: match.numberTotalOfMarkets,
            icons: Self.createMarketIcons(from: relevantMarkets, match: match),
            marketId: firstMarket?.id ?? "",
            marketTypeId: firstMarket?.marketTypeId
        )

        // Create child view models
        let headerViewModel = MatchHeaderViewModel(data: matchHeaderData)
        let marketInfoViewModel = MarketInfoLineViewModel(marketInfoData: marketInfoData)
        let outcomesViewModel = MarketOutcomesMultiLineViewModel.createWithDirectLineViewModels(
            from: relevantMarkets,
            marketTypeId: marketTypeId,
            with: matchCardContext
        )

        // Create initial score view model from match data
        let scoreViewModel = ScoreViewModel(
            detailedScores: match.detailedScores,
            activePlayerServing: Self.mapActivePlayerServe(from: match.activePlayerServe),
            homeScore: match.homeParticipantScore,
            awayScore: match.awayParticipantScore,
            sportId: match.sport.id
        )

        // Initialize subjects
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.matchHeaderViewModelSubject = CurrentValueSubject(headerViewModel)
        self.marketInfoLineViewModelSubject = CurrentValueSubject(marketInfoViewModel)
        self.marketOutcomesViewModelSubject = CurrentValueSubject(outcomesViewModel)
        self.scoreViewModelSubject = CurrentValueSubject(scoreViewModel)

        // Start live data subscription for live matches
        self.subscribeToLiveData()
    }

    // MARK: - Cleanup
    deinit {
        GomaLogger.debug(.ui, category: "TALL_CARD", "DEINIT - matchId: \(matchId)")
        // liveDataCancellable?.cancel()
        liveDataCancellable = nil
    }

    // MARK: - TallOddsMatchCardViewModelProtocol
    func onMatchHeaderAction() {
        print("Production: Match header tapped for match: \(matchId)")
    }

    func onFavoriteToggle() {
        print("Production: Favorite toggled for match: \(matchId)")
    }

    func onOutcomeSelected(outcomeId: String) {
        print("Production: Outcome selected: \(outcomeId) for match: \(matchId)")

        let outcome = marketOutcomesViewModelSubject.value.lineViewModels.compactMap { lineViewModel in
            if lineViewModel.marketStateSubject.value.leftOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.leftOutcome
            } else if lineViewModel.marketStateSubject.value.middleOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.middleOutcome
            } else if lineViewModel.marketStateSubject.value.rightOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.rightOutcome
            }
            return nil
        }.first

        let oddDouble = Double(outcome?.value ?? "")

        let bettingTicket = BettingTicket(
            id: outcome?.bettingOfferId ?? outcomeId,
            outcomeId: outcomeId,
            marketId: marketInfoLineViewModelSubject.value.marketInfoData.marketId,
            matchId: matchId,
            marketTypeId: marketTypeId,
            decimalOdd: oddDouble ?? 0.0,
            isAvailable: true,
            matchDescription: "\(homeParticipantName) - \(awayParticipantName)",
            marketDescription: marketInfoLineViewModelSubject.value.marketInfoData.marketName,
            outcomeDescription: outcome?.completeName ?? "",
            homeParticipantName: homeParticipantName,
            awayParticipantName: awayParticipantName,
            sportIdCode: nil,
            competition: competitionName,
            date: self.matchDate
        )

        Env.betslipManager.addBettingTicket(bettingTicket)
    }

    func onOutcomeDeselected(outcomeId: String) {
        print("Production: Outcome deselected: \(outcomeId) for match: \(matchId)")

        let outcome = marketOutcomesViewModelSubject.value.lineViewModels.compactMap { lineViewModel in
            if lineViewModel.marketStateSubject.value.leftOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.leftOutcome
            } else if lineViewModel.marketStateSubject.value.middleOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.middleOutcome
            } else if lineViewModel.marketStateSubject.value.rightOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.rightOutcome
            }
            return nil
        }.first

        let oddDouble = Double(outcome?.value ?? "")

        let bettingTicket = BettingTicket(
            id: outcome?.bettingOfferId ?? outcomeId,
            outcomeId: outcomeId,
            marketId: marketInfoLineViewModelSubject.value.marketInfoData.marketId,
            matchId: matchId,
            decimalOdd: oddDouble ?? 0.0,
            isAvailable: true,
            matchDescription: "\(homeParticipantName) - \(awayParticipantName)",
            marketDescription: marketInfoLineViewModelSubject.value.marketInfoData.marketName,
            outcomeDescription: outcome?.completeName ?? "",
            homeParticipantName: homeParticipantName,
            awayParticipantName: awayParticipantName,
            sportIdCode: nil,
            competition: competitionName,
            date: self.matchDate
        )

        Env.betslipManager.removeBettingTicket(bettingTicket)
    }

    func onMarketInfoTapped() {
        print("Production: Market info tapped for match: \(matchId)")
    }

    func onCardTapped() {
        print("Production: Card tapped for match: \(matchId)")
    }

    // MARK: - Live Data Subscription

    private func subscribeToLiveData() {
        GomaLogger.debug(.ui, category: "TALL_CARD", "Starting live data subscription for match: \(matchId)")
        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchId)
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] completion in
                GomaLogger.debug(.ui, category: "TALL_CARD", "Live data subscription completed: \(completion) for match: \(self?.matchId ?? "unknown")")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }

                switch subscribableContent {
                case .connected(let subscription):
                    GomaLogger.debug(.ui, category: "TALL_CARD", "Live data connected: \(subscription.id) for match: \(self.matchId)")

                case .contentUpdate(let eventLiveData):
                    GomaLogger.debug(.ui, category: "TALL_CARD", "contentUpdated live data")

                    self.currentEventLiveData = eventLiveData
                    self.updateScoreViewModel(from: eventLiveData)
                    self.updateMatchHeaderViewModel(from: eventLiveData)

                case .disconnected:
                    GomaLogger.debug(.ui, category: "TALL_CARD", "Live data disconnected for match: \(self.matchId)")
                }
            })
    }

    private func updateScoreViewModel(from eventLiveData: EventLiveData) {
        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "TallOddsMatchCardViewModel.updateScoreViewModel called")
        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   Event ID: \(eventLiveData.id)")
        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   Score: \(eventLiveData.homeScore?.description ?? "nil") - \(eventLiveData.awayScore?.description ?? "nil")")
        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   DetailedScores: \(eventLiveData.detailedScores?.count ?? 0) entries")

        // Map ServicesProvider types to app types
        let mappedScores = eventLiveData.detailedScores.map { ServiceProviderModelMapper.scoresDictionary(fromInternalScoresDictionary: $0) }

        let newScoreViewModel = ScoreViewModel(
            detailedScores: mappedScores,
            activePlayerServing: eventLiveData.activePlayerServing,
            homeScore: eventLiveData.homeScore,
            awayScore: eventLiveData.awayScore,
            sportId: sportId
        )

        GomaLogger.debug(.realtime, category: "LIVE_SCORE", "   Created ScoreViewModel")
        scoreViewModelSubject.send(newScoreViewModel)
    }

    private func updateMatchHeaderViewModel(from eventLiveData: EventLiveData) {
        // Update match time/status display
        if let matchTime = eventLiveData.matchTime {
            // Has match time (Football, Basketball, etc.)
            if let status = eventLiveData.status, case .inProgress(let details) = status {
                if let headerViewModel = matchHeaderViewModelSubject.value as? MatchHeaderViewModel {
                    // Combine status + time: "1st Half, 10 min"
                    headerViewModel.updateMatchTime(details + ", " + matchTime + " min")
                }
            }
            else if let headerViewModel = matchHeaderViewModelSubject.value as? MatchHeaderViewModel {
                // Just show time
                headerViewModel.updateMatchTime(matchTime)
            }
        } else if let status = eventLiveData.status, case .inProgress(let details) = status {
            // No match time but has status (Tennis, etc.)
            // Show current game/set info: "6th Game (1st Set)"
            if let headerViewModel = matchHeaderViewModelSubject.value as? MatchHeaderViewModel {
                headerViewModel.updateMatchTime(details)
            }
        }

        // Update live status based on event status
        if let status = eventLiveData.status {
            let isLive = status.isInProgress

            if let headerViewModel = matchHeaderViewModelSubject.value as? MatchHeaderViewModel {
                headerViewModel.updateIsLive(isLive)
            }
        }
    }
}

// MARK: - Helper Methods
extension TallOddsMatchCardViewModel {

    /// Maps Match.ActivePlayerServe to ServicesProvider.ActivePlayerServe
    private static func mapActivePlayerServe(from matchServe: Match.ActivePlayerServe?) -> ServicesProvider.ActivePlayerServe? {
        switch matchServe {
        case .home:
            return .home
        case .away:
            return .away
        case .none:
            return nil
        }
    }

    private static func extractCountryFlag(from match: Match) -> String? {
        return match.venue?.isoCode
    }

    private static func extractSportIcon(from match: Match) -> String? {
        return match.sport.alphaId ?? match.sportIdCode ?? "1"
    }

    private static func formatMatchTime(from match: Match) -> String? {
        if let matchTime = match.matchTime {
            return matchTime
        }
        if let date = match.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM, HH:mm"
            return formatter.string(from: date)
        }
        return nil
    }

    private static func createMarketIcons(from markets: [Market], match: Match) -> [MarketInfoIcon] {
        var icons: [MarketInfoIcon] = []
        icons.append(MarketInfoIcon(type: .expressPickShort, isVisible: false))
        icons.append(MarketInfoIcon(type: .mostPopular, isVisible: false))
        icons.append(MarketInfoIcon(type: .betBuilder, isVisible: false))
        icons.append(MarketInfoIcon(type: .statistics, isVisible: false))
        return icons
    }

}
