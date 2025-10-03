//
//  MarketIdentifier.swift
//  ServicesProvider
//
//  Created on 2025-09-30.
//

import Foundation

/// Identifies a market across different providers
/// Each provider has its own way of identifying markets
public enum MarketIdentifier: Hashable {
    /// Goma provider uses direct market IDs
    case marketId(String)

    /// EveryMatrix uses event part ID + betting type ID combination
    /// Example: eventPartId: "3", bettingTypeId: "69" -> subscribes to "69-3"
    case everyMatrixMarket(eventPartId: String, bettingTypeId: String)
}
