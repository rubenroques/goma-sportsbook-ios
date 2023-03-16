//
//  BankPaymentDetail.swift
//  
//
//  Created by André Lascas on 15/03/2023.
//

import Foundation

public struct BankPaymentDetail: Codable {

    public var id: Int
    public var paymentInfoId: Int
    public var key: String
    public var value: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case paymentInfoId = "paymentInformationId"
        case key = "key"
        case value = "value"
    }
}
