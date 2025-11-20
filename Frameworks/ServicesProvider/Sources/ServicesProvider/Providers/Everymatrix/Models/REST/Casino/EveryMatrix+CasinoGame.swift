//
//  CasinoGame.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 29/01/2025.
//

import Foundation

extension EveryMatrix {

    /// REST API model for casino game response
    struct CasinoGame: Codable {
        let href: String
        let id: String
        let name: String
        let launchUrl: String
        let backgroundImageUrl: String?
        let popularity: Double?
        let isNew: Bool?
        let width: Int?
        let height: Int?
        let hasFunMode: Bool?
        let hasAnonymousFunMode: Bool?
        let thumbnail: String?
        let subVendor: String?
        let subVendorId: Int?
        let defaultThumbnail: String?
        let type: String?
        let advancedTags: [String]?
        let logo: String?
        let slug: String?
        let theoreticalPayOut: Double?
        let platform: [FailableDecodable<String>]?
        let maxBetRestriction: CasinoGameBetRestriction?
        let vendor: CasinoGameVendor?  // Optional - v2 only has href, not displayed in UI
        let tags: CasinoGameTags?
        
        let categories: CasinoGameCategories?
        let jackpots: CasinoGameJackpots?
        
        let htmlDescription: String?
        let description: String?
        let promo: CasinoGamePromo?
        let exclusive: CasinoGameExclusive?
        let gameCode: String?
        let helpUrl: String?
        let languages: [FailableDecodable<String>]?
        let currencies: [FailableDecodable<String>]?
        let realMode: CasinoGameRealMode?
        let license: String?
        let minHitFrequency: Double?
        let maxHitFrequency: Double?
        let vendorGameID: String?
        let restrictedTerritories: [FailableDecodable<String>]?
        let gId: Int?
        let gameId: Int?
        let thumbnails: [String: String]?
        let fpp: Double?
        let bonusContribution: Double?
        let icons: [String: String]?
        let volatility: String?
        let position: String?
        let groups: CasinoGameGroups?
        let groupInfos: CasinoGameGroupInfos?
        let lobby: [FailableDecodable<String>]?
    }
    
    /// REST API model for casino games response
    struct CasinoGamesResponse: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGame>]?
        let pages: CasinoPages?
        let success: Bool?
        let errorMessage: String?
        let errorCode: Int?
    }
    
    /// REST API model for game vendor information (v2 only has href)
    struct CasinoGameVendor: Codable {
        let href: String?
    }
    
    /// REST API model for game tags
    struct CasinoGameTags: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameTagItem>]
        let pagination: CasinoPages?
    }
    
    /// REST API model for individual tag item
    struct CasinoGameTagItem: Codable {
        let href: String
    }
    
    /// REST API model for game categories
    struct CasinoGameCategories: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameCategoryItem>]
        let pagination: CasinoPages?
    }
    
    /// REST API model for individual category item
    struct CasinoGameCategoryItem: Codable {
        let href: String?  // Optional - not always present in API responses
        let id: String
        let name: String
    }
    
    /// REST API model for game jackpots
    struct CasinoGameJackpots: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<String>]?
        let pagination: CasinoPages?
    }
    
    /// REST API model for bet restrictions
    struct CasinoGameBetRestriction: Codable {
        let defaultMaxBet: [String: Double]?
        let defaultMaxWin: [String: Double]?
        let defaultMaxMultiplier: Double?
    }
    
    /// REST API model for real mode settings
    struct CasinoGameRealMode: Codable {
        let fun: Bool?
        let anonymity: Bool?
        let realMoney: Bool?
    }
    
    /// REST API model for promotional settings
    struct CasinoGamePromo: Codable {
        let effective: Bool
    }
    
    /// REST API model for exclusive settings
    struct CasinoGameExclusive: Codable {
        let effective: Bool
    }
    
    /// REST API model for game groups
    struct CasinoGameGroups: Codable {
        let count: Int
        let items: [FailableDecodable<String>]
    }
    
    /// REST API model for group infos
    struct CasinoGameGroupInfos: Codable {
        let count: Int
        let items: [String: FailableDecodable<CasinoGameGroupInfoItem>]
    }
    
    /// REST API model for individual group info item
    struct CasinoGameGroupInfoItem: Codable {
        let position: String?
        let thumbnail: String?
    }
}
