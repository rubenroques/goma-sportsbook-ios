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
        let type: String
        let systemBetType: String?
        let eachWay: Bool
        let selections: [BetSelectionInfo]
        let stakeAmount: Double
        let terminalType: String
        let lang: String

        init(type: String, systemBetType: String? = nil, eachWay: Bool = false, selections: [BetSelectionInfo], stakeAmount: Double, terminalType: String, lang: String) {
            self.type = type
            self.systemBetType = systemBetType
            self.eachWay = eachWay
            self.selections = selections
            self.stakeAmount = stakeAmount
            self.terminalType = terminalType
            self.lang = lang
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
