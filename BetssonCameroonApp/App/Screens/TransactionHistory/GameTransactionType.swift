//
//  GameTransactionType.swift
//  BetssonCameroonApp
//
//  Created by Game Type Sub-Filter Feature on 30/09/2025.
//

import Foundation

/// Represents the type of game transaction for level 1 filtering
/// Matches web implementation: level1Tabs under "games" category
enum GameTransactionType: String, CaseIterable {
    case all = "all"
    case sportsbook = "sportsbook"  // gameId == "OddsMatrix2"
    case casino = "casino"           // gameId != "OddsMatrix2"

    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .sportsbook:
            return "Sportsbook"
        case .casino:
            return "Casino"
        }
    }

    /// Check if a gameId matches this game type
    func matches(gameId: String?) -> Bool {
        switch self {
        case .all:
            return true
        case .sportsbook:
            return gameId == "OddsMatrix2"
        case .casino:
            return gameId != "OddsMatrix2" && gameId != nil
        }
    }
}