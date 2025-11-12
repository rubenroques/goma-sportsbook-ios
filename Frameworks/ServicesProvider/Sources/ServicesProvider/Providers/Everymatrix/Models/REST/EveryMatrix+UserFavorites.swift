//
//  EveryMatrix+UserFavorites.swift
//  ServicesProvider
//
//  Created by André Lascas on 12/11/2025.
//

import Foundation

extension EveryMatrix {
    
    struct UserFavoritesResponse: Codable {
        var favoriteEvents: [String]
        
        enum CodingKeys: String, CodingKey {
            case favoriteEvents = "favoriteEvents"
        }
    }
}
