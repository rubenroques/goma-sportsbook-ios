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
        // Convert TimeFilter to TimeRange enum
        let timeRange: TimeRange
        switch timeFilter {
        case .all:
            timeRange = .all
        case .oneHour:
            timeRange = .oneHour
        case .eightHours:
            timeRange = .eightHours
        case .today:
            timeRange = .today
        case .fortyEightHours:
            timeRange = .fortyEightHours
        }
        
        // Convert SortType to SortBy enum
        let sortBy: SortBy
        switch sortType {
        case .popular:
            sortBy = .popular
        case .upcoming:
            sortBy = .upcoming
        case .favorites:
            sortBy = .favorites
        }
        
        // Convert leagueId to TournamentFilter and LocationFilter
        let tournament: TournamentFilter
        let location: LocationFilter
        
        // Check for special "{countryId}_all" format
        if leagueId.hasSuffix("_all") {
            // Extract country ID and set location filter
            let countryId = String(leagueId.dropLast(4)) // Remove "_all"
            location = .specific(countryId)
            tournament = .all
        } else if leagueId == "all" || leagueId == "0" || leagueId.isEmpty {
            // No specific filters
            location = .all
            tournament = .all
        } else {
            // Specific league selected, no country filter
            location = .all
            tournament = .specific(leagueId)
        }
        
        return MatchesFilterOptions(
            sportId: sportId,
            timeRange: timeRange,
            sortBy: sortBy,
            location: location,
            tournament: tournament,
            optionalUserId: optionalUserId
        )
    }
}

// MARK: - MatchesFilterOptions Extension
extension MatchesFilterOptions {
    
    /// Converts MatchesFilterOptions back to AppliedEventsFilters
    public func toAppliedEventsFilters() -> AppliedEventsFilters {
        // Convert TimeRange to TimeFilter
        let timeFilter: AppliedEventsFilters.TimeFilter
        switch timeRange {
        case .all:
            timeFilter = .all
        case .oneHour:
            timeFilter = .oneHour
        case .eightHours:
            timeFilter = .eightHours
        case .today:
            timeFilter = .today
        case .fortyEightHours:
            timeFilter = .fortyEightHours
        }
        
        // Convert SortBy to SortType
        let sortType: AppliedEventsFilters.SortType
        switch sortBy {
        case .popular:
            sortType = .popular
        case .upcoming:
            sortType = .upcoming
        case .favorites:
            sortType = .favorites
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
            timeFilter: timeFilter,
            sortType: sortType,
            leagueId: leagueId
        )
    }
}