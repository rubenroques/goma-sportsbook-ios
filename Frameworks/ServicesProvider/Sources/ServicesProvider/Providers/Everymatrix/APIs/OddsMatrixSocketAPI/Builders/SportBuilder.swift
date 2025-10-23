//
//  SportBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct SportBuilder: HierarchicalBuilder {
        typealias FlatType = SportDTO
        typealias OutputType = Sport

        static func build(from sport: SportDTO, store: EntityStore) -> Sport? {
            return Sport(
                id: sport.id,
                name: sport.name,
                shortName: sport.shortName,
                isVirtual: sport.isVirtual,
                numberOfEvents: sport.numberOfEvents,
                numberOfLiveEvents: sport.numberOfLiveEvents,
                numberOfUpcomingMatches: sport.numberOfUpcomingMatches,
                showEventCategory: sport.showEventCategory,
                isTopSport: sport.isTopSport,
                hasMatches: sport.hasMatches,
                hasOutrights: sport.hasOutrights
            )
        }
    }
}
