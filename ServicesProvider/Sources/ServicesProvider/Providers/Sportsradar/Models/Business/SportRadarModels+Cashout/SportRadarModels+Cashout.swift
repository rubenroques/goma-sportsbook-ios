//
//  SportRadarModels+Cashout.swift
//  
//
//  Created by André Lascas on 14/03/2023.
//

import Foundation

extension SportRadarModels {

    struct Cashout: Codable {

        var cashoutValue: Double
        var partialCashoutAvailable: Bool?

        enum CodingKeys: String, CodingKey {
            case cashoutValue = "cashoutValue"
            case partialCashoutAvailable = "partialCashoutAvailable"
        }
    }

}
