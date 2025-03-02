//
//  PendingWithdrawal.swift
//  
//
//  Created by André Lascas on 28/02/2023.
//

import Foundation

public struct PendingWithdrawal: Codable {

    public var status: String
    public var paymentId: Int
    public var amount: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case paymentId = "paymentId"
        case amount = "amount"
    }
}
