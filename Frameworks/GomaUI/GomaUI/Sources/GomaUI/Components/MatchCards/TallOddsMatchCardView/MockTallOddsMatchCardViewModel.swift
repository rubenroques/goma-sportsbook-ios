import Combine
import UIKit

final public class MockTallOddsMatchCardViewModel: TallOddsMatchCardViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<TallOddsMatchCardDisplayState, Never>
    private let matchHeaderViewModelSubject: CurrentValueSubject<MatchHeaderViewModelProtocol, Never>
    private let marketInfoLineViewModelSubject: CurrentValueSubject<MarketInfoLineViewModelProtocol, Never>
    private let marketOutcomesViewModelSubject: CurrentValueSubject<MarketOutcomesMultiLineViewModelProtocol, Never>
    private let scoreViewModelSubject: CurrentValueSubject<ScoreViewModelProtocol?, Never>
    
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
    
    private var matchData: TallOddsMatchData
    
    // MARK: - Initialization
    public init(matchData: TallOddsMatchData, useSingleLineOutcomes: Bool = false) {
        self.matchData = matchData
        
        // Create initial display state
        let initialDisplayState = TallOddsMatchCardDisplayState(
            matchId: matchData.matchId,
            homeParticipantName: matchData.homeParticipantName,
            awayParticipantName: matchData.awayParticipantName,
            isLive: matchData.leagueInfo.isLive
        )
        
        // Create child view models
        let headerViewModel = MockMatchHeaderViewModel(matchHeaderData: matchData.leagueInfo)
        let marketInfoViewModel = MockMarketInfoLineViewModel(marketInfoData: matchData.marketInfo)
        // Outcomes VM configuration (default: multi-line mock)
        let outcomesViewModel: MarketOutcomesMultiLineViewModelProtocol = {
            if useSingleLineOutcomes {
                let singleLine = MockMarketOutcomesLineViewModel.threeWayMarket
                return MockMarketOutcomesMultiLineViewModel(groupTitle: nil, lineViewModels: [singleLine])
            } else {
                return MockMarketOutcomesMultiLineViewModel.overUnderMarketGroup
            }
        }()
        
        // Create score view model for live matches
        let scoreViewModel: ScoreViewModelProtocol? = matchData.liveScoreData != nil ? 
            MockScoreViewModel(scoreCells: matchData.liveScoreData!.scoreCells, visualState: .display) : nil
        
        // Initialize subjects
        self.displayStateSubject = CurrentValueSubject(initialDisplayState)
        self.matchHeaderViewModelSubject = CurrentValueSubject(headerViewModel)
        self.marketInfoLineViewModelSubject = CurrentValueSubject(marketInfoViewModel)
        self.marketOutcomesViewModelSubject = CurrentValueSubject(outcomesViewModel)
        self.scoreViewModelSubject = CurrentValueSubject(scoreViewModel)
    }
    
    // MARK: - TallOddsMatchCardViewModelProtocol
    public func onMatchHeaderAction() {
        print("Match header tapped for match: \(matchData.matchId)")
    }
    
    public func onFavoriteToggle() {
        print("Favorite toggled for match: \(matchData.matchId)")
    }
    
    public func onOutcomeSelected(outcomeId: String) {
        print("Outcome selected: \(outcomeId) for match: \(matchData.matchId)")
    }
    
    public func onOutcomeDeselected(outcomeId: String) {
        print("Outcome deselected: \(outcomeId) for match: \(matchData.matchId)")
    }
    
    public func onMarketInfoTapped() {
        print("Market info tapped for match: \(matchData.matchId)")
    }
    
    public func onCardTapped() {
        print("Card tapped for match: \(matchData.matchId)")
    }
}

