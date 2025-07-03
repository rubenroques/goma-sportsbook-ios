//
//  Match.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct Match: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let startTime: Date
        let sport: Sport?
        let venue: Location?
        let competitionId: String?
        let competitionName: String?
        let category: EventCategory?
        let homeParticipant: Participant?
        let awayParticipant: Participant?
        let status: MatchStatus
        let markets: [Market]
        let allowsLiveOdds: Bool?
        let numberOfMarkets: Int?
        let numberOfBettingOffers: Int?

        struct Participant: Identifiable, Hashable {
            let id: String
            let name: String
            let shortName: String
        }

        struct MatchStatus: Identifiable, Hashable {
            let id: String
            let name: String
        }
    }
}