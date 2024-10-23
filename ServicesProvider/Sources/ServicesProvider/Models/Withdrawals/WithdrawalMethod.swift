//
//  WithdrawalMethod.swift
//  
//
//  Created by André Lascas on 24/02/2023.
//

import Foundation

public struct WithdrawalMethod: Codable {
    public var code: String
    public var paymentMethod: String
    public var minimumWithdrawal: String
    public var maximumWithdrawal: String
    public var conversionRequired: Bool

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case paymentMethod = "paymentMethod"
        case minimumWithdrawal = "minimumWithdrawal"
        case maximumWithdrawal = "maximumWithdrawal"
        case conversionRequired = "conversionRequired"
    }
}
