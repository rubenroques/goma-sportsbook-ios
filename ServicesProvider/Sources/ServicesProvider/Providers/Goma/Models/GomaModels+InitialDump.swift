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
        let homeWidgetContent: HomeWidgetContent?
        let homeWidgetPointers: HomeWidgetPointers?

        enum CodingKeys: String, CodingKey {
            case homeTemplate = "home_template"
            case homeWidgetContent = "home_widgets"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.InitialDump.CodingKeys> = try decoder.container(keyedBy: GomaModels.InitialDump.CodingKeys.self)
            self.homeTemplate = try container.decode(GomaModels.HomeTemplate.self, forKey: GomaModels.InitialDump.CodingKeys.homeTemplate)
            
            // The server API can return both, a "pointing version" with IDs and a "full details" verion
            self.homeWidgetContent = try? container.decodeIfPresent(GomaModels.HomeWidgetContent.self, forKey: GomaModels.InitialDump.CodingKeys.homeWidgetContent)
            self.homeWidgetPointers = try? container.decodeIfPresent(GomaModels.HomeWidgetPointers.self, forKey: GomaModels.InitialDump.CodingKeys.homeWidgetContent)
            
            print("GM-InitialDump ")
        }
        
        func getAlertBanner() -> GomaModels.AlertBanner? {
            return self.homeWidgetContent?.alertBanner ?? self.homeWidgetPointers?.alertBanner
        }
        
        func getBanners() -> GomaModels.Banners? {
            return self.homeWidgetContent?.banners ?? self.homeWidgetPointers?.banners
        }
        
        func getNews() -> GomaModels.NewsItems? {
            return self.homeWidgetContent?.news ?? self.homeWidgetPointers?.news
        }
        
        func getstories() -> GomaModels.Stories? {
            return self.homeWidgetContent?.stories ?? self.homeWidgetPointers?.stories
        }
        
    }

    // MARK: - Promotions Content
    struct HomeWidgetContent: Codable {
        let alertBanner: GomaModels.AlertBanner?
        let banners: GomaModels.Banners?
        
        let carouselEvents: GomaModels.CarouselEvents?
        let topImageEvents: GomaModels.Events?
        let proChoiceEvents: GomaModels.Events?
        let boostedOddsEvents: GomaModels.BoostedOddsEvents?
        let heroCardEvents: GomaModels.HeroCardEvents?
        
        let stories: GomaModels.Stories?
        let news: GomaModels.NewsItems?

        enum CodingKeys: String, CodingKey {
            case alertBanner = "alert_banner"
            case banners
            case carouselEvents = "sport_banners"
            case topImageEvents = "highlighted_events"
            case proChoiceEvents = "pro_choices"
            case boostedOddsEvents = "boosted_odds_banners"
            case heroCardEvents = "hero_cards"
            case stories
            case news
        }
    }
    
    // MARK: - Promotions Content
    struct HomeWidgetPointers: Codable {
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

}
