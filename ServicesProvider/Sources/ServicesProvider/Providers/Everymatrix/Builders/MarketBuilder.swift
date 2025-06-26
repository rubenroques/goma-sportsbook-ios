//
//  MarketBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MarketBuilder: HierarchicalBuilder {
        typealias FlatType = MarketDTO
        typealias OutputType = Market

        static func build(from market: MarketDTO, store: EntityStore) -> Market? {
            // Get outcomes for this market
            let allOutcomes = store.getAll(OutcomeDTO.self)
            let allRelations = store.getAll(MarketOutcomeRelationDTO.self)

            // Find outcomes related to this market
            let relatedOutcomeIds = allRelations
                .filter { $0.marketId == market.id }
                .map { $0.outcomeId }

            let marketOutcomes = allOutcomes.filter { relatedOutcomeIds.contains($0.id) }

            // Build hierarchical outcomes
            let hierarchicalOutcomes = marketOutcomes.compactMap { outcome in
                OutcomeBuilder.build(from: outcome, store: store)
            }

            return Market(
                id: market.id,
                name: market.name,
                shortName: market.shortName,
                displayName: market.displayName,
                bettingType: Market.BettingType(
                    id: market.bettingTypeId,
                    name: market.bettingTypeName,
                    shortName: market.shortBettingTypeName
                ),
                outcomes: hierarchicalOutcomes,
                isAvailable: market.isAvailable,
                isMainLine: market.mainLine,
                paramFloat1: market.paramFloat1
            )
        }
    }
}