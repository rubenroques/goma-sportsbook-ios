//
//  BetslipConfiguration.swift
//  BetssonCameroonApp
//
//  Created on 13/10/2025.
//

import Foundation

// MARK: - BetslipConfiguration
struct BetslipConfiguration: Codable {
    let config: BetslipConfigMetadata
    let settings: [BetslipSetting]
    let tabs: [BetslipTab]
    
    /// Check if virtual betslip is enabled
    var hasVirtualBetslip: Bool {
        return tabs.contains { $0.id == "virtuals-betslip" }
    }
    
    /// Check if sports betslip is enabled
    var hasSportsBetslip: Bool {
        return tabs.contains { $0.id == "sports-betslip" }
    }
    
    /// Returns true if we should show the type selector (when we have both sports and virtual)
    var shouldShowTypeSelector: Bool {
        return hasSportsBetslip && hasVirtualBetslip
    }
}

// MARK: - BetslipConfigMetadata
struct BetslipConfigMetadata: Codable {
    let name: String
    let version: String
    let defaultLanguage: String
    let id: String
}

// MARK: - BetslipSetting
struct BetslipSetting: Codable {
    let id: String
    let label: String
    let value: String
    let `default`: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case value
        case `default` = "default"
    }
}

// MARK: - BetslipTab
struct BetslipTab: Codable {
    let id: String
    let label: String
    let component: String
    let icon: String
    let `default`: Bool
    let betslipId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case component
        case icon
        case `default` = "default"
        case betslipId
    }
}

