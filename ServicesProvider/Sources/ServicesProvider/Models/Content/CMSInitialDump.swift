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
    public let promotions: PromotionsContent

}

/// Contains all promotional content grouped by type
public struct PromotionsContent: Codable, Equatable, Hashable {
    /// Alert banner at the top of the app
    public let alertBanner: AlertBanner?

    /// Promotional banners
    public let banners: [Banner]

    /// Sport-specific banners
    public let carouselEvents: CarouselEvents

    /// Highlighted events with custom images
    public let highlightedEvents: [HighlightedEventData]

    /// Expert betting picks
    public let proChoices: [ProChoice]

    /// Boosted odds promotions
    public let boostedOddsBanners: [BoostedOddsBanner]

    /// Featured hero card promotions
    public let heroCards: [HeroCard]

    /// Promotional stories
    public let stories: [Story]

    /// News items
    public let news: [NewsItem]

}

/// Highlighted event model
public struct HighlightedEventData: Codable, Equatable, Hashable {
    /// Sport event identifier
    public let sportEventId: String

    /// Sport event market identifier
    public let sportEventMarketId: String

    /// Image URL for the event
    public let imageUrl: URL?

}
