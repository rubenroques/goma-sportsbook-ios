
import Foundation

// MARK: - Time Range Filter
public enum TimeRange: Equatable, CaseIterable {
    case all
    case oneHour
    case eightHours
    case today
    case fortyEightHours
    
    /// Converts to web app hoursInterval string format
    public var serverRawValue: String {
        switch self {
        case .all:
            return "all"
        case .oneHour:
            return "0-1"
        case .eightHours:
            return "0-8"
        case .today:
            return "0-24"
        case .fortyEightHours:
            return "0-48"
        }
    }
    
    /// Creates TimeRange from web app hoursInterval string
    public static func from(serverRawValue: String) -> TimeRange {
        switch serverRawValue {
        case "all":
            return .all
        case "0-1":
            return .oneHour
        case "0-8":
            return .eightHours
        case "0-24":
            return .today
        case "0-48":
            return .fortyEightHours
        default:
            return .all
        }
    }
    
    /// Display name for UI
    public var displayName: String {
        switch self {
        case .all:
            return "All"
        case .oneHour:
            return "1h"
        case .eightHours:
            return "8h"
        case .today:
            return "Today"
        case .fortyEightHours:
            return "48h"
        }
    }
}

// MARK: - Sort By Filter
public enum SortBy: Equatable, CaseIterable {
    case popular
    case upcoming
    case favorites
    
    /// Converts to web app sortEventsBy string format
    public var serverRawValue: String {
        switch self {
        case .popular:
            return "POPULAR"
        case .upcoming:
            return "UPCOMING"
        case .favorites:
            return "FAVORITES"
        }
    }
    
    /// Creates SortBy from web app sortEventsBy string
    public static func from(serverRawValue: String) -> SortBy {
        switch serverRawValue.uppercased() {
        case "POPULAR":
            return .popular
        case "UPCOMING":
            return .upcoming
        case "FAVORITES":
            return .favorites
        default:
            return .popular
        }
    }
    
    /// Display name for UI
    public var displayName: String {
        switch self {
        case .popular:
            return "Popular"
        case .upcoming:
            return "Upcoming"
        case .favorites:
            return "Favourites"
        }
    }
}

// MARK: - Location Filter
public enum LocationFilter: Equatable {
    case all
    case specific(String)
    
    /// Converts to web app locationId string format
    public var serverRawValue: String {
        switch self {
        case .all:
            return "all"
        case .specific(let id):
            return id
        }
    }
    
    /// Creates LocationFilter from web app locationId string
    public static func from(serverRawValue: String) -> LocationFilter {
        if serverRawValue == "all" || serverRawValue.isEmpty {
            return .all
        }
        return .specific(serverRawValue)
    }
}

// MARK: - Tournament Filter
public enum TournamentFilter: Equatable {
    case all
    case specific(String)
    
    /// Converts to web app tournamentId string format
    public var serverRawValue: String {
        switch self {
        case .all:
            return "all"
        case .specific(let id):
            return id
        }
    }
    
    /// Creates TournamentFilter from web app tournamentId string
    public static func from(serverRawValue: String) -> TournamentFilter {
        if serverRawValue == "all" || serverRawValue.isEmpty {
            return .all
        }
        return .specific(serverRawValue)
    }
}

// MARK: - Combined Filter Options
public struct MatchesFilterOptions: Equatable {
    public let sportId: String
    public let timeRange: TimeRange
    public let sortBy: SortBy
    public let location: LocationFilter
    public let tournament: TournamentFilter
    public let optionalUserId: String?
    
    public init(
        sportId: String,
        timeRange: TimeRange = .today,
        sortBy: SortBy = .upcoming,
        location: LocationFilter = .all,
        tournament: TournamentFilter = .all,
        optionalUserId: String? = nil
    ) {
        self.sportId = sportId
        self.timeRange = timeRange
        self.sortBy = sortBy
        self.location = location
        self.tournament = tournament
        self.optionalUserId = optionalUserId
    }
    
    /// Creates default filter options for a specific sport
    public static func defaultFilters(for sportId: String) -> MatchesFilterOptions {
        return MatchesFilterOptions(sportId: sportId)
    }
    
    /// No filters applied - equivalent to "all" values matching web app defaults
    public static func noFilters(for sportId: String) -> MatchesFilterOptions {
        return MatchesFilterOptions(
            sportId: sportId,
            timeRange: .today,
            sortBy: .upcoming,
            location: .all,
            tournament: .all,
            optionalUserId: nil
        )
    }
}
