//
//  AppliedEventsFilters+MatchesFilterOptions.swift
//  Sportsbook
//

import Foundation
import ServicesProvider
import SharedModels

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
        }
        
        // Convert leagueFilter to TournamentFilter and LocationFilter
        let (location, tournament): (LocationFilter, TournamentFilter)
        switch leagueFilter {
        case .all:
            location = .all
            tournament = .all
        case .allInCountry(let countryId):
            location = .specific(countryId)
            tournament = .all
        case .singleLeague(let id):
            location = .all
            tournament = .specific(id)
        }

        let filterOptions = MatchesFilterOptions(
            sportId: sportId.rawValue,
            timeRange: timeRange,
            sortBy: sortBy,
            location: location,
            tournament: tournament,
            optionalUserId: optionalUserId
        )

        print("[FILTER_DEBUG] toMatchesFilterOptions - sportId: \(filterOptions.sportId), " +
              "timeRange: \(filterOptions.timeRange.serverRawValue), sortBy: \(filterOptions.sortBy.serverRawValue), " +
              "location: \(filterOptions.location.serverRawValue), tournament: \(filterOptions.tournament.serverRawValue)")

        return filterOptions
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
            // Favorites not supported in BetssonCameroonApp, fallback to popular
            sortType = .popular
        }
        
        // Convert LocationFilter + TournamentFilter to LeagueFilterIdentifier
        let leagueFilter: LeagueFilterIdentifier
        switch (location, tournament) {
        case (.all, .all):
            leagueFilter = .all
        case (.specific(let countryId), .all):
            leagueFilter = .allInCountry(countryId: countryId)
        case (.all, .specific(let leagueId)):
            leagueFilter = .singleLeague(id: leagueId)
        case (.specific, .specific(let leagueId)):
            leagueFilter = .singleLeague(id: leagueId)
        }

        return AppliedEventsFilters(
            sportId: FilterIdentifier(stringValue: sportId),
            timeFilter: timeFilter,
            sortType: sortType,
            leagueFilter: leagueFilter
        )
    }
}