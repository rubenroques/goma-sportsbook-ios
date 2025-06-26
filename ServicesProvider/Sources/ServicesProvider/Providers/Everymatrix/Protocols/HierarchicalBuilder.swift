//
//  HierarchicalBuilder.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    /// Protocol for building hierarchical objects from flat data
    protocol HierarchicalBuilder {
        associatedtype FlatType: Entity
        associatedtype OutputType

        static func build(from entity: FlatType, store: EntityStore) -> OutputType?
    }
}