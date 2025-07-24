//
//  SportRadarModels+CancelWithdrawalResponse.swift
//  
//
//  Created by André Lascas on 28/02/2023.
//

import Foundation

extension SportRadarModels {

    struct CancelWithdrawalResponse: Codable {
        var status: String
        var amount: String
        var currency: String

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case amount = "amount"
            case currency = "currency"
        }
    }

}
