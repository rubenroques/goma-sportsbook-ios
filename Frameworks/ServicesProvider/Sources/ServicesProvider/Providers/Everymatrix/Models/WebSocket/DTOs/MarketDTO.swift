//
//  MarketDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MarketDTO: Entity, EntityContainer {
        let id: String
        static let rawType: String = "MARKET"
        let name: String
        let shortName: String
        let displayKey: String
        let displayName: String
        let displayShortName: String
        let eventId: String
        let eventPartId: String
        let bettingTypeId: String
        let numberOfOutcomes: Int?
        let scoringUnitId: String?
        let isComplete: Bool
        let isClosed: Bool
        let paramFloat1: Double?
        let paramFloat2: Double?
        let paramFloat3: Double?
        let bettingTypeName: String
        let shortBettingTypeName: String
        let eventPartName: String
        let mainLine: Bool
        let isAvailable: Bool
        let notAvailableSince: Int64?
        let shortEventPartName: String
        let scoringUnitName: String?
        let asianLine: Bool?
        let labelName: String?
        let labelStyle: String?
        let allowEachWay: Bool
        let allowStartingPrice: Bool

        func getReferencedIds() -> [String: [String]] {
            return [
                "Match": [eventId]
            ]
        }
    }
}