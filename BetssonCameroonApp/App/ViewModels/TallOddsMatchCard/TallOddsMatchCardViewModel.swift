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
        self.subscribeToLiveData()
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
        
        let outcome = marketOutcomesViewModelSubject.value.lineViewModels.compactMap { lineViewModel in
            if lineViewModel.marketStateSubject.value.leftOutcome?.id == outcomeId {
                print("LINEVM: \(lineViewModel.marketStateSubject.value)")
                return lineViewModel.marketStateSubject.value.leftOutcome
            } else if lineViewModel.marketStateSubject.value.middleOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.middleOutcome
            } else if lineViewModel.marketStateSubject.value.rightOutcome?.id == outcomeId {
                return lineViewModel.marketStateSubject.value.rightOutcome
            }
            return nil
        }.first
        
        let oddDouble = Double(outcome?.value ?? "")
        
        let bettingTicket = BettingTicket(id: outcome?.bettingOfferId ?? outcomeId, outcomeId: outcomeId, marketId: matchData.marketInfo.marketName, matchId: matchData.matchId, decimalOdd: oddDouble ?? 0.0, isAvailable: true, matchDescription: "\(matchData.homeParticipantName) - \(matchData.awayParticipantName)", marketDescription: matchData.marketInfo.marketName, outcomeDescription: outcome?.title ?? "", homeParticipantName: matchData.homeParticipantName, awayParticipantName: matchData.awayParticipantName, sportIdCode: nil)
        
        
        Env.betslipManager.addBettingTicket(bettingTicket)
    }
    
    func onOutcomeDeselected(outcomeId: String) {
        print("Production: Outcome deselected: \(outcomeId) for match: \(matchData.matchId)")

        let outcome = marketOutcomesViewModelSubject.value.lineViewModels.compactMap { lineVewModel in
            if lineVewModel.marketStateSubject.value.leftOutcome?.id == outcomeId {
                return lineVewModel.marketStateSubject.value.leftOutcome
            } else if lineVewModel.marketStateSubject.value.middleOutcome?.id == outcomeId {
                return lineVewModel.marketStateSubject.value.middleOutcome
            } else if lineVewModel.marketStateSubject.value.rightOutcome?.id == outcomeId {
                return lineVewModel.marketStateSubject.value.rightOutcome
            }
            return nil
        }.first
        
        let oddDouble = Double(outcome?.value ?? "")
        
        let bettingTicket = BettingTicket(id: outcomeId, outcomeId: outcomeId, marketId: matchData.marketInfo.marketName, matchId: matchData.matchId, decimalOdd: oddDouble ?? 0.0, isAvailable: true, matchDescription: "\(matchData.homeParticipantName) - \(matchData.awayParticipantName)", marketDescription: matchData.marketInfo.marketName, outcomeDescription: outcome?.title ?? "", homeParticipantName: matchData.homeParticipantName, awayParticipantName: matchData.awayParticipantName, sportIdCode: nil)
        
        
        Env.betslipManager.removeBettingTicket(bettingTicket)
    }
    
    func onMarketInfoTapped() {
        print("Production: Market info tapped for match: \(matchData.matchId)")
        // TODO: Implement market details navigation
    }
    
    func onCardTapped() {
        print("Production: Card tapped for match: \(matchData.matchId)")
        // TODO: Implement match details navigation
    }
    
    // MARK: - Live Data Subscription
    
    private func subscribeToLiveData() {
        print("[TallOddsMatchCardViewModel] 🟢 Starting live data subscription for match: \(matchData.matchId)")
        liveDataCancellable = Env.servicesProvider.subscribeToLiveDataUpdates(forEventWithId: matchData.matchId)
            .removeDuplicates()
            .sink(receiveCompletion: { [weak self] completion in
                print("[TallOddsMatchCardViewModel] 🔴 Live data subscription completed: \(completion) for match: \(self?.matchData.matchId ?? "unknown")")
            }, receiveValue: { [weak self] subscribableContent in
                guard let self = self else { return }
                
                switch subscribableContent {
                case .connected(let subscription):
                    print("[TallOddsMatchCardViewModel] 🟢 Live data connected: \(subscription.id) for match: \(self.matchData.matchId)")
                    
                case .contentUpdate(let eventLiveData):
                    // print("[TallOddsMatchCardViewModel] contentUpdated live data")
                    self.currentEventLiveData = eventLiveData
                    self.updateScoreViewModel(from: eventLiveData)
                    self.updateMatchHeaderViewModel(from: eventLiveData)
                
                case .disconnected:
                    print("[TallOddsMatchCardViewModel] 🔴 Live data disconnected for match: \(self.matchData.matchId)")
                }
            })
    }
    
    private func updateScoreViewModel(from eventLiveData: EventLiveData) {
        let liveScoreData = transformEventLiveDataToLiveScoreData(eventLiveData)
        let newScoreViewModel = Self.createScoreViewModel(from: liveScoreData)
        
        scoreViewModelSubject.send(newScoreViewModel)
    }
    
    private func updateMatchHeaderViewModel(from eventLiveData: EventLiveData) {
        // Update match time if available
        if let matchTime = eventLiveData.matchTime {
            if let status = eventLiveData.status, case .inProgress(let details) = status {
                if let headerViewModel = matchHeaderViewModelSubject.value as? MatchHeaderViewModel {
                    headerViewModel.updateMatchTime(details + ", " + matchTime + " min")
                }
            }
            else if let headerViewModel = matchHeaderViewModelSubject.value as? MatchHeaderViewModel {
                headerViewModel.updateMatchTime(matchTime)
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
            scoreCells: scoreCells
        )
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
        // 1. Create MatchHeaderData
        let matchHeaderData = MatchHeaderData(
            id: match.id,
            competitionName: match.competitionName,
            countryFlagImageName: Self.extractCountryFlag(from: match),
            sportIconImageName: Self.extractSportIcon(from: match),
            isFavorite: false, // TODO: Check with favorites service when available
            matchTime: Self.formatMatchTime(from: match),
            isLive: match.status.isLive
        )
        
        // 2. Create MarketInfoData
        let firstMarket = relevantMarkets.first
        let marketInfoData = MarketInfoData(
            marketName: firstMarket?.marketTypeName ?? firstMarket?.name ?? "Markets",
            marketCount: match.numberTotalOfMarkets,
            icons: createMarketIcons(from: relevantMarkets, match: match)
        )
        
        let outcomesViewModel = createMarketOutcomesViewModel(from: relevantMarkets, marketTypeId: marketTypeId)
        
        // Create the view model directly with production child view models
        let tallOddsMatchData = TallOddsMatchData(
            matchId: match.id,
            leagueInfo: matchHeaderData,
            homeParticipantName: match.homeParticipant.name,
            awayParticipantName: match.awayParticipant.name,
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: marketTypeId, marketLines: [])
        )
        
        let viewModel = TallOddsMatchCardViewModel(matchData: tallOddsMatchData)

        viewModel.marketOutcomesViewModelSubject.send(outcomesViewModel)

        return viewModel
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
    
}
