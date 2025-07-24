//
//  MarketInfoDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    struct MarketInfoDTO: Entity {
        let id: String
        static let rawType: String = "MARKET_INFO"
        let marketInfo: String
        let displayKey: String
    }
}