//
//  Bonus.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import Foundation

extension EveryMatrix {
    struct ApplicableBonusResponse: Decodable {

        let enableBonusInput: Bool
        let enableBonusSelector: Bool
        let gamingAccountId: Int?
        let bonuses: [ApplicableBonus]?

        enum CodingKeys: String, CodingKey {
            case enableBonusInput = "enableBonusInput"
            case enableBonusSelector = "enableBonusSelector"
            case gamingAccountId = "gamingAccountId"
            case bonuses = "bonuses"
        }

    }

    struct ApplicableBonus: Decodable {

        let code: String
        let name: String
        let description: String
        let url: String
        let html: String
        // let minAmount: CurrencyBonus?

        enum CodingKeys: String, CodingKey {
            case code = "code"
            case name = "name"
            case description = "description"
            case url = "url"
            case html = "html"
            // case minAmount = "minAmount"
        }

    }

    struct CurrencyBonus: Decodable {
        let eur: Double?
        let usd: Double?
        let gbp: Double?

        enum CodingKeys: String, CodingKey {
            case eur = "EUR"
            case usd = "USD"
            case gbp = "GBP"
        }
    }

    // typealias ClaimableBonusResponse = [ApplicableBonus]
    struct ClaimableBonusResponse: Decodable {
        let locallyInjectedKey: [ApplicableBonus]
    }

    struct ClaimableBonus: Decodable {

        let code: String?
        let name: String?

        enum CodingKeys: String, CodingKey {
            case code = "code"
            case name = "name"
        }

    }

    struct GrantedBonusResponse: Decodable {

        let totalRecords: Int?
        let bonuses: [GrantedBonus]?

        enum CodingKeys: String, CodingKey {
            case totalRecords = "totalRecords"
            case bonuses = "bonuses"
        }
    }

    struct GrantedBonus: Decodable {
        let id: String?
        let name: String?
        let status: String
        let type: String?
        let localizedType: String?
        let description: String?
        let vendor: String?
        let currency: String?
        let amount: Double?
        let expiryDate: String?
        let grantedDate: String?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case status = "status"
            case type = "type"
            case localizedType = "localizedType"
            case description = "description"
            case vendor = "vendor"
            case currency = "currency"
            case amount = "amount"
            case expiryDate = "expiryDate"
            case grantedDate = "grantedDate"
        }
    }

    struct ApplyBonusResponse: Decodable {
        
    }
}
