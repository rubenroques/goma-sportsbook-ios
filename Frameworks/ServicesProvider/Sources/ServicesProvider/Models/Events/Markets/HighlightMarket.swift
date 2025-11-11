//
//  HighlightMarket.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public class HighlightMarket: Codable, Equatable {
    public var id: String {
        return market.id
    }
    public var market: Market
    public var enabledSelectionsCount: Int
    public var promotionImageURl: String?

    public init(market: Market, enabledSelectionsCount: Int, promotionImageURl: String?) {
        self.market = market
        self.enabledSelectionsCount = enabledSelectionsCount
        self.promotionImageURl = promotionImageURl
    }

    public static func == (lhs: HighlightMarket, rhs: HighlightMarket) -> Bool {
        // Compare all properties for equality
        return lhs.market == rhs.market &&
        lhs.enabledSelectionsCount == rhs.enabledSelectionsCount
    }
}
