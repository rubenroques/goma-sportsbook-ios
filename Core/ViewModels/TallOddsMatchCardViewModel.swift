import Combine
import UIKit
import GomaUI

final class TallOddsMatchCardViewModel: TallOddsMatchCardViewModelProtocol {
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TallOddsMatchCardDisplayState, Never>
    private let matchHeaderViewModelSubject: CurrentValueSubject<MatchHeaderViewModelProtocol, Never>
    private let marketInfoLineViewModelSubject: CurrentValueSubject<MarketInfoLineViewModelProtocol, Never>
    private let marketOutcomesViewModelSubject: CurrentValueSubject<MarketOutcomesMultiLineViewModelProtocol, Never>
    
    // MARK: - Logging Properties
    private let creationTime: CFAbsoluteTime
    private var lastUpdateTime: CFAbsoluteTime = 0
    
    public var displayStatePublisher: AnyPublisher<TallOddsMatchCardDisplayState, Never> {
        return displayStateSubject
            .handleEvents(receiveOutput: { [weak self] state in
                let currentTime = CFAbsoluteTimeGetCurrent()
                let timeSinceLastUpdate = self?.lastUpdateTime == 0 ? 0 : currentTime - (self?.lastUpdateTime ?? 0)
                let timeSinceCreation = currentTime - (self?.creationTime ?? 0)
                
                let longLog = """
                [TallOdds] displayStatePublisher sending update for match: \(state.matchId) |
                Time since creation: \(String(format: "%.3f", timeSinceCreation))s |
                Time since last update: \(String(format: "%.3f", timeSinceLastUpdate))s
                """
                print("displayStatePublisher \(longLog)")
                
                self?.lastUpdateTime = currentTime
            })
            .eraseToAnyPublisher()
    }
    
    public var matchHeaderViewModelPublisher: AnyPublisher<MatchHeaderViewModelProtocol, Never> {
        return matchHeaderViewModelSubject
            .handleEvents(receiveOutput: { _ in
                print("[TallOdds] matchHeaderViewModelPublisher sending update for match: \(self.matchData.matchId)")
            })
            .eraseToAnyPublisher()
    }
    
    public var marketInfoLineViewModelPublisher: AnyPublisher<MarketInfoLineViewModelProtocol, Never> {
        return marketInfoLineViewModelSubject
            .handleEvents(receiveOutput: { _ in
                print("[TallOdds] marketInfoLineViewModelPublisher sending update for match: \(self.matchData.matchId)")
            })
            .eraseToAnyPublisher()
    }
    
    public var marketOutcomesViewModelPublisher: AnyPublisher<MarketOutcomesMultiLineViewModelProtocol, Never> {
        return marketOutcomesViewModelSubject
            .handleEvents(receiveOutput: { _ in
                print("[TallOdds] marketOutcomesViewModelPublisher sending update for match: \(self.matchData.matchId)")
            })
            .eraseToAnyPublisher()
    }
    
    private let matchData: TallOddsMatchData
    
    // MARK: - Initialization
    init(matchData: TallOddsMatchData) {
        self.creationTime = CFAbsoluteTimeGetCurrent()
        print("[TallOdds] Creating TallOddsMatchCardViewModel for match: \(matchData.matchId) at time: \(String(format: "%.3f", creationTime))")
        self.matchData = matchData
        
        // Create initial display state from match data
        let initialDisplayState = TallOddsMatchCardDisplayState(
            matchId: matchData.matchId,
            homeParticipantName: matchData.homeParticipantName,
            awayParticipantName: matchData.awayParticipantName
        )
        
        // Create child view models from match data
        let headerViewModel = Self.createMatchHeaderViewModel(from: matchData.leagueInfo)
        let marketInfoViewModel = Self.createMarketInfoLineViewModel(from: matchData.marketInfo)
        let outcomesViewModel = Self.createMarketOutcomesViewModel(from: matchData.outcomes)
        
        print("[TallOdds] Created child view models for match: \(matchData.matchId)")
        
        // Initialize subjects
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.matchHeaderViewModelSubject = CurrentValueSubject(headerViewModel)
        self.marketInfoLineViewModelSubject = CurrentValueSubject(marketInfoViewModel)
        self.marketOutcomesViewModelSubject = CurrentValueSubject(outcomesViewModel)
        
        print("[TallOdds] Initialized all subjects for match: \(matchData.matchId)")
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
}

// MARK: - Factory for Creating from Real Match Data
extension TallOddsMatchCardViewModel {
    
    /// Creates a TallOddsMatchCardViewModel from real Match and Market data
    static func create(from match: Match, relevantMarkets: [Market], marketTypeId: String) -> TallOddsMatchCardViewModel {
        print("[TallOdds] Creating TallOddsMatchCardViewModel from Match data - ID: \(match.id), Markets: \(relevantMarkets.count), MarketType: \(marketTypeId)")
        let matchData = extractMatchData(from: match, relevantMarkets: relevantMarkets, marketTypeId: marketTypeId)
        return TallOddsMatchCardViewModel(matchData: matchData)
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
            guard !market.outcomes.isEmpty else { return nil }
            
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
                lineType: lineType,
                isLineDisabled: !market.isAvailable
            )
        }
    }
}
