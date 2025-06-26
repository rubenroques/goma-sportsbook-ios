//
//  Outcome.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct Outcome: Identifiable, Hashable {
        let id: String
        let name: String
        let shortName: String?
        let code: String
        let bettingOffers: [BettingOffer]
        let headerName: String?
        let headerNameKey: String?
    }
}