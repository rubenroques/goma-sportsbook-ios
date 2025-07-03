//
//  TournamentBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct TournamentBuilder: HierarchicalBuilder {
        typealias FlatType = TournamentDTO
        typealias OutputType = Tournament

        static func build(from tournament: TournamentDTO, store: EntityStore) -> Tournament? {
            return Tournament(
                type: "TOURNAMENT",
                id: tournament.id,
                idAsString: nil,
                typeId: tournament.typeId,
                name: tournament.name,
                shortName: tournament.shortTranslatedName,
                numberOfEvents: tournament.numberOfEvents,
                numberOfMarkets: tournament.numberOfMarkets,
                numberOfBettingOffers: tournament.numberOfBettingOffers,
                numberOfLiveEvents: tournament.numberOfLiveEvents,
                numberOfLiveMarkets: tournament.numberOfLiveMarkets,
                numberOfLiveBettingOffers: tournament.numberOfLiveBettingOffers,
                numberOfOutrightMarkets: tournament.numberOfOutrightMarkets,
                numberOfUpcomingMatches: tournament.numberOfUpcomingMatches,
                sportId: tournament.sportId,
                sportName: tournament.sportName,
                shortSportName: tournament.shortSportName,
                venueId: tournament.venueId,
                venueName: tournament.venueName,
                shortVenueName: tournament.shortVenueName,
                categoryId: tournament.categoryId,
                templateId: tournament.templateId,
                templateName: tournament.templateName,
                rootPartId: tournament.rootPartId,
                rootPartName: tournament.rootPartName,
                shortRootPartName: tournament.shortRootPartName
            )
        }
    }
}