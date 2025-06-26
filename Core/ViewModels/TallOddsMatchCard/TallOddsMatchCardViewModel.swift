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
    
    private let matchData: TallOddsMatchData
    
    // MARK: - Live Data Properties
    private var liveDataCancellable: AnyCancellable?
    private var currentEventLiveData: EventLiveData?
    
    // MARK: - Initialization
    init(matchData: TallOddsMatchData) {
        print("[TallOddsMatchCardViewModel] Creating VM for match: \(matchData.homeParticipantName)-\(matchData.awayParticipantName)")
        self.matchData = matchData
        
        // Create initial display state from match data
        let initialDisplayState = TallOddsMatchCardDisplayState(
            matchId: matchData.matchId,
            homeParticipantName: matchData.homeParticipantName,
            awayParticipantName: matchData.awayParticipantName,
            isLive: matchData.leagueInfo.isLive
        )
        
        // Create child view models from match data
        let headerViewModel = Self.createMatchHeaderViewModel(from: matchData.leagueInfo)
        let marketInfoViewModel = Self.createMarketInfoLineViewModel(from: matchData.marketInfo)
        let outcomesViewModel = Self.createMarketOutcomesViewModel(from: matchData.outcomes)
        let scoreViewModel = Self.createScoreViewModel(from: matchData.liveScoreData)
        
        // Initialize subjects
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.matchHeaderViewModelSubject = CurrentValueSubject(headerViewModel)
        self.marketInfoLineViewModelSubject = CurrentValueSubject(marketInfoViewModel)
        self.marketOutcomesViewModelSubject = CurrentValueSubject(outcomesViewModel)
        self.scoreViewModelSubject = CurrentValueSubject(scoreViewModel)
        
        // Start live data subscription for live matches
        subscribeToLiveData()
    }
    
    // MARK: - Cleanup
    deinit {
        print("[TallOddsMatchCardViewModel] 🔴 DEINIT - matchId: \(matchData.matchId)")
        liveDataCancellable?.cancel()
        liveDataCancellable = nil
    }
    
    // MARK: - TallOddsMatchCardViewModelProtocol
    func onMatchHeaderAction() {
        print("Production: Match header tapped for match: \(matchData.matchId)")
        // TODO: Implement actual navigation or action handling
    }
    
    func onFavoriteToggle() {
        print("Production: Favorite toggled for match: \(matchData.matchId)")
        // TODO: Implement favorite management via services
    }
    
    func onOutcomeSelected(outcomeId: String) {
        print("Production: Outcome selected: \(outcomeId) for match: \(matchData.matchId)")
        // TODO: Implement betslip management
    }
    
    func onMarketInfoTapped() {
        print("Production: Market info tapped for match: \(matchData.matchId)")
        // TODO: Implement market details navigation
    }
    
    // MARK: - Live Data Subscription
    
    private func subscribeToLiveData() {
        guard matchData.leagueInfo.isLive else {
            print("[TallOddsMatchCardViewModel] 🟡 Skipping live data subscription - match is not live: \(matchData.matchId)")
            return
        }
        
        print("[TallOddsMatchCardViewModel] 🟢 Starting live data subscription for match: \(matchData.matchId)")
        
        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchData.matchId)
            .sink(receiveCompletion: { [weak self] completion in
                print("[TallOddsMatchCardViewModel] 🔴 Live data subscription completed: \(completion) for match: \(self?.matchData.matchId ?? "unknown")")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }
                
                switch subscribableContent {
                case .contentUpdate(let eventLiveData):
                    print("[TallOddsMatchCardViewModel] 📡 Received live data update for match: \(self.matchData.matchId)")
                    print("  - Home Score: \(eventLiveData.homeScore ?? -1)")
                    print("  - Away Score: \(eventLiveData.awayScore ?? -1)")
                    print("  - Status: \(self.eventStatusToString(eventLiveData.status))")
                    print("  - Match Time: \(eventLiveData.matchTime ?? "nil")")
                    print("  - Detailed Scores Count: \(eventLiveData.detailedScores?.count ?? 0)")
                    print("  - Active Player Serving: \(eventLiveData.activePlayerServing?.rawValue ?? "nil")")
                    
                    self.currentEventLiveData = eventLiveData
                    self.updateScoreViewModel(from: eventLiveData)
                    
                case .connected(let subscription):
                    print("[TallOddsMatchCardViewModel] 🟢 Live data connected: \(subscription.id) for match: \(self.matchData.matchId)")
                    
                case .disconnected:
                    print("[TallOddsMatchCardViewModel] 🔴 Live data disconnected for match: \(self.matchData.matchId)")
                }
            })
    }
    
    private func updateScoreViewModel(from eventLiveData: EventLiveData) {
        let liveScoreData = transformEventLiveDataToLiveScoreData(eventLiveData)
        let newScoreViewModel = Self.createScoreViewModel(from: liveScoreData)
        
        print("[TallOddsMatchCardViewModel] 🔄 Updating score ViewModel for match: \(matchData.matchId)")
        print("  - New score cells count: \(liveScoreData?.scoreCells.count ?? 0)")
        
        scoreViewModelSubject.send(newScoreViewModel)
    }
    
    private func transformEventLiveDataToLiveScoreData(_ eventLiveData: EventLiveData) -> LiveScoreData? {
        var scoreCells: [ScoreDisplayData] = []
        
        
        
        // Add detailed scores (sets, games, etc.)
        if let detailedScores = eventLiveData.detailedScores {
            for (scoreName, score) in detailedScores.sorted(by: { $0.value.sortValue < $1.value.sortValue }) {
                let scoreCell: ScoreDisplayData
                
                switch score {
                case .set(let index, let home, let away):
                    scoreCell = ScoreDisplayData(
                        id: "set-\(scoreName)",
                        homeScore: home != nil ? "\(home!)" : "-",
                        awayScore: away != nil ? "\(away!)" : "-",
                        index: index,
                        style: .simple
                    )
                case .gamePart(let home, let away):
                    scoreCell = ScoreDisplayData(
                        id: "game-\(scoreName)",
                        homeScore: home != nil ? "\(home!)" : "-",
                        awayScore: away != nil ? "\(away!)" : "-",
                        style: .background
                    )
                case .matchFull(let home, let away):
                    scoreCell = ScoreDisplayData(
                        id: "match-\(scoreName)",
                        homeScore: home != nil ? "\(home!)" : "-",
                        awayScore: away != nil ? "\(away!)" : "-",
                        style: .simple
                    )
                }
                
                scoreCells.append(scoreCell)
            }
        }

        if scoreCells.isEmpty {
            // Add main score if available
            if let homeScore = eventLiveData.homeScore, let awayScore = eventLiveData.awayScore {
                let mainScoreCell = ScoreDisplayData(
                    id: "match",
                    homeScore: "\(homeScore)",
                    awayScore: "\(awayScore)",
                    style: .simple
                )
                scoreCells.append(mainScoreCell)
            }
        }
        
        guard !scoreCells.isEmpty else { return nil }
        
        return LiveScoreData(
            sportCode: extractSportCode(from: matchData),
            scoreCells: scoreCells
        )
    }
    
    private func extractSportCode(from matchData: TallOddsMatchData) -> String {
        // Extract sport code from match data or default to tennis for EVENT_INFO rich data
        return "tennis" // Could be enhanced to use actual sport detection
    }
    
    private func eventStatusToString(_ status: EventStatus?) -> String {
        guard let status = status else { return "nil" }
        switch status {
        case .unknown:
            return "unknown"
        case .notStarted:
            return "not started"
        case .inProgress(let detail):
            return "in progress (\(detail))"
        case .ended(let detail):
            return "ended (\(detail))"
        }
    }
}