// MARK: - Mock Factory
extension MockTallOddsMatchCardViewModel {
    public static var premierLeagueMock: MockTallOddsMatchCardViewModel {
        // Simple match data using existing working structures
        let marketIcons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true)
        ]
        
        let marketInfoData = MarketInfoData(
            marketName: "1X2 TR",
            marketCount: 1235,
            icons: marketIcons,
            marketId: "123",
            marketTypeId: nil
        )
        
        // Create minimal match data - will use factory view models
        let matchData = TallOddsMatchData(
            matchId: "liverpool_arsenal_premier_league",
            leagueInfo: MatchHeaderData(
                id: "premier_league_match",
                competitionName: "Premier League",
                countryFlagImageName: "UK",
                sportIconImageName: "sportscourt.fill", // Football icon
                isFavorite: false,
                matchTime: "16 April, 18:00",
                isLive: false
            ),
            homeParticipantName: "Liverpool F.C.",
            awayParticipantName: "Arsenal F.C.",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "premier_league_markets", marketLines: [])
        )
        
        return MockTallOddsMatchCardViewModel(matchData: matchData)
    }
    
    public static func premierLeagueMock(singleLineOutcomes: Bool) -> MockTallOddsMatchCardViewModel {
        let marketIcons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true)
        ]
        let marketInfoData = MarketInfoData(
            marketName: "1X2 TR",
            marketCount: 1235,
            icons: marketIcons,
            marketId: "123",
            marketTypeId: nil
        )
        let matchData = TallOddsMatchData(
            matchId: "liverpool_arsenal_premier_league",
            leagueInfo: MatchHeaderData(
                id: "premier_league_match",
                competitionName: "Premier League",
                countryFlagImageName: "UK",
                sportIconImageName: "sportscourt.fill",
                isFavorite: false,
                matchTime: "16 April, 18:00",
                isLive: false
            ),
            homeParticipantName: "Liverpool F.C.",
            awayParticipantName: "Arsenal F.C.",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "premier_league_markets", marketLines: [])
        )
        return MockTallOddsMatchCardViewModel(matchData: matchData, useSingleLineOutcomes: singleLineOutcomes)
    }
    
    public static var compactMock: MockTallOddsMatchCardViewModel {
        let marketInfoData = MarketInfoData(
            marketName: "Match Winner",
            marketCount: 456,
            icons: [
                MarketInfoIcon(type: .mostPopular, isVisible: true)
            ],
            marketId: "123",
            marketTypeId: nil
        )
        
        let matchData = TallOddsMatchData(
            matchId: "barcelona_madrid_la_liga",
            leagueInfo: MatchHeaderData(id: "la_liga_match", competitionName: "La Liga", matchTime: "Tomorrow, 20:30", isLive: false),
            homeParticipantName: "FC Barcelona",
            awayParticipantName: "Real Madrid",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "la_liga_markets", marketLines: [])
        )
        
        return MockTallOddsMatchCardViewModel(matchData: matchData)
    }
    
    public static func compactMock(singleLineOutcomes: Bool) -> MockTallOddsMatchCardViewModel {
        let marketInfoData = MarketInfoData(
            marketName: "Match Winner",
            marketCount: 456,
            icons: [
                MarketInfoIcon(type: .mostPopular, isVisible: true)
            ],
            marketId: "123",
            marketTypeId: nil
        )
        let matchData = TallOddsMatchData(
            matchId: "barcelona_madrid_la_liga",
            leagueInfo: MatchHeaderData(id: "la_liga_match", competitionName: "La Liga", matchTime: "Tomorrow, 20:30", isLive: false),
            homeParticipantName: "FC Barcelona",
            awayParticipantName: "Real Madrid",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "la_liga_markets", marketLines: [])
        )
        return MockTallOddsMatchCardViewModel(matchData: matchData, useSingleLineOutcomes: singleLineOutcomes)
    }
    
    public static var bundesliegaMock: MockTallOddsMatchCardViewModel {
        let marketIcons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true),
            MarketInfoIcon(type: .betBuilder, isVisible: true)
        ]
        
        let marketInfoData = MarketInfoData(
            marketName: "Both Teams Score",
            marketCount: 2847,
            icons: marketIcons,
            marketId: "123",
            marketTypeId: nil
        )
        
        let matchData = TallOddsMatchData(
            matchId: "bayern_dortmund_bundesliga",
            leagueInfo: MatchHeaderData(id: "bundesliga_match", competitionName: "Bundesliga", matchTime: "18 April, 15:30", isLive: false),
            homeParticipantName: "Bayern Munich",
            awayParticipantName: "Borussia Dortmund",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "bundesliga_markets", marketLines: [])
        )
        
        return MockTallOddsMatchCardViewModel(matchData: matchData)
    }
    
    public static func bundesliegaMock(singleLineOutcomes: Bool) -> MockTallOddsMatchCardViewModel {
        let marketIcons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true),
            MarketInfoIcon(type: .statistics, isVisible: true),
            MarketInfoIcon(type: .betBuilder, isVisible: true)
        ]
        let marketInfoData = MarketInfoData(
            marketName: "Both Teams Score",
            marketCount: 2847,
            icons: marketIcons,
            marketId: "123",
            marketTypeId: nil
        )
        let matchData = TallOddsMatchData(
            matchId: "bayern_dortmund_bundesliga",
            leagueInfo: MatchHeaderData(id: "bundesliga_match", competitionName: "Bundesliga", matchTime: "18 April, 15:30", isLive: false),
            homeParticipantName: "Bayern Munich",
            awayParticipantName: "Borussia Dortmund",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "bundesliga_markets", marketLines: [])
        )
        return MockTallOddsMatchCardViewModel(matchData: matchData, useSingleLineOutcomes: singleLineOutcomes)
    }
    
    public static var liveMock: MockTallOddsMatchCardViewModel {
        let marketIcons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true)
        ]
        
        let marketInfoData = MarketInfoData(
            marketName: "1X2",
            marketCount: 987,
            icons: marketIcons,
            marketId: "123",
            marketTypeId: nil
        )
        
        // Create live score data for football
        let liveScoreData = LiveScoreData(
            scoreCells: [
                ScoreDisplayData(id: "main", homeScore: "2", awayScore: "1", style: .simple)
            ]
        )
        
        let matchData = TallOddsMatchData(
            matchId: "chelsea_tottenham_live",
            leagueInfo: MatchHeaderData(
                id: "premier_league_live",
                competitionName: "Premier League",
                countryFlagImageName: "GB",
                sportIconImageName: "1", // Football icon
                isFavorite: true,
                matchTime: "2nd Half, 67 Min",
                isLive: true
            ),
            homeParticipantName: "Chelsea F.C.",
            awayParticipantName: "Tottenham Hotspur",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "live_match_markets", marketLines: []),
            liveScoreData: liveScoreData
        )
        
        return MockTallOddsMatchCardViewModel(matchData: matchData)
    }
    
    public static func liveMock(singleLineOutcomes: Bool) -> MockTallOddsMatchCardViewModel {
        let marketIcons = [
            MarketInfoIcon(type: .expressPickShort, isVisible: true),
            MarketInfoIcon(type: .mostPopular, isVisible: true)
        ]
        let marketInfoData = MarketInfoData(
            marketName: "1X2",
            marketCount: 987,
            icons: marketIcons,
            marketId: "123",
            marketTypeId: nil
        )
        let liveScoreData = LiveScoreData(
            scoreCells: [
                ScoreDisplayData(id: "main", homeScore: "2", awayScore: "1", style: .simple)
            ]
        )
        let matchData = TallOddsMatchData(
            matchId: "chelsea_tottenham_live",
            leagueInfo: MatchHeaderData(
                id: "premier_league_live",
                competitionName: "Premier League",
                countryFlagImageName: "GB",
                sportIconImageName: "1",
                isFavorite: true,
                matchTime: "2nd Half, 67 Min",
                isLive: true
            ),
            homeParticipantName: "Chelsea F.C.",
            awayParticipantName: "Tottenham Hotspur",
            marketInfo: marketInfoData,
            outcomes: MarketGroupData(id: "live_match_markets", marketLines: []),
            liveScoreData: liveScoreData
        )
        return MockTallOddsMatchCardViewModel(matchData: matchData, useSingleLineOutcomes: singleLineOutcomes)
    }
}
