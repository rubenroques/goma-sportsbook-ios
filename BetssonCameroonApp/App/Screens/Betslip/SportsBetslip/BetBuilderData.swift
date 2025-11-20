//
//  BetBuilderData.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 04/11/2025.
//

import Foundation

/// Stores bet builder information including total odds and associated betting offer IDs
public struct BetBuilderData: Equatable {
    public let totalOdds: Double
    public let bettingOfferIds: [String]
    
    public init(totalOdds: Double, bettingOfferIds: [String]) {
        self.totalOdds = totalOdds
        self.bettingOfferIds = bettingOfferIds
    }
}





