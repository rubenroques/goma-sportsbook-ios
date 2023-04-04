//
//  SportRadarModels+WithdrawalMethod.swift
//  
//
//  Created by André Lascas on 27/02/2023.
//

import Foundation

extension SportRadarModels {

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
