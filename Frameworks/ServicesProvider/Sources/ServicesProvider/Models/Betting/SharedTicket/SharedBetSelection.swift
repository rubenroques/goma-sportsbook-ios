//
//  SharedBetSelection.swift
//  
//
//  Created by André Lascas on 21/04/2023.
//

import Foundation

public struct SharedBetSelection: Codable {

    public var id: Double
    public var priceDenominator: Int
    public var priceNumerator: Int
    public var priceType: String

    public var odd: Double {
        let priceNumerator = Double(self.priceNumerator)
        let priceDenominator = Double(self.priceDenominator)
        return (priceNumerator/priceDenominator) + 1.0
    }

    enum CodingKeys: String, CodingKey {
        case id = "idFOSelection"
        case priceDenominator = "priceDown"
        case priceNumerator = "priceUp"
        case priceType = "idFOPriceType"
    }
}
