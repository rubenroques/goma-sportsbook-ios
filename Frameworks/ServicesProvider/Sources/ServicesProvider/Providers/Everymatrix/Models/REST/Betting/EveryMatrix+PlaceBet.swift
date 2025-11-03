//
//  EveryMatrix+PlaceBet.swift
//  ServicesProvider
//
//  Created by Assistant on 30/09/2025.
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
        let bettingOfferId: String
        let priceValue: Double

        init(bettingOfferId: String, priceValue: Double) {
            self.bettingOfferId = bettingOfferId
            self.priceValue = priceValue
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


