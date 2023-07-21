//
//  CashbackBalance.swift
//  
//
//  Created by André Lascas on 17/07/2023.
//

import Foundation

public struct CashbackBalance: Codable {
    public var status: String
    public var balance: String?
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case balance = "balance"
        case message = "message"
    }
}
