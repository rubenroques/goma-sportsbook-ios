//
//  CasinoCategory.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 29/01/2025.
//

import Foundation

extension EveryMatrix {
    
    /// REST API model for casino category API response
    struct CasinoCategory: Codable {
        let id: String
        let name: String
        let games: CasinoCategoryGames
    }
    
    /// REST API model for games information within a category
    struct CasinoCategoryGames: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGame>]
        let pages: CasinoPages?
    }
    
    /// REST API model for casino categories response
    struct CasinoCategoriesResponse: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoCategory>]
        let pages: CasinoPages?
    }
    
    /// REST API model for pagination pages information
    struct CasinoPages: Codable {
        let first: String?
        let next: String?
        let previous: String?
        let last: String?
    }
    
    /// REST API model for casino group response (v2 games endpoint)
    struct CasinoGroupResponse: Codable {
        let id: String?
        let name: String?
        let games: CasinoGamesNested?
        let success: Bool?
        let errorMessage: String?
        let errorCode: Int?
    }

    /// REST API model for nested games structure in v2 response
    struct CasinoGamesNested: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGame>]
        let pages: CasinoPages?
    }
}
