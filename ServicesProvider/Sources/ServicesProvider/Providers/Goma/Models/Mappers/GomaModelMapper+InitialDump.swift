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
        return PromotionsContent(
            alertBanner: content.alertBanner != nil ? alertBanner(fromInternalAlertBanner: content.alertBanner!) : nil,
            banners: banners(fromInternalBanners: content.banners ?? []),
            carouselEvents: carouselEvents(fromInternalCarouselEvents: content.carouselEvents ?? []),
            topImageCardPointers: topImageCardPointers(fromInternaTopImageCardPointers: content.topImageCardPointers ?? []),
            proChoiceCardPointers: proChoiceCardPointers(fromInternalProChoiceCardPointers: content.proChoiceCardPointers ?? []),
            boostedOddsBanners: boostedOddsPointers(fromInternalBoostedOddsPointers: content.boostedOddsBanners ?? []),
            heroCardPointers: heroCardPointers(fromInternalHeroCardPointers: content.heroCardPointers ?? []),
            stories: stories(fromInternalStories: content.stories ?? []),
            news: newsItems(fromInternalNewsItems: content.news ?? [])
        )
    }

}
