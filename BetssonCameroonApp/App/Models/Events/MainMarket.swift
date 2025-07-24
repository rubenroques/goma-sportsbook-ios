//
//  MainMarket.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

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

