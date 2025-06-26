//
//  EventCategoryBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct EventCategoryBuilder: HierarchicalBuilder {
        typealias FlatType = EventCategoryDTO
        typealias OutputType = EventCategory

        static func build(from category: EventCategoryDTO, store: EntityStore) -> EventCategory? {
            return EventCategory(
                id: category.id,
                sportId: category.sportId,
                sportName: category.sportName,
                name: category.name,
                shortName: category.shortName,
                numberOfEvents: category.numberOfEvents,
                numberOfLiveEvents: category.numberOfLiveEvents,
                numberOfUpcomingMatches: category.numberOfUpcomingMatches
            )
        }
    }
}