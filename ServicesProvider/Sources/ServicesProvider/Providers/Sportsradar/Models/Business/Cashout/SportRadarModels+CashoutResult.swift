//
//  SportRadarModels+CashoutResult.swift
//  
//
//  Created by André Lascas on 14/03/2023.
//

import Foundation

extension SportRadarModels {

    struct CashoutResult: Codable {
        var cashoutResult: Int?
        var cashoutReoffer: Double?

        enum CodingKeys: String, CodingKey {
            case cashoutResult = "cashoutResult"
            case cashoutReoffer = "cashoutReoffer"
        }
    }
    
}
