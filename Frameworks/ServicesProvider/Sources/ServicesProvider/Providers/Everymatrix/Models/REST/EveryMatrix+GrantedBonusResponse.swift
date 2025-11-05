//
//  EveryMatrix+GrantedBonusResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 23/10/2025.
//

import Foundation

extension EveryMatrix {
    
    public struct GrantedBonusResponse: Codable {
        public let total: Int
        public let count: Int
        public let items: [GrantedBonusItem]
        public let pages: Pages
        public let success: Bool
        public let executionTime: Double
        public let requestId: String
        
        enum CodingKeys: String, CodingKey {
            case total
            case count
            case items
            case pages
            case success
            case executionTime
            case requestId
        }
    }
    
    public struct GrantedBonusItem: Codable {
        public let linkedFunds: Double
        public let id: String
        public let bonusId: String
        public let name: String
        public let type: String
        public let localizedType: String
        public let status: String
        public let localizedStatus: String
        public let url: String
        public let description: String
        public let html: String
        public let vendor: String
        public let products: [String]
        public let currency: String
        public let amount: Double?
        public let remainingAmount: Double
        public let initialWagerRequirementCurrency: String
        public let initialWagerRequirementAmount: Double
        public let remainingWagerRequirementCurrency: String
        public let remainingWagerRequirementAmount: Double
        public let grantedDate: String
        public let expiryDate: String
        public let confiscateAllFundsOnExpiration: Bool
        public let confiscateAllFundsOnForfeiture: Bool
        public let ordinal: Double
        public let lockedAmount: Double
        public let bonusWalletID: String
        public let endTime: String
        public let bonusCode: String
        public let assets: String?
        
        enum CodingKeys: String, CodingKey {
            case linkedFunds
            case id
            case bonusId
            case name
            case type
            case localizedType
            case status
            case localizedStatus
            case url
            case description
            case html
            case vendor
            case products
            case currency
            case amount
            case remainingAmount
            case initialWagerRequirementCurrency
            case initialWagerRequirementAmount
            case remainingWagerRequirementCurrency
            case remainingWagerRequirementAmount
            case grantedDate
            case expiryDate
            case confiscateAllFundsOnExpiration
            case confiscateAllFundsOnForfeiture
            case ordinal
            case lockedAmount
            case bonusWalletID
            case endTime
            case bonusCode
            case assets
        }
    }
}

