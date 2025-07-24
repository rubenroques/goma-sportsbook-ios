//
//  SportRadarModels+BankPaymentDetail.swift
//  
//
//  Created by André Lascas on 15/03/2023.
//

import Foundation

extension SportRadarModels {
    struct BankPaymentDetail: Codable {

        var id: Int
        var paymentInfoId: Int
        var key: String
        var value: String

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case paymentInfoId = "paymentInformationId"
            case key = "key"
            case value = "value"
        }
    }
}
