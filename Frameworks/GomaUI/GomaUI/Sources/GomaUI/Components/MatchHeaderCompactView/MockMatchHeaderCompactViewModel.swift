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
            competition: currentData.competition,
            league: currentData.league,
            hasStatistics: currentData.hasStatistics,
            isStatisticsCollapsed: !currentData.isStatisticsCollapsed,
            statisticsCollapsedTitle: currentData.statisticsCollapsedTitle,
            statisticsExpandedTitle: currentData.statisticsExpandedTitle
        )
        
        // Also call the callback
        onStatisticsTapped?()
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
                competition: "International",
                league: "UEFA Europa League",
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
                competition: "Domestic",
                league: "La Liga",
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
                competition: "International Friendlies",
                league: "UEFA Champions League Qualification",
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
                competition: "International Championship Tournament",
                league: "UEFA Champions League Qualification Playoffs",
                hasStatistics: true
            )
        )
    }
}
