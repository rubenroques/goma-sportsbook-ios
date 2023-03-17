//
//  File.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

public struct RedeemBonus: Codable {
    public var id: Int
    public var name: String
    public var status: String
    public var triggerDate: String
    public var expiryDate: String
    public var amount: String
    public var wagerRequired: String
    public var amountWagered: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "bonusPlanName"
        case status = "status"
        case triggerDate = "triggerDate"
        case expiryDate = "expiryDate"
        case amount = "amount"
        case wagerRequired = "wagerRequirement"
        case amountWagered = "amountWagered"
    }
}
