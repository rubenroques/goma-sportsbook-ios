//
//  SportRadarModels+CashbackResult.swift
//  
//
//  Created by André Lascas on 18/07/2023.
//

import Foundation

extension SportRadarModels {

    struct CashbackResult: Codable {
        var id: Double
        var amount: Double

        enum CodingKeys: String, CodingKey {
            case id = "idFoSOOffer"
            case amount = "soReturn"
        }
    }
}
