//
//  EventCategory.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct EventCategory: Identifiable, Hashable {
        let id: String
        let sportId: String
        let sportName: String?
        let name: String
        let shortName: String?
        let numberOfEvents: Int?
        let numberOfLiveEvents: Int?
        let numberOfUpcomingMatches: Int?
    }
}