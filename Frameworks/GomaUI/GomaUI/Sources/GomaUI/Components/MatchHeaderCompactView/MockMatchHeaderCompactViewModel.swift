import Foundation
import Combine

public final class MockMatchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol {

    // MARK: - Properties
    @Published private var headerData: MatchHeaderCompactData

    // MARK: - Protocol Conformance
    public var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> {
        $headerData.eraseToAnyPublisher()
    }

    public var onStatisticsTapped: (() -> Void)?
    public var onCountryTapped: ((String) -> Void)?
    public var onLeagueTapped: ((String) -> Void)?
    
    // MARK: - Initialization
    public init(headerData: MatchHeaderCompactData) {
        self.headerData = headerData
    }
    
    // MARK: - Methods
    public func handleStatisticsTap() {
        // Toggle the collapsed state
        let currentData = headerData
        headerData = MatchHeaderCompactData(
            homeTeamName: currentData.homeTeamName,
            awayTeamName: currentData.awayTeamName,
            sport: currentData.sport,
            country: currentData.country,
            league: currentData.league,
            countryId: currentData.countryId,
            leagueId: currentData.leagueId,
            hasStatistics: currentData.hasStatistics,
            isStatisticsCollapsed: !currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle,
            scoreViewModel: currentData.scoreViewModel,
            isLive: currentData.isLive
        )

        // Also call the callback
        onStatisticsTapped?()
    }

    public func handleCountryTap() {
        if let countryId = headerData.countryId {
            onCountryTapped?(countryId)
        }
    }

    public func handleLeagueTap() {
        if let leagueId = headerData.leagueId {
            onLeagueTapped?(leagueId)
        }
    }
}

// MARK: - Preset Mock ViewModels
public extension MockMatchHeaderCompactViewModel {
    
    static var `default`: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Manchester United",
                awayTeamName: "Glasgow Rangers",
                sport: "Football",
                country: "England",
                league: "UEFA Europa League",
                countryId: "country-england",
                leagueId: "league-uefa-europa",
                hasStatistics: true
            )
        )
    }
    
    static var withoutStatistics: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Real Madrid",
                awayTeamName: "Barcelona",
                sport: "Football",
                country: "Spain",
                league: "La Liga",
                countryId: "country-spain",
                leagueId: "league-la-liga",
                hasStatistics: false
            )
        )
    }
    
    static var longNames: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Borussia Mönchengladbach",
                awayTeamName: "Wolverhampton Wanderers",
                sport: "Football",
                country: "Germany",
                league: "UEFA Champions League Qualification",
                countryId: "country-germany",
                leagueId: "league-ucl-qual",
                hasStatistics: true
            )
        )
    }
    
    static var longContent: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "FC Bayern München Fußball-Verein e.V.",
                awayTeamName: "Real Club Deportivo de La Coruña",
                sport: "Football",
                country: "Germany",
                league: "UEFA Champions League Qualification Playoffs",
                countryId: "country-germany",
                leagueId: "league-ucl-playoffs",
                hasStatistics: true
            )
        )
    }

    // MARK: - Live Match Presets with Scores

    static var liveFootballMatch: MockMatchHeaderCompactViewModel {
        // Create mock score for football
        let scoreData = [
            ScoreDisplayData(
                id: "match",
                homeScore: "2",
                awayScore: "1",
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        return MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Arsenal",
                awayTeamName: "Chelsea",
                sport: "Football",
                country: "England",
                league: "Premier League",
                countryId: "country-england",
                leagueId: "league-premier",
                hasStatistics: true,
                scoreViewModel: scoreViewModel,
                isLive: true
            )
        )
    }

    static var liveTennisMatch: MockMatchHeaderCompactViewModel {
        // Create mock score for tennis (game + sets)
        let scoreData = [
            ScoreDisplayData(
                id: "game-current",
                homeScore: "40",
                awayScore: "30",
                style: .background,
                highlightingMode: .bothHighlight,
                showsTrailingSeparator: true,
                servingPlayer: .home
            ),
            ScoreDisplayData(
                id: "set-1",
                homeScore: "6",
                awayScore: "3",
                index: 1,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-2",
                homeScore: "4",
                awayScore: "6",
                index: 2,
                style: .simple,
                highlightingMode: .winnerLoser
            ),
            ScoreDisplayData(
                id: "set-3",
                homeScore: "2",
                awayScore: "1",
                index: 3,
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        return MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Nadal",
                awayTeamName: "Federer",
                sport: "Tennis",
                country: "France",
                league: "Roland Garros",
                countryId: "country-france",
                leagueId: "league-roland-garros",
                hasStatistics: true,
                scoreViewModel: scoreViewModel,
                isLive: true
            )
        )
    }

    static var liveLongNames: MockMatchHeaderCompactViewModel {
        // Create mock score
        let scoreData = [
            ScoreDisplayData(
                id: "match",
                homeScore: "1",
                awayScore: "2",
                style: .simple,
                highlightingMode: .bothHighlight
            )
        ]
        let scoreViewModel = MockScoreViewModel(scoreCells: scoreData, visualState: .display)

        return MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Wolverhampton Wanderers",
                awayTeamName: "Brighton & Hove Albion",
                sport: "Football",
                country: "England",
                league: "Premier League",
                countryId: "country-england",
                leagueId: "league-premier",
                hasStatistics: true,
                scoreViewModel: scoreViewModel,
                isLive: true
            )
        )
    }
}
