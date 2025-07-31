//
//  AppliedEventsFilters+MatchesFilterOptions.swift
//  Sportsbook
//

import Foundation
import ServicesProvider

// MARK: - AppliedEventsFilters Extension
extension AppliedEventsFilters {
    
    /// Converts AppliedEventsFilters to MatchesFilterOptions
    public func toMatchesFilterOptions(optionalUserId: String? = nil) -> MatchesFilterOptions {
        // Convert timeValue (Float) to TimeRange enum
        let timeRange: TimeRange
        switch timeValue {
        case 0:
            timeRange = .all
        case 1:
            timeRange = .oneHour
        case 8:
            timeRange = .eightHours
        case 24:
            timeRange = .today
        case 48:
            timeRange = .fortyEightHours
        default:
            timeRange = .all
        }
        
        // Convert sortTypeId (String) to SortBy enum
        let sortBy: SortBy
        switch sortTypeId {
        case "1":
            sortBy = .popular
        case "2":
            sortBy = .upcoming
        case "3":
            sortBy = .favorites
        default:
            sortBy = .popular
        }
        
        // Convert leagueId to TournamentFilter
        let tournament: TournamentFilter
        if leagueId == "all" || leagueId == "0" || leagueId.isEmpty {
            tournament = .all
        } else {
            tournament = .specific(leagueId)
        }
        
        return MatchesFilterOptions(
            sportId: sportId,
            timeRange: timeRange,
            sortBy: sortBy,
            location: .all, // AppliedEventsFilters doesn't have location
            tournament: tournament,
            optionalUserId: optionalUserId
        )
    }
}

// MARK: - MatchesFilterOptions Extension
extension MatchesFilterOptions {
    
    /// Converts MatchesFilterOptions back to AppliedEventsFilters
    public func toAppliedEventsFilters() -> AppliedEventsFilters {
        // Convert TimeRange back to Float
        let timeValue: Float
        switch timeRange {
        case .all:
            timeValue = 0
        case .oneHour:
            timeValue = 1
        case .eightHours:
            timeValue = 8
        case .today:
            timeValue = 24
        case .fortyEightHours:
            timeValue = 48
        }
        
        // Convert SortBy back to String
        let sortTypeId: String
        switch sortBy {
        case .popular:
            sortTypeId = "1"
        case .upcoming:
            sortTypeId = "2"
        case .favorites:
            sortTypeId = "3"
        }
        
        // Convert TournamentFilter back to String
        let leagueId: String
        switch tournament {
        case .all:
            leagueId = "all"
        case .specific(let id):
            leagueId = id
        }
        
        return AppliedEventsFilters(
            sportId: sportId,
            timeValue: timeValue,
            sortTypeId: sortTypeId,
            leagueId: leagueId
        )
    }
}
