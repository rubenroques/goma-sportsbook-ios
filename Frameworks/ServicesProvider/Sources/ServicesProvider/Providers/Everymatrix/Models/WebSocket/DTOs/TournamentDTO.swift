//
//  TournamentDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct TournamentDTO: Entity {
        let id: String
        static let rawType: String = "TOURNAMENT"
        let isTopLevelTournament: Bool
        let typeId: String
        let sportId: String
        let templateId: String
        let name: String
        let startTime: Int64
        let endTime: Int64
        let venueId: String
        let statusId: String
        let rootPartId: String
        let categoryId: String
        let allowsLiveOdds: Bool
        let numberOfMarkets: Int
        let numberOfBettingOffers: Int
        let numberOfLiveMarkets: Int
        let numberOfLiveBettingOffers: Int
        let typeName: String
        let sportName: String
        let shortSportName: String
        let templateName: String
        let venueName: String
        let shortVenueName: String
        let statusName: String
        let rootPartName: String
        let shortRootPartName: String
        let translatedName: String
        let shortTranslatedName: String
        let numberOfEvents: Int
        let numberOfUpcomingMatches: Int
        let numberOfOutrightMarkets: Int
        let numberOfOutrightMarketsForSubtournaments: Int
        let numberOfLiveEvents: Int
        let showEventCategory: Bool
        let categoryName: String
        let displayChildren: Bool
        let layoutStyle: String
    }
}