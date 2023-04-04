//
//  SportRadarModels+PendingWithdrawal.swift
//  
//
//  Created by André Lascas on 28/02/2023.
//

import Foundation

extension SportRadarModels {

    struct PendingWithdrawal: Codable {

        var status: String
        var paymentId: Int
        var amount: String

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case paymentId = "paymentId"
            case amount = "amount"
        }
    }

}
