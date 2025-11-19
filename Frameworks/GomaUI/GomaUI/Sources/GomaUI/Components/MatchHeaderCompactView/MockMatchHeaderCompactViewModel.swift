import Foundation
import Combine

public final class MockMatchHeaderCompactViewModel: MatchHeaderCompactViewModelProtocol {

    // MARK: - Properties
    @Published private var headerData: MatchHeaderCompactData

    // MARK: - Protocol Conformance
    public var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> {
        $headerData.eraseToAnyPublisher()
    }

    public var matchTimePublisher: AnyPublisher<String?, Never> {
        $headerData.map(\.matchTime).eraseToAnyPublisher()
    }

    public var isLivePublisher: AnyPublisher<Bool, Never> {
        $headerData.map(\.isLive).eraseToAnyPublisher()
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
            matchTime: currentData.matchTime,
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

    static var liveFootballMatch: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Liverpool FC",
                awayTeamName: "Arsenal FC",
                sport: "Football",
                country: "England",
                league: "Premier League",
                countryId: "country-england",
                leagueId: "league-premier-league",
                hasStatistics: true,
                isStatisticsCollapsed: true,
                statisticsCollapsedTitle: "View Statistics",
                statisticsExpandedTitle: "Close Statistics",
                matchTime: "1st Half, 45 min",
                isLive: true
            )
        )
    }

    static var liveTennisMatch: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "Novak Djokovic",
                awayTeamName: "Rafael Nadal",
                sport: "Tennis",
                country: "France",
                league: "Roland Garros",
                countryId: "country-france",
                leagueId: "league-roland-garros",
                hasStatistics: true,
                isStatisticsCollapsed: true,
                statisticsCollapsedTitle: "View Statistics",
                statisticsExpandedTitle: "Close Statistics",
                matchTime: "6th Game (2nd Set)",
                isLive: true
            )
        )
    }

    static var liveBasketballMatch: MockMatchHeaderCompactViewModel {
        MockMatchHeaderCompactViewModel(
            headerData: MatchHeaderCompactData(
                homeTeamName: "LA Lakers",
                awayTeamName: "Boston Celtics",
                sport: "Basketball",
                country: "USA",
                league: "NBA",
                countryId: "country-usa",
                leagueId: "league-nba",
                hasStatistics: true,
                isStatisticsCollapsed: true,
                statisticsCollapsedTitle: "View Statistics",
                statisticsExpandedTitle: "Close Statistics",
                matchTime: "3rd Quarter, 8 min",
                isLive: true
            )
        )
    }
}