// MARK: - Factory Methods for Child ViewModels
extension TallOddsMatchCardViewModel {
    
    private static func createMatchHeaderViewModel(from headerData: MatchHeaderData) -> MatchHeaderViewModelProtocol {
        return MatchHeaderViewModel(data: headerData)
    }
    
    private static func createMarketInfoLineViewModel(from marketInfoData: MarketInfoData) -> MarketInfoLineViewModelProtocol {
        return MarketInfoLineViewModel(marketInfoData: marketInfoData)
    }
    
    private static func createMarketOutcomesViewModel(from marketGroupData: MarketGroupData) -> MarketOutcomesMultiLineViewModelProtocol {
        return MarketOutcomesMultiLineViewModel(marketGroupData: marketGroupData)
    }
    
    private static func createScoreViewModel(from liveScoreData: LiveScoreData?) -> ScoreViewModelProtocol? {
        guard let liveScoreData = liveScoreData else { return nil }
        
        // Import MockScoreViewModel since this is in Core and we need to create a score view model
        // In production, this would be a proper ScoreViewModel implementation
        return MockScoreViewModel(scoreCells: liveScoreData.scoreCells, visualState: .display)
    }
    
    private static func createMarketOutcomesViewModel(from markets: [Market], marketTypeId: String) -> MarketOutcomesMultiLineViewModelProtocol {
        return MarketOutcomesMultiLineViewModel.createWithDirectLineViewModels(
            from: markets,
            marketTypeId: marketTypeId
        )
    }
}

// MARK: - Factory for Creating from Real Match Data
extension TallOddsMatchCardViewModel {
    
    /// Creates a TallOddsMatchCardViewModel from real Match and Market data
    static func create(from match: Match, relevantMarkets: [Market], marketTypeId: String) -> TallOddsMatchCardViewModel {
        print("[TallOdds] Creating TallOddsMatchCardViewModel from Match data - ID: \(match.id), Markets: \(relevantMarkets.count), MarketType: \(marketTypeId)")
        
        // Create with direct production view models that have real-time subscriptions
        return createWithProductionViewModels(from: match, relevantMarkets: relevantMarkets, marketTypeId: marketTypeId)
    }
    
