//
//  OddsBoostStairs.swift
//  BetssonCameroonApp
//
//  Created by Claude on 16/10/2025.
//

import Foundation

/// App model representing the current odds boost stairs state
/// Maps from ServicesProvider.OddsBoostStairsResponse to app-specific model
struct OddsBoostStairsState: Equatable {

    /// Current tier the user qualifies for
    let currentTier: OddsBoostTier?

    /// Next tier available (nil if max tier reached)
    let nextTier: OddsBoostTier?

    /// Event IDs that are eligible for the bonus
    let eligibleEventIds: [String]

    /// UBS Wallet ID - CRITICAL: Must be passed to bet placement
    let ubsWalletId: String

    /// Currency for this bonus
    let currency: String

    /// All available bonus tiers in the progression
    /// Used to show complete boost ladder to users
    let allTiers: [OddsBoostTier]
}

/// App model representing a single bonus tier/stair
struct OddsBoostTier: Equatable {

    /// Minimum number of selections required for this tier
    let minSelections: Int

    /// Bonus percentage as decimal (0.1 = 10%, 0.15 = 15%)
    let percentage: Double

    /// Maximum bonus amount for user's currency
    let capAmount: Double
}
