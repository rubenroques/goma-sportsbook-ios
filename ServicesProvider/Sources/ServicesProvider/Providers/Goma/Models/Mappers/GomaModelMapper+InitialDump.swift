//
//  GomaModelMapper+InitialDump.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

extension GomaModelMapper {

    // MARK: - Initial Dump Mapper

    static func initialDump(fromInternalInitialDump initialDump: GomaModels.InitialDump) -> CMSInitialDump {
        
        var mappedHomeWidgetContent: HomeWidgetContent?
        if let homeWidgetContentValue = initialDump.homeWidgetContent {
            mappedHomeWidgetContent  = Self.homeWidgetContent(fromInternalhomeWidgetContent: homeWidgetContentValue)
        }
         
        /// All promotional pointers
        var mappedHomeWidgetPointers: HomeWidgetPointers? 
        if let homeWidgetPointersValue = initialDump.homeWidgetPointers {
            mappedHomeWidgetPointers  = Self.homeWidgetPointers(fromInternalHomeWidgetPointers: homeWidgetPointersValue)
        }
        
        return CMSInitialDump(
            homeTemplate: Self.homeTemplate(fromInternalHomeTemplate: initialDump.homeTemplate),
            homeWidgetContent: mappedHomeWidgetContent,
            homeWidgetPointers: mappedHomeWidgetPointers
        )
    }

    // MARK: - Promotions Content Mapper
    static func homeWidgetPointers(fromInternalHomeWidgetPointers content: GomaModels.HomeWidgetPointers) -> HomeWidgetPointers {
        return HomeWidgetPointers(
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
    
    static func homeWidgetContent(fromInternalhomeWidgetContent content: GomaModels.HomeWidgetContent) -> HomeWidgetContent {
        return HomeWidgetContent(
            alertBanner: content.alertBanner != nil ? Self.alertBanner(fromInternalAlertBanner: content.alertBanner!) : nil,
            banners: Self.banners(fromInternalBanners: content.banners ?? []),
            carouselEvents: Self.events(fromInternalCarouselEvents: content.carouselEvents ?? []),
            topImageEvents: Self.events(fromInternalEvents: content.topImageEvents ?? []),
            proChoiceEvents: Self.events(fromInternalEvents: content.proChoiceEvents ?? []),
            boostedOddsEvents: Self.events(fromInternalBoostedOddsEvents: content.boostedOddsEvents ?? []),
            heroCardEvents: Self.events(fromInternalHeroCardEvents: content.heroCardEvents ?? []),
            stories: Self.stories(fromInternalStories: content.stories ?? []),
            news: Self.newsItems(fromInternalNewsItems: content.news ?? [])
        )
    }

}
