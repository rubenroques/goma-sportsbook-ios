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
        let homeWidgetContent: HomeWidgetContent

        enum CodingKeys: String, CodingKey {
            case homeTemplate = "home_template"
            case homeWidgetContent = "home_widgets"
        }
    }

    // MARK: - Promotions Content
    struct HomeWidgetContent: Codable {
        let alertBanner: GomaModels.AlertBanner?
        let banners: GomaModels.Banners?
        let carouselEventPointers: GomaModels.CarouselEventPointers?
        let topImageCardPointers: GomaModels.TopImageCardPointers?
        let proChoiceCardPointers: GomaModels.ProChoiceCardPointers?
        let boostedOddsBanners: GomaModels.BoostedOddsPointers?
        let heroCardPointers: GomaModels.HeroCardPointers?
        let stories: GomaModels.Stories?
        let news: GomaModels.NewsItems?

        enum CodingKeys: String, CodingKey {
            case alertBanner = "alert_banner"
            case banners
            case carouselEventPointers = "sport_banners"
            case topImageCardPointers = "highlighted_events"
            case proChoiceCardPointers = "pro_choices"
            case boostedOddsBanners = "boosted_odds_banners"
            case heroCardPointers = "hero_cards"
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
