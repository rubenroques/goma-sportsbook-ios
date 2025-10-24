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
    public var type: String?
    public var amount: String
    public var remainingAmount: String?
    public var triggerDate: Date?
    public var expiryDate: Date?
    public var wagerRequirement: String?
    public var amountWagered: String?
    public var currency: String?
    public var imageUrl: String?
    public var linkUrl: String?

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
    
    public init(
        id: Int,
        name: String,
        status: String,
        type: String? = nil,
        amount: String,
        remainingAmount: String? = nil,
        triggerDate: Date?,
        expiryDate: Date?,
        wagerRequirement: String? = nil,
        amountWagered: String? = nil,
        currency: String? = nil,
        imageUrl: String? = nil,
        linkUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.type = type
        self.amount = amount
        self.remainingAmount = remainingAmount
        self.triggerDate = triggerDate
        self.expiryDate = expiryDate
        self.wagerRequirement = wagerRequirement
        self.amountWagered = amountWagered
        self.currency = currency
        self.imageUrl = imageUrl
        self.linkUrl = linkUrl
    }
}

