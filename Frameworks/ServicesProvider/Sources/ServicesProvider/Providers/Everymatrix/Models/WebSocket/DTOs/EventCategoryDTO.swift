//
//  EventCategoryDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct EventCategoryDTO: Entity {
        let id: String
        static let rawType: String = "EVENT_CATEGORY"
        let sportId: String
        let sportName: String
        let name: String
        let shortName: String
        let numberOfEvents: Int
        let numberOfMarkets: Int
        let numberOfBettingOffers: Int
        let numberOfLiveEvents: Int
        let numberOfLiveMarkets: Int
        let numberOfLiveBettingOffers: Int
        let numberOfUpcomingMatches: Int
    }
}