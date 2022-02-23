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
        let loss: Limit?

        enum CodingKeys: String, CodingKey {
            case deposit = "deposit"
            case wagering = "wagering"
            case loss = "loss"
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
