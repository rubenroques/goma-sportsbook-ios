//
//  CasinoCategoryDTO.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 29/01/2025.
//

import Foundation

extension EveryMatrix {
    
    /// DTO for casino category API response
    struct CasinoCategoryDTO: Codable {
        let id: String
        let name: String
        let games: CasinoCategoryGamesDTO
    }
    
    /// DTO for games information within a category
    struct CasinoCategoryGamesDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameDTO>]
        let pages: CasinoPagesDTO?
    }
    
    /// DTO for casino categories response
    struct CasinoCategoriesResponseDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoCategoryDTO>]
        let pages: CasinoPagesDTO?
    }
    
    /// DTO for pagination pages information
    struct CasinoPagesDTO: Codable {
        let first: String?
        let next: String?
        let previous: String?
        let last: String?
    }
    
    /// DTO for casino group response (v2 games endpoint)
    struct CasinoGroupResponseDTO: Codable {
        let id: String?
        let name: String?
        let games: CasinoGamesNestedDTO?
        let success: Bool?
        let errorMessage: String?
        let errorCode: Int?
    }

    /// DTO for nested games structure in v2 response
    struct CasinoGamesNestedDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<CasinoGameDTO>]
        let pages: CasinoPagesDTO?
    }
}
