//
//  OutcomeBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct OutcomeBuilder: HierarchicalBuilder {
        typealias FlatType = OutcomeDTO
        typealias OutputType = Outcome

        static func build(from outcome: OutcomeDTO, store: EntityStore) -> Outcome? {
            // Get betting offers for this outcome in original order
            let allBettingOffers = store.getAllInOrder(BettingOfferDTO.self)
            let outcomeBettingOffers = allBettingOffers.filter { $0.outcomeId == outcome.id }

            // Build hierarchical betting offers
            let hierarchicalBettingOffers = outcomeBettingOffers.compactMap { offer in
                BettingOfferBuilder.build(from: offer, store: store)
            }

            return Outcome(
                id: outcome.id,
                name: outcome.translatedName,
                shortName: outcome.shortTranslatedName,
                code: outcome.code,
                bettingOffers: hierarchicalBettingOffers,
                headerName: outcome.headerName,
                headerNameKey: outcome.headerNameKey,
                paramFloat1: outcome.paramFloat1
            )
        }
    }
}