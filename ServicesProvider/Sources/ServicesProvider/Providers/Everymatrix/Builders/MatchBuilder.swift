//
//  MatchBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MatchBuilder: HierarchicalBuilder {
        typealias FlatType = MatchDTO
        typealias OutputType = Match

        static func build(from match: MatchDTO, store: EntityStore) -> Match? {
            // Get related entities
            let sportDTO = store.get(SportDTO.self, id: match.sportId)
            let venueDTO = store.get(LocationDTO.self, id: match.venueId)
            let categoryDTO = store.get(EventCategoryDTO.self, id: match.categoryId)

            // Convert DTOs to UI models using builders
            let sport = sportDTO.flatMap { SportBuilder.build(from: $0, store: store) }
            let venue = venueDTO.flatMap { LocationBuilder.build(from: $0, store: store) }
            let category = categoryDTO.flatMap { EventCategoryBuilder.build(from: $0, store: store) }

            // Get markets for this match in original order
            let allMarkets = store.getAllInOrder(MarketDTO.self)
            let matchMarkets = allMarkets.filter { $0.eventId == match.id }

            // Build hierarchical markets
            let hierarchicalMarkets = matchMarkets.compactMap { market in
                MarketBuilder.build(from: market, store: store)
            }

            return Match(
                id: match.id,
                name: match.name,
                shortName: match.shortName,
                startTime: Date(timeIntervalSince1970: TimeInterval(match.startTime / 1000)),
                sport: sport,
                venue: venue,
                competitionId: match.parentId,
                competitionName: match.parentName,
                category: category,
                homeParticipant: Match.Participant(
                    id: match.homeParticipantId,
                    name: match.homeParticipantName,
                    shortName: match.homeShortParticipantName
                ),
                awayParticipant: Match.Participant(
                    id: match.awayParticipantId,
                    name: match.awayParticipantName,
                    shortName: match.awayShortParticipantName
                ),
                status: Match.MatchStatus(
                    id: match.statusId,
                    name: match.statusName
                ),
                markets: hierarchicalMarkets,
                allowsLiveOdds: match.allowsLiveOdds,
                numberOfMarkets: match.numberOfMarkets,
                numberOfBettingOffers: match.numberOfBettingOffers
            )
        }
    }
}