//
//  CasinoGameDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 29/01/2025.
//

import Foundation

extension EveryMatrix {
    
    /// DTO for casino game API response
    struct CasinoGameDTO: Codable {
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
        let advancedTags: [AnyCodable]?
        let logo: String?
        let slug: String?
        let theoreticalPayOut: Double?
        let platform: [FailableDecodable<String>]?
        let maxBetRestriction: CasinoGameBetRestrictionDTO?
        let vendor: CasinoGameVendorDTO?  // Optional - v2 only has href, not displayed in UI
        let tags: CasinoGameTagsDTO?
        let categories: CasinoGameCategoriesDTO?
        let jackpots: CasinoGameJackpotsDTO?
        let htmlDescription: String?
        let description: String?
        let promo: CasinoGamePromoDTO?
        let exclusive: CasinoGameExclusiveDTO?
        let gameCode: String?
        let helpUrl: String?
        let languages: [FailableDecodable<String>]?
        let currencies: [FailableDecodable<String>]?
        let realMode: CasinoGameRealModeDTO?
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
        let groups: CasinoGameGroupsDTO?
        let groupInfos: CasinoGameGroupInfosDTO?
        let lobby: [FailableDecodable<String>]?
    }
    
    /// DTO for casino games response
    struct CasinoGamesResponseDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameDTO>]
        let pages: CasinoPagesDTO?
    }
    
    /// DTO for game vendor information (v2 only has href)
    struct CasinoGameVendorDTO: Codable {
        let href: String?
    }
    
    /// DTO for game tags
    struct CasinoGameTagsDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameTagItemDTO>]
        let pagination: CasinoPagesDTO?
    }
    
    /// DTO for individual tag item
    struct CasinoGameTagItemDTO: Codable {
        let href: String
    }
    
    /// DTO for game categories
    struct CasinoGameCategoriesDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameCategoryItemDTO>]
        let pagination: CasinoPagesDTO?
    }
    
    /// DTO for individual category item
    struct CasinoGameCategoryItemDTO: Codable {
        let href: String
    }
    
    /// DTO for game jackpots
    struct CasinoGameJackpotsDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<AnyCodable>]
        let pagination: CasinoPagesDTO?
    }
    
    /// DTO for bet restrictions
    struct CasinoGameBetRestrictionDTO: Codable {
        let defaultMaxBet: [String: Double]?
        let defaultMaxWin: [String: Double]?
        let defaultMaxMultiplier: Double?
    }
    
    /// DTO for real mode settings
    struct CasinoGameRealModeDTO: Codable {
        let fun: Bool?
        let anonymity: Bool?
        let realMoney: Bool?
    }
    
    /// DTO for promotional settings
    struct CasinoGamePromoDTO: Codable {
        let effective: Bool
    }
    
    /// DTO for exclusive settings
    struct CasinoGameExclusiveDTO: Codable {
        let effective: Bool
    }
    
    /// DTO for game groups
    struct CasinoGameGroupsDTO: Codable {
        let count: Int
        let items: [FailableDecodable<String>]
    }
    
    /// DTO for group infos
    struct CasinoGameGroupInfosDTO: Codable {
        let count: Int
        let items: [String: FailableDecodable<CasinoGameGroupInfoItemDTO>]
    }
    
    /// DTO for individual group info item
    struct CasinoGameGroupInfoItemDTO: Codable {
        let position: String?
        let thumbnail: String?
    }
}
