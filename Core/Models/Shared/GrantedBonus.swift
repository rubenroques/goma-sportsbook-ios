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
    let expiryDate: String?
    let grantedDate: String?
    let initialWagerRequirementAmount: Double?
    let remainingWagerRequirementAmount: Double?

    init(id: String, name: String, status: String, type: String? = nil, localizedType: String? = nil, description: String? = nil,
         vendor: String? = nil, currency: String? = nil, amount: Double? = nil,
         remainingAmount: Double? = nil, expiryDate: String? = nil, grantedDate: String? = nil,
         initialWagerRequirementAmount: Double? = nil, remainingWagerRequirementAmount: Double? = nil) {
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
    }
}
