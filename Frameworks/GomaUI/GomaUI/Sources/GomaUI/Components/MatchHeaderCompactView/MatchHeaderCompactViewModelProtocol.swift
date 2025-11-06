import Foundation
import Combine

// MARK: - MatchHeaderCompactData
public struct MatchHeaderCompactData: Equatable {
    public let homeTeamName: String
    public let awayTeamName: String
    public let sport: String
    public let competition: String
    public let league: String
    public let hasStatistics: Bool
    public let isStatisticsCollapsed: Bool
    public let statisticsCollapsedTitle: String
    public let statisticsExpandedTitle: String
    
    public init(
        homeTeamName: String,
        awayTeamName: String,
        sport: String,
        competition: String,
        league: String,
        hasStatistics: Bool = true,
        isStatisticsCollapsed: Bool = true,
        statisticsCollapsedTitle: String = "View Statistics",
        statisticsExpandedTitle: String = "Close Statistics"
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.sport = sport
        self.competition = competition
        self.league = league
        self.hasStatistics = hasStatistics
        self.isStatisticsCollapsed = isStatisticsCollapsed
        self.statisticsCollapsedTitle = statisticsCollapsedTitle
        self.statisticsExpandedTitle = statisticsExpandedTitle
    }
}

// MARK: - MatchHeaderCompactViewModelProtocol
public protocol MatchHeaderCompactViewModelProtocol: AnyObject {
    // Data
    var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> { get }
    
    // Actions
    var onStatisticsTapped: (() -> Void)? { get set }
    
    // Methods
    func handleStatisticsTap()
}