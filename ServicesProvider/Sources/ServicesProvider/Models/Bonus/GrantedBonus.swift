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
    public var triggerDate: Date?
    public var expiryDate: Date?
    public var wagerRequirement: String?
    public var amountWagered: String?
    public var freeBetBonus: FreeBetBonus?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "bonusPlanName"
        case status = "status"
        case amount = "amount"
        case triggerDate = "triggerDate"
        case expiryDate = "expiryDate"
        case wagerRequirement = "wagerRequirement"
        case amountWagered = "amountWagered"
        case freeBetBonus = "externalFreeBet"
    }
    
    init(id: Int,
         name: String,
         status: String,
         amount: String,
         triggerDate: Date?,
         expiryDate: Date?,
         wagerRequirement: String? = nil,
         amountWagered: String? = nil,
         freeBetBonus: FreeBetBonus? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.amount = amount
        self.triggerDate = triggerDate
        self.expiryDate = expiryDate
        self.wagerRequirement = wagerRequirement
        self.amountWagered = amountWagered
        self.freeBetBonus = freeBetBonus
    }
}

public struct FreeBetBonus: Codable {
    public var productCode: String
    public var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case productCode = "productCode"
        case amount = "amount"
    }
}

