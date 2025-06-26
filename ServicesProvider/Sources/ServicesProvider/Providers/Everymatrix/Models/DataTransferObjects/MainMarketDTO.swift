//
//  MainMarketDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MainMarketDTO: Entity {
        let id: String
        static let rawType: String = "MAIN_MARKET"
        let bettingTypeId: String
        let eventPartId: String
        let sportId: String
        let bettingTypeName: String
        let eventPartName: String
        let numberOfOutcomes: Int?
        let liveMarket: Bool
        let outright: Bool
    }
}