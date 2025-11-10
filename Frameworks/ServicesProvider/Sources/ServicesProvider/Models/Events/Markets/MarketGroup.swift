//
//  MarketGroup.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct MarketGroup {

    public var type: String
    public var id: String
    public var groupKey: String?
    public var translatedName: String?
    public var position: Int?
    public var isDefault: Bool?
    public var numberOfMarkets: Int?
    public var loaded: Bool
    public var markets: [Market]?

    // Additional EveryMatrix new properties
    public var isBetBuilder: Bool?
    public var isFast: Bool?
    public var isOutright: Bool?
}
