//
//  BettingOffer.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct BettingOffer: Identifiable, Hashable {
        let id: String
        let odds: Double
        let isAvailable: Bool
        let isLive: Bool
        let lastChangedTime: Date
        let providerId: String
    }
}