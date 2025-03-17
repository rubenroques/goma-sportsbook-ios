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
            homeWidgetContent: homeWidgetContent(fromInternalhomeWidgetContent: dump.homeWidgetContent)
        )
    }

    // MARK: - Promotions Content Mapper
    static func homeWidgetContent(fromInternalhomeWidgetContent content: GomaModels.HomeWidgetContent) -> HomeWidgetContent {
        return HomeWidgetContent(
            alertBanner: content.alertBanner != nil ? Self.alertBanner(fromInternalAlertBanner: content.alertBanner!) : nil,
            banners: Self.banners(fromInternalBanners: content.banners ?? []),
            carouselEventPointers: Self.carouselEventPointers(fromInternalCarouselEventPointers: content.carouselEventPointers ?? []),
            topImageCardPointers: Self.topImageCardPointers(fromInternaTopImageCardPointers: content.topImageCardPointers ?? []),
            proChoiceCardPointers: Self.proChoiceCardPointers(fromInternalProChoiceCardPointers: content.proChoiceCardPointers ?? []),
            boostedOddsBanners: Self.boostedOddsPointers(fromInternalBoostedOddsPointers: content.boostedOddsBanners ?? []),
            heroCardPointers: Self.heroCardPointers(fromInternalHeroCardPointers: content.heroCardPointers ?? []),
            stories: Self.stories(fromInternalStories: content.stories ?? []),
            news: Self.newsItems(fromInternalNewsItems: content.news ?? [])
        )
    }

}
