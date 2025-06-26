//
//  Entity.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    /// Protocol for all entities that can be stored and referenced
    protocol Entity: Codable, Identifiable {
        var id: String { get }
        static var rawType: String { get }
    }
}