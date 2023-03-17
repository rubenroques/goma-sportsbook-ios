//
//  File.swift
//  
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

public struct GrantedBonus: Codable {
    public var id: Int
    public var name: String
    public var status: String
    public var amount: String
    public var triggerDate: String
    public var expiryDate: String
    public var wagerRequirement: String?
    public var amountWagered: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "bonusPlanName"
        case status = "status"
        case amount = "amount"
        case triggerDate = "triggerDate"
        case expiryDate = "expiryDate"
        case wagerRequirement = "wagerRequirement"
        case amountWagered = "amountWagered"
    }
}

