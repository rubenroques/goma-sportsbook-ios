//
//  GomaModelsHeroCardEvents+.swift
//
//
//  Created by André Lascas on 23/09/2024.
//

import Foundation

extension GomaModels {
    
    struct HeroCardEvents: Codable {
        
        var id: Int
        var imageUrl: String
        var event: Event
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case imageUrl = "image_url"
            case event = "event"
        }
    }
}
