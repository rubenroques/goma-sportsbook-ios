//
//  BettingOfferBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct BettingOfferBuilder: HierarchicalBuilder {
        typealias FlatType = BettingOfferDTO
        typealias OutputType = BettingOffer

        static func build(from offer: BettingOfferDTO, store: EntityStore) -> BettingOffer? {
            return BettingOffer(
                id: offer.id,
                odds: offer.odds,
                isAvailable: offer.isAvailable,
                isLive: offer.isLive,
                lastChangedTime: Date(timeIntervalSince1970: TimeInterval(offer.lastChangedTime / 1000)),
                providerId: offer.providerId
            )
        }
    }
}