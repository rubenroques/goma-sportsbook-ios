//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 22/02/2022.
//

import Foundation

extension EveryMatrix {
    struct LimitsResponse: Decodable {

        let deposit: Limit?
        let wagering: Limit?
        let wageringPerDay: Limit?
        let wageringPerWeek: Limit?
        let wageringPerMonth: Limit?
        let loss: Limit?
        let lossPerDay: Limit?
        let lossPerWeek: Limit?
        let lossPerMonth: Limit?

        enum CodingKeys: String, CodingKey {
            case deposit = "deposit"
            case wagering = "wagering"
            case wageringPerDay = "wageringPerDay"
            case wageringPerWeek = "wageringPerWeek"
            case wageringPerMonth = "wageringPerMonth"
            case loss = "loss"
            case lossPerDay = "lossPerDay"
            case lossPerWeek = "lossPerWeek"
            case lossPerMonth = "lossPerMonth"
        }
        
    }

    struct Limit: Decodable {

        let updatable: Bool
        let current: LimitInfo?
        let queued: LimitInfo?

        enum CodingKeys: String, CodingKey {
            case updatable = "updatable"
            case current = "current"
            case queued = "queued"
        }
    }

    struct LimitInfo: Decodable {
        let period: String
        let currency: String
        let amount: Double
        let expiryDate: String?

        enum CodingKeys: String, CodingKey {
            case period = "period"
            case currency = "currency"
            case amount = "amount"
            case expiryDate = "expiryDate"
        }
    }

    struct LimitSetResponse: Decodable {
        
    }

}
