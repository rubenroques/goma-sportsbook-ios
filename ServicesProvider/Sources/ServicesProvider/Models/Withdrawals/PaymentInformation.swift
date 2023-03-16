//
//  PaymentInformation.swift
//  
//
//  Created by André Lascas on 15/03/2023.
//

import Foundation

public struct PaymentInformation: Codable {

    public var status: String
    public var data: [BankPaymentInfo]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }
}
