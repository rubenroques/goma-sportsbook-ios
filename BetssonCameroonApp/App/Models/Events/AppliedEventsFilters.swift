//
//  AppliedEventsFilters.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import Foundation
import SharedModels

public struct AppliedEventsFilters: Codable, Equatable {
    
    // MARK: - Enums
    
    /// Time filter options
    public enum TimeFilter: Float, Codable, CaseIterable {
        case all = 0
        case oneHour = 1
        case eightHours = 8
        case today = 24
        case fortyEightHours = 48
        
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
    
    /// Sort type options
    public enum SortType: String, Codable, CaseIterable {
        case popular = "1"
        case upcoming = "2"
        case favorites = "3"
        
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
    
    // MARK: - Properties

    var sportId: FilterIdentifier
    var timeFilter: TimeFilter
    var sortType: SortType
    var leagueFilter: LeagueFilterIdentifier
    
    // MARK: - Coding Keys for backward compatibility
    
    private enum CodingKeys: String, CodingKey {
        case sportId
        case timeValue  // Keep old key for backward compatibility
        case sortTypeId // Keep old key for backward compatibility
        case leagueId
    }
    
    // MARK: - Codable Implementation
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode sportId as String and convert to FilterIdentifier
        let sportIdString = try container.decode(String.self, forKey: .sportId)
        sportId = FilterIdentifier(stringValue: sportIdString)

        // Decode leagueId as String and convert to LeagueFilterIdentifier
        let leagueIdString = try container.decode(String.self, forKey: .leagueId)
        leagueFilter = LeagueFilterIdentifier(stringValue: leagueIdString)

        // Decode timeValue as Float and convert to enum
        let timeValue = try container.decode(Float.self, forKey: .timeValue)
        timeFilter = TimeFilter(rawValue: timeValue) ?? .all

        // Decode sortTypeId as String and convert to enum
        let sortTypeId = try container.decode(String.self, forKey: .sortTypeId)
        sortType = SortType(rawValue: sortTypeId) ?? .popular
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode FilterIdentifier as raw string value
        try container.encode(sportId.rawValue, forKey: .sportId)

        // Encode LeagueFilterIdentifier as raw string value
        try container.encode(leagueFilter.rawValue, forKey: .leagueId)

        // Encode enum as raw value for backward compatibility
        try container.encode(timeFilter.rawValue, forKey: .timeValue)
        try container.encode(sortType.rawValue, forKey: .sortTypeId)
    }
    
    // MARK: - Initializer

    public init(
        sportId: FilterIdentifier,
        timeFilter: TimeFilter,
        sortType: SortType,
        leagueFilter: LeagueFilterIdentifier
    ) {
        self.sportId = sportId
        self.timeFilter = timeFilter
        self.sortType = sortType
        self.leagueFilter = leagueFilter
    }
    
    // MARK: - Default Values

    public static let defaultFilters = AppliedEventsFilters(
        sportId: .singleSport(id: "1"),
        timeFilter: .all,
        sortType: .popular,
        leagueFilter: .all
    )
}