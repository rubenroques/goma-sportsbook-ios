//
//  SportRadarModels+PaymentInformation.swift
//  
//
//  Created by André Lascas on 15/03/2023.
//

import Foundation

extension SportRadarModels {
    struct PaymentInformation: Codable {

        var status: String
        var data: [BankPaymentInfo]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case data = "data"
        }
    }

}
