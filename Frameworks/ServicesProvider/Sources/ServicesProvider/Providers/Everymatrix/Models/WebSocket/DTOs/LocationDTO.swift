//
//  LocationDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct LocationDTO: Entity {
        let id: String
        static let rawType: String = "LOCATION"
        let typeId: String
        let name: String
        let shortName: String
        let code: String?
    }
}