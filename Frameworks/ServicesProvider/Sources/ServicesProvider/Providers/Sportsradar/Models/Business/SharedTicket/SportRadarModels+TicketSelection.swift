//
//  SportRadarModels+TicketSelection.swift
//  
//
//  Created by André Lascas on 24/04/2023.
//

import Foundation

extension SportRadarModels {

    struct TicketSelection: Codable {

        var id: String
        var marketId: String
        var name: String
        var priceDenominator: String
        var priceNumerator: String

        var odd: Double {
            let priceNumerator = Double(self.priceNumerator) ?? 0.0
            let priceDenominator = Double(self.priceDenominator) ?? 0.0
            return (priceNumerator/priceDenominator) + 1.0
        }

        enum CodingKeys: String, CodingKey {
            case id = "idfoselection"
            case marketId = "idfomarket"
            case name = "name"
            case priceDenominator = "currentpricedown"
            case priceNumerator = "currentpriceup"
        }
    }

}
