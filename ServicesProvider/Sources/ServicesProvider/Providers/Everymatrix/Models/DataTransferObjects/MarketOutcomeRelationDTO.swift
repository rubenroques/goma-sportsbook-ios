//
//  MarketOutcomeRelationDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MarketOutcomeRelationDTO: Entity {
        let id: String
        static let rawType: String = "MARKET_OUTCOME_RELATION"
        let marketId: String
        let outcomeId: String
    }
}