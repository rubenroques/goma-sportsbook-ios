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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(String.self, forKey: .status)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)

        if let balanceDouble = try container.decodeIfPresent(Double.self, forKey: .balance) {
            self.balance = balanceDouble
        }
        else if let balanceString = try container.decodeIfPresent(String.self, forKey: .balance) {
            self.balance = Double(balanceString)
        }
        else {
            self.balance = nil
        }
    }

}
