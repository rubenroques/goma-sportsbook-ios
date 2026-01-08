//
//  GrantedBonus.swift
//  Sportsbook
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation

struct GrantedBonus: Codable {
    let id: String
    let name: String
    let status: String
    let type: String?
    let localizedType: String?
    let description: String?
    let vendor: String?
    let currency: String?
    let amount: Double?
    let remainingAmount: Double?
    let expiryDate: Date?
    let grantedDate: Date?
    let initialWagerRequirementAmount: Double?
    let remainingWagerRequirementAmount: Double?
    let freeBetBonus: FreeBetBonus?

    init(id: String,
         name: String,
         status: String,
         type: String? = nil,
         localizedType: String? = nil,
         description: String? = nil,
         vendor: String? = nil,
         currency: String? = nil,
         amount: Double? = nil,
         remainingAmount: Double? = nil,
         expiryDate: Date? = nil,
         grantedDate: Date? = nil,
         initialWagerRequirementAmount: Double? = nil,
         remainingWagerRequirementAmount: Double? = nil,
         freeBetBonus: FreeBetBonus? = nil)
    {
        self.id = id
        self.name = name
        self.status = status
        self.type = type
        self.localizedType = localizedType
        self.description = description
        self.vendor = vendor
        self.currency = currency
        self.amount = amount
        self.remainingAmount = remainingAmount
        self.expiryDate = expiryDate
        self.grantedDate = grantedDate
        self.initialWagerRequirementAmount = initialWagerRequirementAmount
        self.remainingWagerRequirementAmount = remainingWagerRequirementAmount
        self.freeBetBonus = freeBetBonus
    }
}

struct FreeBetBonus: Codable {
    var productCode: String
    var amount: Double
    
    enum CodingKeys: String, CodingKey {
        case productCode = "productCode"
        case amount = "amount"
    }
}
