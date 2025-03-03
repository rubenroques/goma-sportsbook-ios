//
//  GomaModelMapper+InitialDump.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

extension GomaModelMapper {

    // MARK: - Initial Dump Mapper

    static func initialDump(fromInternalInitialDump dump: GomaModels.InitialDump) -> CMSInitialDump {
        return CMSInitialDump(
            homeTemplate: homeTemplate(fromInternalHomeTemplate: dump.homeTemplate),
            promotions: promotionsContent(fromInternalPromotionsContent: dump.promotions)
        )
    }

    // MARK: - Promotions Content Mapper

    static func promotionsContent(fromInternalPromotionsContent content: GomaModels.PromotionsContent) -> PromotionsContent {
        // Convert sport banners to carousel events
        let carouselEvents: CarouselEvents = content.carouselEvents
            .map { (carouselEvent: GomaModels.CarouselEvent) -> CarouselEvent in
                return Self.carouselEvent(fromInternalCarouselEvent: carouselEvent)
            }
        
        // Convert highlighted events
        let highlightedEvents = content.highlightedEvents.map { highlightedEvent(fromInternalHighlightedEvent: $0) }

        return PromotionsContent(
            alertBanner: content.alertBanner != nil ? alertBanner(fromInternalAlertBanner: content.alertBanner!) : nil,
            banners: banners(fromInternalBanners: content.banners),
            carouselEvents: carouselEvents,
            highlightedEvents: highlightedEvents,
            proChoices: proChoices(fromInternalProChoices: content.proChoices),
            boostedOddsBanners: boostedOddsBanners(fromInternalBoostedOddsBanners: content.boostedOddsBanners),
            heroCards: heroCards(fromInternalHeroCards: content.heroCards),
            stories: stories(fromInternalStories: content.stories),
            news: newsItems(fromInternalNewsItems: content.news)
        )
    }

    // MARK: - Highlighted Event Mapper

    static func highlightedEvent(fromInternalHighlightedEvent event: GomaModels.HighlightedEventData) -> HighlightedEventData {
        return HighlightedEventData(
            sportEventId: event.sportEventId,
            sportEventMarketId: event.sportEventMarketId,
            imageUrl: event.imageUrl
        )
    }
}
