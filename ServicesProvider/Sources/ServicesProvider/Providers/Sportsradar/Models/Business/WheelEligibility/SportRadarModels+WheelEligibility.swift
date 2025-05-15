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
        var winBoostId: String?
        var gameTransId: String?
        var status: String
        var message: String?
        var configuration: WheelConfiguration?
        
        enum CodingKeys: String, CodingKey {
            case winBoostId = "winBoostId"
            case gameTransId = "gameTranId"
            case status = "status"
            case message = "message"
            case configuration = "configuration"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.winBoostId = try container.decodeIfPresent(String.self, forKey: .winBoostId)
            
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
    
    struct WheelOptInData: Codable {
        let status: String
        let winBoostId: String?
        let gameTranId: String?
        let awardedTier: WheelAwardedTier?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case winBoostId = "winBoostId"
            case gameTranId = "gameTranId"
            case awardedTier = "awardedTier"
        }
    }
    
    struct WheelAwardedTier: Codable {
        let configurationId: String?
        let name: String
        let boostMultiplier: Double
        
        enum CodingKeys: String, CodingKey {
            case configurationId = "configurationId"
            case name = "name"
            case boostMultiplier = "boostMultiplier"
        }
    }
    
    struct GrantedWinBoostsResponse: Codable {
        let status: String
        let message: String?
        let data: [GrantedWinBoosts]?
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case message = "message"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            status = try container.decode(String.self, forKey: .status)
            message = try container.decodeIfPresent(String.self, forKey: .message)
            
            // Handle the case where data might be an empty array
            do {
                data = try container.decodeIfPresent([GrantedWinBoosts].self, forKey: .data)
            } catch {
                // If decoding as array fails, check if it's an empty array
                if let dataValue = try? container.decodeIfPresent(EmptyResponse.self, forKey: .data) {
                    if dataValue.isEmpty {
                        data = []
                    } else {
                        throw error
                    }
                } else {
                    data = nil
                }
            }
        }
    }

    struct GrantedWinBoosts: Codable {
        let gameTranId: String
        let winBoosts: [GrantedWinBoostInfo]
        
        enum CodingKeys: String, CodingKey {
            case gameTranId = "gameTranId"
            case winBoosts = "winBoosts"
        }
    }

    struct GrantedWinBoostInfo: Codable {
        let winBoostId: String
        let gameTranId: String
        let status: String
        let awardedTier: WheelAwardedTier?
        let boostAmount: Double?
        
        enum CodingKeys: String, CodingKey {
            case winBoostId = "winBoostId"
            case gameTranId = "gameTranId"
            case status = "status"
            case awardedTier = "awardedTier"
            case boostAmount = "boostAmount"
        }
    }
    
    // Helper struct to detect empty arrays or objects
    struct EmptyResponse: Codable {
        var isEmpty: Bool {
            return true
        }
    }
}
