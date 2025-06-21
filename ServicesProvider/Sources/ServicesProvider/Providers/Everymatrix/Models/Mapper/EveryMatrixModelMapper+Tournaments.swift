//
//  EveryMatrixModelMapper+Tournaments.swift
//  ServicesProvider
//
//  Created by André Lascas on 17/06/2025.
//

import Foundation
import SharedModels

extension EveryMatrixModelMapper {
    static func tournament(fromInternalTournament internalTournament: EveryMatrix.Tournament) -> Tournament? {
        return Tournament(
            type: "TOURNAMENT",
            id: internalTournament.id,
            idAsString: nil,
            typeId: nil,
            name: internalTournament.name,
            shortName: internalTournament.shortName,
            numberOfEvents: internalTournament.numberOfEvents,
            numberOfMarkets: internalTournament.numberOfMarkets,
            numberOfBettingOffers: internalTournament.numberOfBettingOffers,
            numberOfLiveEvents: internalTournament.numberOfLiveEvents,
            numberOfLiveMarkets: internalTournament.numberOfLiveMarkets,
            numberOfLiveBettingOffers: nil,
            numberOfOutrightMarkets: internalTournament.numberOfOutrightMarkets,
            numberOfUpcomingMatches: internalTournament.numberOfUpcomingMatches,
            sportId: internalTournament.sportId,
            sportName: internalTournament.sportName,
            shortSportName: nil,
            venueId: internalTournament.venueId,
            venueName: internalTournament.venueName,
            shortVenueName: nil,
            categoryId: internalTournament.categoryId,
            templateId: nil,
            templateName: nil,
            rootPartId: nil,
            rootPartName: nil,
            shortRootPartName: nil
        )
    }
}
