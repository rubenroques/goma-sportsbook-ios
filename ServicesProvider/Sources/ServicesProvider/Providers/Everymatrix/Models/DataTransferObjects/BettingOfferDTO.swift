//
//  BettingOfferDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct BettingOfferDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "BETTING_OFFER"
        let providerId: String
        let outcomeId: String
        let bettingTypeId: String
        let statusId: String
        let isLive: Bool
        let odds: Double
        let lastChangedTime: Int64
        let bettingTypeName: String
        let shortBettingTypeName: String
        let isAvailable: Bool

        func getReferencedIds() -> [String: [String]] {
            return [
                "Outcome": [outcomeId]
            ]
        }

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<EveryMatrix.BettingOfferDTO.CodingKeys> = try decoder.container(keyedBy: EveryMatrix.BettingOfferDTO.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.id)
            self.providerId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.providerId)
            self.outcomeId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.outcomeId)
            self.bettingTypeId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.bettingTypeId)
            self.statusId = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.statusId)
            self.isLive = try container.decode(Bool.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.isLive)
            self.odds = try container.decode(Double.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.odds)
            self.lastChangedTime = try container.decode(Int64.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.lastChangedTime)
            self.bettingTypeName = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.bettingTypeName)
            self.shortBettingTypeName = try container.decode(String.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.shortBettingTypeName)
            self.isAvailable = try container.decode(Bool.self, forKey: EveryMatrix.BettingOfferDTO.CodingKeys.isAvailable)
        }
    }
}