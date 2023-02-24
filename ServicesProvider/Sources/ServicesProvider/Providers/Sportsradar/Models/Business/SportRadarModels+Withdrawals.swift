//
//  SportRadarModels+Withdrawals.swift
//  
//
//  Created by André Lascas on 24/02/2023.
//

import Foundation

extension SportRadarModels {

    struct WithdrawalMethodsResponse: Codable {

        var status: String
        var withdrawalMethods: [WithdrawalMethod]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case withdrawalMethods = "withdrawalMethods"
        }
    }

    struct WithdrawalMethod: Codable {
        var code: String
        var paymentMethod: String
        var minimumWithdrawal: String
        var maximumWithdrawal: String

        enum CodingKeys: String, CodingKey {
            case code = "code"
            case paymentMethod = "paymentMethod"
            case minimumWithdrawal = "minimumWithdrawal"
            case maximumWithdrawal = "maximumWithdrawal"
        }
    }
}
