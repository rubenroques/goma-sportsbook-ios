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
    public let scoreViewModel: ScoreViewModelProtocol?
    public let isLive: Bool

    public init(
        homeTeamName: String,
        awayTeamName: String,
        sport: String,
        country: String,
        league: String,
        countryId: String? = nil,
        leagueId: String? = nil,
        scoreViewModel: ScoreViewModelProtocol? = nil,
        isLive: Bool = false
    ) {
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.sport = sport
        self.country = country
        self.league = league
        self.countryId = countryId
        self.leagueId = leagueId
        self.scoreViewModel = scoreViewModel
        self.isLive = isLive
    }

    // Custom Equatable implementation (scoreViewModel compared by identity)
    public static func == (lhs: MatchHeaderCompactData, rhs: MatchHeaderCompactData) -> Bool {
        return lhs.homeTeamName == rhs.homeTeamName &&
            lhs.awayTeamName == rhs.awayTeamName &&
            lhs.sport == rhs.sport &&
            lhs.country == rhs.country &&
            lhs.league == rhs.league &&
            lhs.countryId == rhs.countryId &&
            lhs.leagueId == rhs.leagueId &&
            lhs.isLive == rhs.isLive
    }
}

// MARK: - MatchHeaderCompactViewModelProtocol
public protocol MatchHeaderCompactViewModelProtocol: AnyObject {
    // Data
    var headerDataPublisher: AnyPublisher<MatchHeaderCompactData, Never> { get }

    // Actions
    var onCountryTapped: ((String) -> Void)? { get set }
    var onLeagueTapped: ((String) -> Void)? { get set }

    // Methods
    func handleCountryTap()
    func handleLeagueTap()
}