    /// Creates a TallOddsMatchCardViewModel with production view models that have real-time subscriptions
    private static func createWithProductionViewModels(from match: Match, relevantMarkets: [Market], marketTypeId: String) -> TallOddsMatchCardViewModel {
        // 1. Create MatchHeaderData
        let matchHeaderData = MatchHeaderData(
            id: match.id,
            competitionName: match.competitionName,
            countryFlagImageName: extractCountryFlag(from: match),
            sportIconImageName: extractSportIcon(from: match),
            isFavorite: false, // TODO: Check with favorites service when available
            visualState: .standard,
            matchTime: formatMatchTime(from: match),
            isLive: match.status.isLive
        )
        
        // 2. Create MarketInfoData
        let firstMarket = relevantMarkets.first
        let marketInfoData = MarketInfoData(
            marketName: firstMarket?.marketTypeName ?? firstMarket?.name ?? "Markets",
            marketCount: match.numberTotalOfMarkets,
            icons: createMarketIcons(from: relevantMarkets, match: match)
        )
        
        // Create child view models
        let headerViewModel = createMatchHeaderViewModel(from: matchHeaderData)
        let marketInfoViewModel = createMarketInfoLineViewModel(from: marketInfoData)
        let outcomesViewModel = createMarketOutcomesViewModel(from: relevantMarkets, marketTypeId: marketTypeId)
        
        // Create initial display state
        let initialDisplayState = TallOddsMatchCardDisplayState(
            matchId: match.id,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            isLive: match.status.isLive
        )
        
        // Create the view model directly with production child view models
        let viewModel = TallOddsMatchCardViewModel(matchData: TallOddsMatchData(
            matchId: match.id,
            leagueInfo: matchHeaderData,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: marketTypeId, marketLines: [])  // Empty, not used in production
        ))
        
        // Override the subjects with production view models
        viewModel.matchHeaderViewModelSubject.send(headerViewModel)
        viewModel.marketInfoLineViewModelSubject.send(marketInfoViewModel)
        viewModel.marketOutcomesViewModelSubject.send(outcomesViewModel)
        
        // Create score view model for live matches
        // TODO: In production, use actual live score data from match.liveScore or similar
        let scoreViewModel: ScoreViewModelProtocol? = match.status.isLive ? 
            MockScoreViewModel(scoreCells: [], visualState: .idle) : nil
        viewModel.scoreViewModelSubject.send(scoreViewModel)
        
        return viewModel
    }
    
    private static func extractMatchData(from match: Match, relevantMarkets: [Market], marketTypeId: String) -> TallOddsMatchData {
        
        // 1. Create MatchHeaderData from match
        let matchHeaderData = MatchHeaderData(
            id: match.id,
            competitionName: match.competitionName,
            countryFlagImageName: extractCountryFlag(from: match),
            sportIconImageName: extractSportIcon(from: match),
            isFavorite: false, // TODO: Check with favorites service when available
            visualState: .standard,
            matchTime: formatMatchTime(from: match),
            isLive: match.status.isLive
        )
        
        // 2. Create MarketInfoData from relevant markets
        let firstMarket = relevantMarkets.first
        let marketInfoData = MarketInfoData(
            marketName: firstMarket?.marketTypeName ?? firstMarket?.name ?? "Markets",
            marketCount: match.numberTotalOfMarkets,
            icons: createMarketIcons(from: relevantMarkets, match: match)
        )
        
        // 3. Create MarketGroupData from markets and outcomes
        let marketGroupData = MarketGroupData(
            id: marketTypeId,
            marketLines: createMarketLines(from: relevantMarkets)
        )
        
        return TallOddsMatchData(
            matchId: match.id,
            leagueInfo: matchHeaderData,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            marketInfo: marketInfoData,
            outcomes: marketGroupData
        )
    }
    
    // MARK: - Helper Methods
    private static func extractCountryFlag(from match: Match) -> String? {
        // Extract country code from venue or sport metadata
        return match.venue?.isoCode
    }
    
    private static func extractSportIcon(from match: Match) -> String? {
        // Use sport ID or alpha code for icon lookup
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
        icons.append(MarketInfoIcon(type: .expressPickShort, isVisible: true))
        icons.append(MarketInfoIcon(type: .mostPopular, isVisible: true))
        icons.append(MarketInfoIcon(type: .betBuilder, isVisible: true))
        icons.append(MarketInfoIcon(type: .statistics, isVisible: true))
        return icons
    }
    
    private static func createMarketLines(from markets: [Market]) -> [MarketLineData] {
        return markets.compactMap { market in
            let outcomes = market.outcomes.map { outcome in
                MarketOutcomeData(
                    id: outcome.id,
                    title: outcome.translatedName,
                    value: String(format: "%.2f", outcome.bettingOffer.decimalOdd),
                    oddsChangeDirection: .none,
                    isSelected: false,
                    isDisabled: !outcome.bettingOffer.isAvailable
                )
            }
            
            // Determine line structure based on number of outcomes
            let lineType: MarketLineType = outcomes.count == 3 ? .threeColumn : .twoColumn
            let displayMode: MarketDisplayMode = outcomes.count == 3 ? .triple : .double
            
            return MarketLineData(
                id: market.id,
                leftOutcome: outcomes.first,
                middleOutcome: outcomes.count == 3 ? outcomes[1] : nil,
                rightOutcome: outcomes.last,
                displayMode: displayMode,
                lineType: lineType
            )
        }
    }
    
    
}
