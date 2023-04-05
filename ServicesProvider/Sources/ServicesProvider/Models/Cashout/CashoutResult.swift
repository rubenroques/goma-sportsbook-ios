//
//  File.swift
//  
//
//  Created by André Lascas on 14/03/2023.
//

import Foundation

public struct CashoutResult: Codable {
    public var cashoutResult: Int?
    public var cashoutReoffer: Double?
    public var message: String?

    enum CodingKeys: String, CodingKey {
        case cashoutResult = "cashoutResult"
        case cashoutReoffer = "cashoutReoffer"
        case message = "message"
    }
}
