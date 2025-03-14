//
//  CMSInitialDump.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

/// Represents the complete initial dump of CMS content
public struct CMSInitialDump: Codable, Equatable, Hashable {
    /// Home template configuration
    public let homeTemplate: HomeTemplate

    /// All promotional content
    public let homeWidgetContent: HomeWidgetContent

}

/// Contains all promotional content grouped by type
public struct HomeWidgetContent: Codable, Equatable, Hashable {
    /// Alert banner at the top of the app
    public let alertBanner: AlertBanner?

    /// Promotional banners
    public let banners: Banners?

    /// Sport-specific banners
    public let carouselEvents: CarouselEvents?

    /// Highlighted events with custom images
    public let topImageCardPointers: TopImageCardPointers?

    /// Expert betting picks
    public let proChoiceCardPointers: ProChoiceCardPointers?

    /// Boosted odds promotions
    public let boostedOddsBanners: BoostedOddsPointers?

    /// Featured hero card promotions
    public let heroCardPointers: HeroCardPointers?

    /// Promotional stories
    public let stories: Stories?

    /// News items
    public let news: NewsItems?
    
    init(alertBanner: AlertBanner?,
         banners: Banners?,
         carouselEvents: CarouselEvents?,
         topImageCardPointers: TopImageCardPointers?,
         proChoiceCardPointers: ProChoiceCardPointers?,
         boostedOddsBanners: BoostedOddsPointers?,
         heroCardPointers: HeroCardPointers?,
         stories: Stories?,
         news: NewsItems?) {
        self.alertBanner = alertBanner
        self.banners = banners
        self.carouselEvents = carouselEvents
        self.topImageCardPointers = topImageCardPointers
        self.proChoiceCardPointers = proChoiceCardPointers
        self.boostedOddsBanners = boostedOddsBanners
        self.heroCardPointers = heroCardPointers
        self.stories = stories
        self.news = news
    }

}

/// Highlighted event model
public typealias TopImageCardPointers = [TopImageCardPointer]
public struct TopImageCardPointer: Codable, Equatable, Hashable {
    /// Sport event identifier
    public let eventId: String

    /// Sport event market identifier
    public let eventMarketId: String

    /// Image URL for the event
    public let imageUrl: String?
    
    init(eventId: String, eventMarketId: String, imageUrl: String?) {
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.imageUrl = imageUrl
    }
}
