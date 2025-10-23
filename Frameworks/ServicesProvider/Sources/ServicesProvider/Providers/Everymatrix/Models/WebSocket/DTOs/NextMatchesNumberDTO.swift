//
//  NextMatchesNumberDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct NextMatchesNumberDTO: Entity {
        let id: String
        static let rawType: String = "NEXT_MATCHES_NUMBER"
        let numberOfNextEvents: Int
    }
}