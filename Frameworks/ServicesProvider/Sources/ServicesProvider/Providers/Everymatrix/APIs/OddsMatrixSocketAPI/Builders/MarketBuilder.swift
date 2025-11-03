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
            // Get outcomes for this market in original order
            let allOutcomes = store.getAllInOrder(OutcomeDTO.self)
            let allRelations = store.getAllInOrder(MarketOutcomeRelationDTO.self)
            let allBettingOffers = store.getAllInOrder(BettingOfferDTO.self)
            
            // Find outcomes related to this market
            let relatedOutcomeIds = allRelations
                .filter { $0.marketId == market.id }
                .map { $0.outcomeId }

            let marketOutcomes = allOutcomes.filter { relatedOutcomeIds.contains($0.id) }

            // Build hierarchical outcomes
            let hierarchicalOutcomes = marketOutcomes.compactMap { outcome in
                OutcomeBuilder.build(from: outcome, store: store)
            }
            
            // Sort outcomes using headerNameKey for consistent ordering
            let sortedOutcomes = hierarchicalOutcomes.sorted { outcome1, outcome2 in
                let sortValue1 = outcome1.headerNameKey.flatMap { EveryMatrixModelMapper.sortValue(
                    forOutcomeHeaderKey: $0,
                    paramFloat1: outcome1.paramFloat1) } ?? 1000
                let sortValue2 = outcome2.headerNameKey.flatMap { EveryMatrixModelMapper.sortValue(
                    forOutcomeHeaderKey: $0,
                    paramFloat1: outcome2.paramFloat1) } ?? 1000
                
                return sortValue1 < sortValue2
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
                outcomes: sortedOutcomes,
                isAvailable: market.isAvailable,
                isMainLine: market.mainLine,
                paramFloat1: market.paramFloat1,
                paramFloat2: market.paramFloat2,
                paramFloat3: market.paramFloat3
            )
        }
    }
}
