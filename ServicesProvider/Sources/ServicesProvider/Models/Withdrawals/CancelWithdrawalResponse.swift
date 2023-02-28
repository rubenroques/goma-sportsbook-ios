//
//  CancelWithdrawalResponse.swift
//  
//
//  Created by André Lascas on 28/02/2023.
//

import Foundation

public struct CancelWithdrawalResponse: Codable {
    public var status: String
    public var amount: String
    public var currency: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case amount = "amount"
        case currency = "currency"
    }
}
