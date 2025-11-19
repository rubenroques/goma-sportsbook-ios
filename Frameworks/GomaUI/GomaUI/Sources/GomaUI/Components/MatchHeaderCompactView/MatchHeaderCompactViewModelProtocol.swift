import Foundation
import Combine

// MARK: - MatchHeaderCompactData
public struct MatchHeaderCompactData: Equatable {
    public let homeTeamName: String
    public let awayTeamName: String
    public let sport: String
    public let country: String
    public let league: String
    public let countryId: String?
    public let leagueId: String?
    public let hasStatistics: Bool
    public let isStatisticsCollapsed: Bool
    public let statisticsCollapsedTitle: String
    public let statisticsExpandedTitle: String
    public let matchTime: String?
    public let isLive: Bool

    public init(
        homeTeamName: String,
        awayTeamName: String,
        sport: String,
        country: String,
        league: String,
        countryId: String? = nil,
        leagueId: String? = nil,
        hasStatistics: Bool = true,
        isStatisticsCollapsed: Bool = true,
        statisticsCollapsedTitle: String = "View Statistics",
        statisticsExpandedTitle: String = "Close Statistics",
        matchTime: String? = nil,
        isLive: Bool = false
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.sport = sport
        self.country = country
        self.league = league
        self.countryId = countryId
        self.leagueId = leagueId
        self.hasStatistics = hasStatistics
        self.isStatisticsCollapsed = isStatisticsCollapsed
        self.statisticsCollapsedTitle = statisticsCollapsedTitle
        self.statisticsExpandedTitle = statisticsExpandedTitle
        self.matchTime = matchTime
        self.isLive = isLive
    }
}

// MARK: - MatchHeaderCompactViewModelProtocol
public protocol MatchHeaderCompactViewModelProtocol: AnyObject {
    // Data
    var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> { get }
    var matchTimePublisher: AnyPublisher<String?, Never> { get }
    var isLivePublisher: AnyPublisher<Bool, Never> { get }

    // Actions
    var onStatisticsTapped: (() -> Void)? { get set }
    var onCountryTapped: ((String) -> Void)? { get set }
    var onLeagueTapped: ((String) -> Void)? { get set }

    // Methods
    func handleStatisticsTap()
    func handleCountryTap()
    func handleLeagueTap()
}