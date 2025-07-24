//
//  MarketGroup.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

struct MarketGroup: Equatable {
    let id: String
    let type: String
    let groupKey: String?
    let translatedName: String?
    let isDefault: Bool?
    let markets: [Market]?
    let position: Int?
    
    // Additional properties for full EveryMatrix support
    let numberOfMarkets: Int?
    let loaded: Bool
    let isBetBuilder: Bool?
    let isFast: Bool?
    let isOutright: Bool?
    
    // Initializer with defaults for retro-compatibility
    init(id: String,
         type: String,
         groupKey: String? = nil,
         translatedName: String? = nil,
         isDefault: Bool? = nil,
         markets: [Market]? = nil,
         position: Int? = nil,
         numberOfMarkets: Int? = nil,
         loaded: Bool = true,
         isBetBuilder: Bool? = nil,
         isFast: Bool? = nil,
         isOutright: Bool? = nil) {
        self.id = id
        self.type = type
        self.groupKey = groupKey
        self.translatedName = translatedName
        self.isDefault = isDefault
        self.markets = markets
        self.position = position
        self.numberOfMarkets = numberOfMarkets
        self.loaded = loaded
        self.isBetBuilder = isBetBuilder
        self.isFast = isFast
        self.isOutright = isOutright
    }
}
