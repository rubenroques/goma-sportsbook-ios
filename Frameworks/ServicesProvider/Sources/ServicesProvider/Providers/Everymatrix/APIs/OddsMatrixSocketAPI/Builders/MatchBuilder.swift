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

            // Handle venue: LocationDTO may not be sent separately by EveryMatrix WebSocket
            // Fallback to embedded venue data in MatchDTO
            let venue: Location?
            if let venueDTO = venueDTO {
                // Prefer LocationDTO from store if available
                venue = LocationBuilder.build(from: venueDTO, store: store)
            } else {
                // Fallback: Use embedded venue data from MatchDTO
                venue = Location(
                    id: match.venueId,
                    typeId: match.venueId,
                    name: match.venueName,
                    shortName: match.shortVenueName
                )
            }

            let category = categoryDTO.flatMap { EventCategoryBuilder.build(from: $0, store: store) }

            // Get markets for this match in original order
            let allMarkets = store.getAllInOrder(MarketDTO.self)
            let matchMarkets = allMarkets.filter { $0.eventId == match.id }

            // Build hierarchical markets
            let hierarchicalMarkets = matchMarkets.compactMap { market in
                MarketBuilder.build(from: market, store: store)
            }

            // Use markets in original WAMP server order (same as events ordering strategy)
            // Previously sorted by paramFloat1/2/3 within betting type groups - commented out to trust server ordering
            // let sortedMarkets = hierarchicalMarkets.sorted { market1, market2 in
            //     // Only sort if same betting type - preserves original order otherwise
            //     guard market1.bettingType?.id == market2.bettingType?.id else {
            //         return false
            //     }
            //
            //     // Sort by paramFloat1
            //     let param1_1 = market1.paramFloat1 ?? Double.greatestFiniteMagnitude
            //     let param1_2 = market2.paramFloat1 ?? Double.greatestFiniteMagnitude
            //     if param1_1 != param1_2 {
            //         return param1_1 < param1_2
            //     }
            //
            //     // Sort by paramFloat2
            //     let param2_1 = market1.paramFloat2 ?? Double.greatestFiniteMagnitude
            //     let param2_2 = market2.paramFloat2 ?? Double.greatestFiniteMagnitude
            //     if param2_1 != param2_2 {
            //         return param2_1 < param2_2
            //     }
            //
            //     // Sort by paramFloat3
            //     let param3_1 = market1.paramFloat3 ?? Double.greatestFiniteMagnitude
            //     let param3_2 = market2.paramFloat3 ?? Double.greatestFiniteMagnitude
            //     return param3_1 < param3_2
            // }

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
