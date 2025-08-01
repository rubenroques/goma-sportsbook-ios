//
//  AppliedEventsFilters.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import Foundation

public struct AppliedEventsFilters: Codable {
    var sportId: String
    var timeValue: Float
    var sortTypeId: String
    var leagueId: String
    
    // MARK: - Default Values
    public static let defaultFilters = AppliedEventsFilters(
        sportId: "1",
        timeValue: 0.0,
        sortTypeId: "1",
        leagueId: "all"
    )
}