//
//  GomaModels+InitialDump.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

extension GomaModels {

    // MARK: - Initial Dump
    struct InitialDump: Codable {

        let homeTemplate: HomeTemplate
        let promotions: PromotionsContent

        enum CodingKeys: String, CodingKey {
            case homeTemplate = "home_template"
            case promotions = "promotions"
        }
    }

    // MARK: - Promotions Content
    struct PromotionsContent: Codable {
        let alertBanner: GomaModels.AlertBanner?
        let banners: [GomaModels.Banner]
        let carouselEvents: GomaModels.CarouselEvents
        let highlightedEvents: [HighlightedEventData]
        let proChoices: [GomaModels.ProChoice]
        let boostedOddsBanners: [GomaModels.BoostedOddsBanner]
        let heroCards: [GomaModels.HeroCard]
        let stories: [GomaModels.Story]
        let news: [GomaModels.NewsItem]

        enum CodingKeys: String, CodingKey {
            case alertBanner = "alert_banner"
            case banners
            case carouselEvents = "sport_banners"
            case highlightedEvents = "highlighted_events"
            case proChoices = "pro_choices"
            case boostedOddsBanners = "boosted_odds_banners"
            case heroCards = "hero_cards"
            case stories
            case news
        }
    }

    // MARK: - Highlighted Event

    struct HighlightedEventData: Codable {
        let sportEventId: String
        let sportEventMarketId: String
        let imageUrl: URL?

        enum CodingKeys: String, CodingKey {
            case sportEventId = "sport_event_id"
            case sportEventMarketId = "sport_event_market_id"
            case imageUrl = "image_url"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.sportEventId = try container.decode(String.self, forKey: .sportEventId)
            self.sportEventMarketId = try container.decode(String.self, forKey: .sportEventMarketId)

            if let imageUrlString = try container.decodeIfPresent(String.self, forKey: .imageUrl) {
                self.imageUrl = URL(string: imageUrlString)
            } else {
                self.imageUrl = nil
            }
        }
    }
}
