//
//  SportRadarModels+CashbackBalance.swift
//  
//
//  Created by André Lascas on 17/07/2023.
//

import Foundation

extension SportRadarModels {

    struct CashbackBalance: Codable {
        var status: String
        var balance: String?
        var message: String?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case balance = "balance"
            case message = "message"
        }
    }

}
