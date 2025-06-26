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
            // Get betting offers for this outcome
            let allBettingOffers = store.getAll(BettingOfferDTO.self)
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
                headerNameKey: outcome.headerNameKey
            )
        }
    }
}