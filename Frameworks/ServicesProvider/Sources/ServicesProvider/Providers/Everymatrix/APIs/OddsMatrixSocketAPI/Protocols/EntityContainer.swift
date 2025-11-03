//
//  EntityContainer.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    /// Protocol for entities that can contain references to other entities
    protocol EntityContainer {
        func getReferencedIds() -> [String: [String]]
    }
}