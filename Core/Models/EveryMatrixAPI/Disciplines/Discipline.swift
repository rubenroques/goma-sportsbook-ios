//
//  Discipline.swift
//  Sportsbook
//
//  Created by André Lascas on 02/09/2021.
//

import Foundation

extension EveryMatrix {
    struct Discipline: Decodable {

        let type: String
        let id: String?
        let name: String?
        let numberOfLiveEvents: Int?

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case id = "id"
            case name = "name"
//            case shortName = "shortName"
//            case isVirtual = "isVirtual"
//            case numberOfEvents = "numberOfEvents"
//            case numberOfMarkets = "numberOfMarkets"
//            case numberOfBettingOffers = "numberOfBettingOffers"
            case numberOfLiveEvents = "numberOfLiveEvents"
//            case numberOfLiveMarkets = "numberOfLiveMarkets"
//            case numberOfLiveBettingOffers = "numberOfLiveBettingOffers"
//            case numberOfUpcomingMatches = "numberOfUpcomingMatches"
//            case childrenIds = "childrenIds"
//            case displayChildren = "displayChildren"
//            case showEventCategory = "showEventCategory"
        }

        func sportUpdated(numberOfLiveEvents: Int?) -> Discipline {
            return Discipline(
                type: self.type,
                id: self.id,
                name: self.name,
                numberOfLiveEvents: numberOfLiveEvents ?? self.numberOfLiveEvents

            )
        }
    }
}
