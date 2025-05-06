//
//  SportRadarModels+WheelEligibility.swift
//  ServicesProvider
//
//  Created by André Lascas on 30/04/2025.
//

import Foundation

extension SportRadarModels {
    
    struct WheelStatusResponse: Codable {
        let status: String
        let message: String?
        let data: WheelEligibility?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
            case data = "data"
        }
    }
    
    struct WheelEligibility: Codable {
        var productCode: String
        var gameTransId: String
        var winBoosts: [WheelStatus]
        
        enum CodingKeys: String, CodingKey {
            case productCode = "productCode"
            case gameTransId = "gameTranId"
            case winBoosts = "winBoosts"
        }
    }

    struct WheelStatus: Codable {
        var gameTransId: String?
        var status: String
        var message: String?
        var configuration: WheelConfiguration?
        
        enum CodingKeys: String, CodingKey {
            case gameTransId = "gameTranId"
            case status = "status"
            case message = "message"
            case configuration = "configuration"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.gameTransId = try container.decodeIfPresent(String.self, forKey: .gameTransId)
            
            self.status = try container.decode(String.self, forKey: .status)

            self.message = try container.decodeIfPresent(String.self, forKey: .message)

            self.configuration = try? container.decodeIfPresent(WheelConfiguration.self, forKey: .configuration)

        }
    }

    struct WheelConfiguration: Codable {
        var id: String
        var title: String
        var tiers: [WheelTier]
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case title = "title"
            case tiers = "tiers"
        }
    }
    
    struct WheelTier: Codable {
        var name: String
        var chance: Double
        var boostMultiplier: Double
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case chance = "chance"
            case boostMultiplier = "boostMultiplier"
        }
    }
    
    struct WheelOptInResponse: Codable {
        let status: String
        let message: String?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
        }
    }
}
