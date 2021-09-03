//
//  Discipline.swift
//  Sportsbook
//
//  Created by André Lascas on 02/09/2021.
//

import Foundation

struct Discipline: Decodable {

    let type: String
    let id: String
    let name: String
    let shortName: String
    let isVirtual: Bool
    let numberOfEvents: Int
    let numberOfMarkets: Int
    let numberOfBettingOffers: Int
    let numberOfLiveEvents: Int
    let numberOfLiveMarkets: Int
    let numberOfLiveBettingOffers: Int
    let numberOfUpcomingMatches: Int
    let childrenIds: [String]?
    let displayChildren: Bool
    let showEventCategory: Bool

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case name = "name"
        case shortName = "shortName"
        case isVirtual = "isVirtual"
        case numberOfEvents = "numberOfEvents"
        case numberOfMarkets = "numberOfMarkets"
        case numberOfBettingOffers = "numberOfBettingOffers"
        case numberOfLiveEvents = "numberOfLiveEvents"
        case numberOfLiveMarkets = "numberOfLiveMarkets"
        case numberOfLiveBettingOffers = "numberOfLiveBettingOffers"
        case numberOfUpcomingMatches = "numberOfUpcomingMatches"
        case childrenIds = "childrenIds"
        case displayChildren = "displayChildren"
        case showEventCategory = "showEventCategory"
    }
}
