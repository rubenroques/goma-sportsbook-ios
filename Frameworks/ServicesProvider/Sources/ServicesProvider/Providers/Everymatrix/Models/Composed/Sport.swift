//
//  Sport.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct Sport: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let isVirtual: Bool?
        let numberOfEvents: Int?
        let numberOfLiveEvents: Int?
        let numberOfUpcomingMatches: Int?
        let showEventCategory: Bool?
        let isTopSport: Bool?
        
        let hasMatches: Bool?
        let hasOutrights: Bool?
    }
}
