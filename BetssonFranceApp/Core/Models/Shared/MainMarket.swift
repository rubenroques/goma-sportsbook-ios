//
//  MainMarket.swift
//  Sportsbook
//
//

import Foundation

// MARK: - MainMarket
/// Represents a main market category that groups related betting markets
/// Maps from ServicesProvider.MainMarket but with app-specific control
struct MainMarket: Equatable, Identifiable {
    let id: String
    let bettingTypeId: String
    let bettingTypeName: String
    let eventPartId: String
    let eventPartName: String
    let sportId: String
    let numberOfOutcomes: Int?
    let isLiveMarket: Bool
    let isOutright: Bool

    /// Display name for UI presentation
    var displayName: String {
        return bettingTypeName
    }
}

