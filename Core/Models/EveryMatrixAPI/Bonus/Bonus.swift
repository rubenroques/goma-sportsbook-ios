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

        let code: String?
        let name: String?
        let description: String?
        let url: String?
        let html: String?
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

    struct ClaimableBonusResponse: Decodable {
        let bonuses: [ClaimableBonus]

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            bonuses = try container.decode([ClaimableBonus].self)
        }
    }

    struct ClaimableBonus: Decodable {

        let code: String?
        let name: String?

        enum CodingKeys: String, CodingKey {
            case code = "code"
            case name = "name"
        }

    }
}
