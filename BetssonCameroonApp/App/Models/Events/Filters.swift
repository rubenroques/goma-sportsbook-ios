//
//  Filters.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

public struct FilterConfiguration: Codable {
    let widgets: [FilterWidget]
    let filtersByContext: [FilterContext]
}

public struct FilterWidget: Codable {
    let id: String
    let type: FilterWidgetType
    let label: String
    let icon: String?
    let details: FilterDetails
}

public enum FilterWidgetType: String, Codable {
    case sportsFilter = "gridFilter"
    case timeFilter = "timeFilter"
    case radioFilterBasic = "radioFilterBasic"
    case radioFilterAccordion = "radioFilterAccordion"
}

public struct FilterDetails: Codable {
    let isExpandable: Bool
    let expandedByDefault: Bool
    let options: [FilterOption]?
}

public struct FilterOption: Codable {
    let id: String
    let label: String
    let value: String
}

public struct FilterContext: Codable {
    let id: String
    let widgets: [String] // Array of widget IDs
}
