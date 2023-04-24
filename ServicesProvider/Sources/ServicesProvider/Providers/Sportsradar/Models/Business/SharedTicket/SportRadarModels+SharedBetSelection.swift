//
//  SportRadarModels+SharedBetSelection.swift
//  
//
//  Created by André Lascas on 21/04/2023.
//

import Foundation

extension SportRadarModels {

    struct SharedBetSelection: Codable {

        var id: Double
        var priceDenominator: Int
        var priceNumerator: Int
        var priceType: String

        enum CodingKeys: String, CodingKey {
            case id = "idFOSelection"
            case priceDenominator = "priceDown"
            case priceNumerator = "priceUp"
            case priceType = "idFOPriceType"
        }
    }

}
