//
//  EveryMatrix+PlaceBet.swift
//  ServicesProvider
//
//  Created on 30/09/2025.
//

import Foundation

extension EveryMatrix {

    // MARK: - Place Bet Request Models

    struct PlaceBetRequest: Codable {
        let ucsOperatorId: Int
        let userId: String
        let username: String
        let currency: String
        let type: String
        // let systemBetType: String?  // V3 field - not in V2
        // let eachWay: Bool            // V3 field - not in V2
        let selections: [BetSelectionInfo]
        let amount: String              // API expects String, not Double
        let oddsValidationType: String
        let terminalType: String
        // let lang: String             // V3 field - not in V2
        let ubsWalletId: String?
        let freeBet: String?

        init(ucsOperatorId: Int, userId: String, username: String, currency: String, type: String, selections: [BetSelectionInfo], amount: String, oddsValidationType: String, terminalType: String, ubsWalletId: String? = nil, freeBet: String? = nil) {
            self.ucsOperatorId = ucsOperatorId
            self.userId = userId
            self.username = username
            self.currency = currency
            self.type = type
            self.selections = selections
            self.amount = amount
            self.oddsValidationType = oddsValidationType
            self.terminalType = terminalType
            self.ubsWalletId = ubsWalletId
            self.freeBet = freeBet
        }
    }

    struct BetSelectionInfo: Codable {
        let bettingOfferId: Int
        let priceValue: Double
        let outcomeId: Int?
        let bettingTypeId: Int?
        let marketIDs: [Int]
        let betBuilderPriceValue: Double?
        let banker: Bool

        init(bettingOfferId: Int,
             priceValue: Double,
             outcomeId: Int?,
             bettingTypeId: Int?,
             marketIDs: [Int],
             betBuilderPriceValue: Double?,
             banker: Bool) {
            self.bettingOfferId = bettingOfferId
            self.priceValue = priceValue
            self.outcomeId = outcomeId
            self.bettingTypeId = bettingTypeId
            self.marketIDs = marketIDs
            self.betBuilderPriceValue = betBuilderPriceValue
            self.banker = banker
        }

        // Custom encoding to skip optional fields when nil
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(bettingOfferId, forKey: .bettingOfferId)
            try container.encode(priceValue, forKey: .priceValue)
            try container.encodeIfPresent(outcomeId, forKey: .outcomeId)
            try container.encodeIfPresent(bettingTypeId, forKey: .bettingTypeId)
            try container.encode(marketIDs, forKey: .marketIDs)
            try container.encodeIfPresent(betBuilderPriceValue, forKey: .betBuilderPriceValue)
            try container.encode(banker, forKey: .banker)
        }

        enum CodingKeys: String, CodingKey {
            case bettingOfferId
            case priceValue
            case outcomeId
            case bettingTypeId
            case marketIDs
            case betBuilderPriceValue
            case banker
        }
    }

    // MARK: - Place Bet Response Models

    struct PlaceBetResponse: Codable {
        let betId: String?
        let potentialReturn: Double?
        let status: String?
        let message: String?

        enum CodingKeys: String, CodingKey {
            case betId = "betId"
            case potentialReturn = "potentialReturn"
            case status = "status"
            case message = "message"
        }
    }
}


