//
//  GomaModelsHeroCardEvents+.swift
//
//
//  Created by André Lascas on 23/09/2024.
//

import Foundation

extension GomaModels {
    
    typealias HeroCardEvents = [HeroCardEvent]
    
    struct HeroCardEvent: Codable {
        
        var id: Int
        var imageUrl: String?
        var event: Event
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case imageUrl = "image_url"
            case event = "event"
        }
    }
    
    typealias CarouselEvents = [CarouselEvent]
    
    struct CarouselEvent: Codable {
        
        var id: Int
        var imageUrl: String?
        var ctaUrl: String?
        var event: Event
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case ctaUrl = "cta_url"
            case imageUrl = "image_url"
            case event = "event"
        }
    }

    typealias BoostedOddsEvents = [BoostedOddsEvent]
    
    struct BoostedOddsEvent: Codable {
        
        var id: Int
        var name: String?
        var imageUrl: String?
        var ctaUrl: String?
        var event: Event
        var boostedOddMarket: Market
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case ctaUrl = "cta_url"
            case imageUrl = "image_url"
            case event = "event"
            case boostedOddMarket = "boosted_market"
        }
    }
    
}
