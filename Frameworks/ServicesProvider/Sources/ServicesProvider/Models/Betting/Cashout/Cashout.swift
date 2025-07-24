//
//  Cashout.swift
//  
//
//  Created by André Lascas on 14/03/2023.
//

import Foundation

public struct Cashout: Codable {

    public var cashoutValue: Double
    public var partialCashoutAvailable: Bool?

    enum CodingKeys: String, CodingKey {
        case cashoutValue = "cashoutValue"
        case partialCashoutAvailable = "partialCashoutAvailable"
    }
}
