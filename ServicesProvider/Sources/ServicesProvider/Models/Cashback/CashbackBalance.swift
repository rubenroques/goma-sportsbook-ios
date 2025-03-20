//
//  CashbackBalance.swift
//  
//
//  Created by André Lascas on 17/07/2023.
//

import Foundation

public struct CashbackBalance: Codable {
    public var status: String
    public var balance: Double?
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case balance = "balance"
        case message = "message"
    }
    
    public init(status: String, balance: Double? = nil, message: String? = nil) {
        self.status = status
        self.balance = balance
        self.message = message
    }
    
}
