//
//  MarketGroupDTO.swift
//  ServicesProvider
//
//  Created on 2025-07-17.
//

import Foundation

extension EveryMatrix {
    
    struct MarketGroupDTO: Codable, Identifiable, Entity {
        let id: String
        let groupKey: String?
        let translatedName: String?
        let position: Int?
        let isDefault: Bool?
        let numberOfMarkets: Int?
        let isBetBuilder: Bool?
        let isFast: Bool?
        let isOutright: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id
            case groupKey
            case translatedName
            case position
            case isDefault
            case numberOfMarkets
            case isBetBuilder
            case isFast
            case isOutright
        }
        
        static let rawType = "MARKET_GROUP"
    }
}