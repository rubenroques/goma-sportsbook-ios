import Combine
import UIKit
import GomaUI
import ServicesProvider

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
        print("[TallOddsMatchCardViewModel] Creating VM for match: \(match.homeParticipant.name)-\(match.awayParticipant.name)")

        // Debug: Log all Sport properties to diagnose sport ID issue
        print("[SPORT_DEBUG] 🎾 Creating ViewModel for: \(match.homeParticipant.name) - \(match.awayParticipant.name)")
        print("[SPORT_DEBUG]    Sport Name: \(match.sport.name)")
        print("[SPORT_DEBUG]    Sport.id: '\(match.sport.id)'")
        print("[SPORT_DEBUG]    Sport.alphaId: '\(match.sport.alphaId ?? "nil")'")
        print("[SPORT_DEBUG]    Sport.numericId: '\(match.sport.numericId ?? "nil")'")

        // Store match identifiers
        self.matchId = match.id
        self.sportId = match.sport.id
        self.homeParticipantName = match.homeParticipant.name
        self.awayParticipantName = match.awayParticipant.name
        self.competitionName = match.competitionName
        self.marketTypeId = marketTypeId
        self.matchDate = match.date
        self.matchCardContext = matchCardContext

        print("[SPORT_DEBUG]    Stored sportId: '\(self.sportId)'")

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
        let scoreViewModel = Self.createScoreViewModel(
            from: match.detailedScores,
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
        print("[TallOddsMatchCardViewModel] 🔴 DEINIT - matchId: \(matchId)")
        liveDataCancellable?.cancel()
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
        print("[LIVE_SCORE TallOddsMatchCardViewModel] 🟢 Starting live data subscription for match: \(matchId)")
        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchId)
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] completion in
                print("[TallOddsMatchCardViewModel] 🔴 Live data subscription completed: \(completion) for match: \(self?.matchId ?? "unknown")")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }

                switch subscribableContent {
                case .connected(let subscription):
                    print("[TallOddsMatchCardViewModel] 🟢 Live data connected: \(subscription.id) for match: \(self.matchId)")

                case .contentUpdate(let eventLiveData):
                    print("[TallOddsMatchCardViewModel] contentUpdated live data")

                    self.currentEventLiveData = eventLiveData
                    self.updateScoreViewModel(from: eventLiveData)
                    self.updateMatchHeaderViewModel(from: eventLiveData)

                case .disconnected:
                    print("[TallOddsMatchCardViewModel] 🔴 Live data disconnected for match: \(self.matchId)")
                }
            })
    }

    private func updateScoreViewModel(from eventLiveData: EventLiveData) {
        print("[LIVE_SCORE] 🎨 TallOddsMatchCardViewModel.updateScoreViewModel called")
        print("[LIVE_SCORE]    Event ID: \(eventLiveData.id)")
        print("[LIVE_SCORE]    Score: \(eventLiveData.homeScore?.description ?? "nil") - \(eventLiveData.awayScore?.description ?? "nil")")
        print("[LIVE_SCORE]    DetailedScores: \(eventLiveData.detailedScores?.count ?? 0) entries")

        // Map ServicesProvider types to app types
        let mappedScores = eventLiveData.detailedScores.map { ServiceProviderModelMapper.scoresDictionary(fromInternalScoresDictionary: $0) }

        let newScoreViewModel = Self.createScoreViewModel(
            from: mappedScores,
            activePlayerServing: eventLiveData.activePlayerServing,
            homeScore: eventLiveData.homeScore,
            awayScore: eventLiveData.awayScore,
            sportId: sportId
        )

        print("[LIVE_SCORE]    Created ScoreViewModel")
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

// MARK: - Score Transformation Logic
extension TallOddsMatchCardViewModel {

    /// Creates a ScoreViewModel from detailed scores with proper tennis layout support
    private static func createScoreViewModel(
        from detailedScores: [String: Score]?,
        activePlayerServing: ServicesProvider.ActivePlayerServe?,
        homeScore: Int?,
        awayScore: Int?,
        sportId: String
    ) -> ScoreViewModelProtocol? {

        // Determine if this is a Type C sport (Tennis, Volleyball, etc.)
        let isTypeCsport = ["3", "20", "64", "63", "14"].contains(sportId)

        // Debug: Log Type C detection details
        print("[SPORT_DEBUG] 🔄 Score Transformation")
        print("[SPORT_DEBUG]    sportId used: '\(sportId)'")
        print("[SPORT_DEBUG]    isTypeCsport: \(isTypeCsport)")
        print("[SPORT_DEBUG]    Expected Type C IDs: [3=Tennis, 20=Volleyball, 14=Badminton, 63=TableTennis, 64=BeachVolley]")

        var scoreCells: [ScoreDisplayData] = []

        // Process detailed scores if available
        if let detailedScores = detailedScores, !detailedScores.isEmpty {
            print("[LIVE_SCORE] 🔄 Transforming \(detailedScores.count) detailed scores for sport ID: \(sportId) (Type C: \(isTypeCsport))")

            // Sort scores by sortValue to ensure correct ordering
            let sortedScores = detailedScores.sorted(by: { $0.value.sortValue < $1.value.sortValue })

            // Find the last set index to determine current set
            let lastSetIndex = sortedScores.compactMap { entry -> Int? in
                if case .set(let index, _, _) = entry.value {
                    return index
                }
                return nil
            }.max()

            // Map serving player for first cell only
            let servingPlayer = mapServingPlayer(from: activePlayerServing)
            var isFirstCell = true

            for (scoreName, score) in sortedScores {
                let scoreCell: ScoreDisplayData

                switch score {
                case .gamePart(let home, let away):
                    // Current game points - always highlighted, separator for Type C, serving indicator
                    print("[LIVE_SCORE]    - GamePart '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-")")
                    scoreCell = ScoreDisplayData(
                        id: "game-\(scoreName)",
                        homeScore: home != nil ? "\(home!)" : "-",
                        awayScore: away != nil ? "\(away!)" : "-",
                        style: .background,
                        highlightingMode: .bothHighlight,
                        showsTrailingSeparator: isTypeCsport,
                        servingPlayer: isFirstCell ? servingPlayer : nil
                    )
                    scoreCells.append(scoreCell)
                    isFirstCell = false

                case .set(let index, let home, let away):
                    // Set scores - determine if current or completed
                    let isCurrentSet = (index == lastSetIndex)
                    let highlighting: ScoreDisplayData.HighlightingMode = isCurrentSet ? .bothHighlight : .winnerLoser

                    print("[LIVE_SCORE]    - Set \(index) '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-") (current: \(isCurrentSet))")
                    scoreCell = ScoreDisplayData(
                        id: "set-\(scoreName)",
                        homeScore: home != nil ? "\(home!)" : "-",
                        awayScore: away != nil ? "\(away!)" : "-",
                        index: index,
                        style: .simple,
                        highlightingMode: highlighting,
                        showsTrailingSeparator: false,
                        servingPlayer: isFirstCell ? servingPlayer : nil
                    )
                    scoreCells.append(scoreCell)
                    isFirstCell = false

                case .matchFull(let home, let away):
                    // Total score - skip for Type C sports (Tennis layout doesn't show totals)
                    if isTypeCsport {
                        print("[LIVE_SCORE]    - MatchFull '\(scoreName)' SKIPPED for Type C sport")
                        continue
                    }

                    print("[LIVE_SCORE]    - MatchFull '\(scoreName)': \(home?.description ?? "-") - \(away?.description ?? "-")")
                    scoreCell = ScoreDisplayData(
                        id: "match-\(scoreName)",
                        homeScore: home != nil ? "\(home!)" : "-",
                        awayScore: away != nil ? "\(away!)" : "-",
                        style: .simple,
                        highlightingMode: .bothHighlight,
                        showsTrailingSeparator: false,
                        servingPlayer: isFirstCell ? servingPlayer : nil
                    )
                    scoreCells.append(scoreCell)
                    isFirstCell = false
                }
            }
        }

        // Fallback to main score if no detailed scores
        if scoreCells.isEmpty {
            if let homeScore = homeScore, let awayScore = awayScore {
                print("[LIVE_SCORE]    Adding main score (no detailed scores): \(homeScore) - \(awayScore)")
                let mainScoreCell = ScoreDisplayData(
                    id: "match",
                    homeScore: "\(homeScore)",
                    awayScore: "\(awayScore)",
                    style: .simple,
                    highlightingMode: .bothHighlight
                )
                scoreCells.append(mainScoreCell)
            }
        }

        guard !scoreCells.isEmpty else {
            print("[LIVE_SCORE]    ⚠️ No score cells created - returning nil")
            return nil
        }

        print("[LIVE_SCORE]    ✅ Created ScoreViewModel with \(scoreCells.count) score cells")
        return ScoreViewModel(scoreCells: scoreCells, visualState: .display)
    }

    /// Maps ServicesProvider ActivePlayerServe to ScoreDisplayData ServingPlayer
    private static func mapServingPlayer(from serving: ServicesProvider.ActivePlayerServe?) -> ScoreDisplayData.ServingPlayer? {
        switch serving {
        case .home:
            return .home
        case .away:
            return .away
        case .none:
            return nil
        }
    }

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
}

// MARK: - Helper Methods
extension TallOddsMatchCardViewModel {

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
