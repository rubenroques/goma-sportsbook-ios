//
//  SportDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct SportDTO: Entity {
        let id: String
        static let rawType: String = "SPORT"
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
        let numberOfMatchesWhichWillHaveLiveOdds: String
        let childrenIds: [String]
        let displayChildren: Bool
        let showEventCategory: Bool
        let isTopSport: Bool
        let hasMatches: Bool
        let hasOutrights: Bool
        let parentId: String?
        let parentName: String?
        let parentShortName: String?
    }
}