//
//  Market.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct Market: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let displayName: String?
        let bettingType: BettingType?
        let outcomes: [Outcome]
        let isAvailable: Bool?
        let isMainLine: Bool?
        let paramFloat1: Double?

        struct BettingType: Identifiable, Hashable {
            let id: String
            let name: String
            let shortName: String
        }
    }
}