//
//  CasinoCategoryDTO.swift
//  ServicesProvider
//
//  Created by Claude on 29/01/2025.
//

import Foundation

extension EveryMatrix {
    
    /// DTO for casino category API response
    struct CasinoCategoryDTO: Codable {
        let href: String
        let id: String
        let name: String
        let games: CasinoCategoryGamesDTO
    }
    
    /// DTO for games information within a category
    struct CasinoCategoryGamesDTO: Codable {
        let count: Int
        let total: Int
        let items: [FailableDecodable<AnyCodable>] // Games list is usually empty in category response
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
}
