import Foundation

/// Data model for match banner display
public struct MatchBannerModel {
    /// Unique identifier for the match
    public let id: String

    /// Whether the match is currently live
    public let isLive: Bool

    /// Date and time of the match
    public let dateTime: Date

    /// League or competition name
    public let leagueName: String

    /// Home team name
    public let homeTeam: String

    /// Away team name
    public let awayTeam: String

    /// Background image URL (optional)
    public let backgroundImageURL: String?

    /// Current match time for live matches (e.g., "44 Min", "1st Half")
    public let matchTime: String?

    /// Home team score (for live matches)
    public let homeScore: Int?

    /// Away team score (for live matches)
    public let awayScore: Int?

    /// Match outcomes for betting
    public let outcomes: [MatchOutcome]

    public init(
        id: String,
        isLive: Bool,
        dateTime: Date,
        leagueName: String,
        homeTeam: String,
        awayTeam: String,
        backgroundImageURL: String? = nil,
        matchTime: String? = nil,
        homeScore: Int? = nil,
        awayScore: Int? = nil,
        outcomes: [MatchOutcome] = []
    ) {
        self.id = id
        self.isLive = isLive
        self.dateTime = dateTime
        self.leagueName = leagueName
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.backgroundImageURL = backgroundImageURL
        self.matchTime = matchTime
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.outcomes = outcomes
    }
}

/// Betting outcome for a match
public struct MatchOutcome {
    /// Unique identifier for the outcome
    public let id: String

    /// Display name (e.g., "Man City", "Draw", "Arsenal")
    public let displayName: String

    /// Odds value (e.g., 1.55, 5.00)
    public let odds: Double

    /// Whether this outcome is currently selected
    public let isSelected: Bool

    /// Whether this outcome is available for betting
    public let isEnabled: Bool

    public init(
        id: String,
        displayName: String,
        odds: Double,
        isSelected: Bool = false,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.displayName = displayName
        self.odds = odds
        self.isSelected = isSelected
        self.isEnabled = isEnabled
    }
}

// MARK: - Helper Extensions
extension MatchBannerModel {
    /// Empty state for cell reuse
    public static let empty = MatchBannerModel(
        id: "",
        isLive: false,
        dateTime: Date(),
        leagueName: "",
        homeTeam: "",
        awayTeam: "",
        outcomes: []
    )

    /// Formatted date string for display
    public var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy - h:mm a"
        return formatter.string(from: dateTime)
    }

    /// Header text for live/prelive display
    public var headerText: String {
        if isLive {
            let timeText = matchTime ?? "LIVE"
            return "\(timeText) • \(leagueName)"
        } else {
            return "\(formattedDateTime) • \(leagueName)"
        }
    }

    /// Whether this match has a valid score to display
    public var hasValidScore: Bool {
        return isLive && homeScore != nil && awayScore != nil
    }
}