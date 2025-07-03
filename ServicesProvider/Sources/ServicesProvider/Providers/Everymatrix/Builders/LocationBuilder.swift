//
//  LocationBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct LocationBuilder: HierarchicalBuilder {
        typealias FlatType = LocationDTO
        typealias OutputType = Location

        static func build(from location: LocationDTO, store: EntityStore) -> Location? {
            return Location(
                id: location.id,
                typeId: location.typeId,
                name: location.name,
                shortName: location.shortName,
                code: location.code
            )
        }
    }
}