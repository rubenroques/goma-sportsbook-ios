//
//  Tournament.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct Tournament: Identifiable, Hashable {
        let type: String
        let id: String
        let idAsString: String?
        let typeId: String?
        let name: String?
        let shortName: String?
        let numberOfEvents: Int
        let numberOfMarkets: Int?
        let numberOfBettingOffers: Int?
        let numberOfLiveEvents: Int
        let numberOfLiveMarkets: Int?
        let numberOfLiveBettingOffers: Int?
        let numberOfOutrightMarkets: Int?
        let numberOfUpcomingMatches: Int?
        let sportId: String?
        let sportName: String?
        let shortSportName: String?
        let venueId: String?
        let venueName: String?
        let shortVenueName: String?
        let categoryId: String?
        let templateId: String?
        let templateName: String?
        let rootPartId: String?
        let rootPartName: String?
        let shortRootPartName: String?
    }
}