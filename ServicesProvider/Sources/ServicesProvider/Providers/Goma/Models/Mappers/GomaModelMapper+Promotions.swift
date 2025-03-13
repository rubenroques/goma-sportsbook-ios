//
//  GomaModelMapper+Promotions.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

extension GomaModelMapper {

    // MARK: - Model mapper Home Template
    static func homeTemplate(fromInternalHomeTemplate template: GomaModels.HomeTemplate) -> HomeTemplate {
        let widgets = template.widgets.compactMap { internalWidget -> HomeWidget? in
            // Initialize using the failable initializer
            return HomeWidget(
                id: String(internalWidget.id),
                type: internalWidget.type,
                description: internalWidget.description,
                userState: internalWidget.userType,
                sortOrder: internalWidget.sortOrder,
                orientation: internalWidget.orientation)
        }

        return HomeTemplate(
            id: String(template.id),
            type: template.type,
            widgets: widgets)
    }

    // MARK: - Alert Banner
    static func alertBanners(fromInternalAlertBanners banners: [GomaModels.AlertBanner]) -> [AlertBanner] {
        return banners.map { alertBanner(fromInternalAlertBanner: $0) }
    }

    static func alertBanner(fromInternalAlertBanner alertBanner: GomaModels.AlertBanner) -> AlertBanner {
        return AlertBanner(
            id: String(alertBanner.id),
            title: alertBanner.title,
            subtitle: alertBanner.subtitle,
            ctaText: alertBanner.ctaText,
            ctaUrl: alertBanner.ctaUrl,
            platform: alertBanner.platform,
            status: alertBanner.status,
            startDate: alertBanner.startDate != nil ? DateFormatter.iso8601.date(from: alertBanner.startDate!) : nil,
            endDate: alertBanner.endDate != nil ? DateFormatter.iso8601.date(from: alertBanner.endDate!) : nil,
            userType: alertBanner.userType)
    }

    // MARK: - Banners
    static func banners(fromInternalBanners banners: [GomaModels.Banner]) -> [Banner] {
        return banners.map { banner(fromInternalBanner: $0) }
    }

    static func banner(fromInternalBanner banner: GomaModels.Banner) -> Banner {
        return Banner(
            id: String(banner.id),
            title: banner.title,
            subtitle: banner.subtitle,
            ctaText: banner.ctaText,
            ctaUrl: banner.ctaUrl,
            platform: banner.platform,
            status: banner.status,
            startDate: banner.startDate,
            endDate: banner.endDate,
            userType: banner.userType,
            imageUrl: banner.imageUrl
        )
    }

    // MARK: - Sport Banners

    static func carouselEvents(fromInternalCarouselEvents carousels: GomaModels.CarouselEvents) -> CarouselEvents {
        return carousels.map { carouselEvent(fromInternalCarouselEvent: $0) }
    }

    static func carouselEvent(fromInternalCarouselEvent carousel: GomaModels.CarouselEvent) -> CarouselEvent {
        return CarouselEvent(
            id: String(carousel.id),
            eventId: carousel.eventId,
            eventMarketId: carousel.eventMarketId,
            ctaUrl: carousel.ctaUrl,
            imageUrl: carousel.imageUrl)
    }

    // MARK: - Boosted Odds Banners

    static func boostedOddsPointers(fromInternalBoostedOddsPointers pointers: GomaModels.BoostedOddsPointers) -> BoostedOddsPointers {
        return pointers.map { boostedOddsPointer(fromInternalBoostedOddsPointer: $0) }
    }

    static func boostedOddsPointer(fromInternalBoostedOddsPointer pointer: GomaModels.BoostedOddsPointer) -> BoostedOddsPointer {
        return BoostedOddsPointer(id: String(pointer.id),
                                  eventId: pointer.eventId,
                                  eventMarketId: pointer.eventMarketId,
                                  boostedEventMarketId: pointer.boostedEventMarketId)
    }

    // MARK: - Hero Cards

    static func heroCardPointers(fromInternalHeroCardPointers cards: [GomaModels.HeroCardPointer]) -> [HeroCardPointer] {
        return cards.map { heroCardPointer(fromInternalHeroCardPointer: $0) }
    }

    static func heroCardPointer(fromInternalHeroCardPointer heroCard: GomaModels.HeroCardPointer) -> HeroCardPointer {
        return HeroCardPointer.init(
            id: String(heroCard.id),
            eventId: heroCard.eventId,
            eventMarketIds: heroCard.eventMarketIds,
            imageUrl: heroCard.imageUrl)
    }

    // MARK: - Stories

    static func stories(fromInternalStories stories: [GomaModels.Story]) -> [Story] {
        return stories.map { story(fromInternalStory: $0) }
    }

    static func story(fromInternalStory story: GomaModels.Story) -> Story {
        return Story(
            id: String(story.id),
            title: story.title,
            mediaType: story.mediaType,
            ctaText: story.ctaText,
            ctaUrl: story.ctaUrl,
            platform: story.platform,
            status: story.status,
            startDate: story.startDate,
            endDate: story.endDate,
            userType: story.userType,
            mediaUrl: story.mediaUrl,
            iconUrl: story.iconUrl)
    }

    // MARK: - News

    static func newsItems(fromInternalNewsItems items: [GomaModels.NewsItem]) -> NewsItems {
        return items.map { newsItem(fromInternalNewsItem: $0) }
    }

    static func newsItem(fromInternalNewsItem item: GomaModels.NewsItem) -> NewsItem {
        return NewsItem(
            id: String(item.id),
            title: item.title,
            subtitle: item.subtitle,
            content: item.content,
            author: item.author,
            publishedDate: item.publishedDate,
            status: item.status,
            imageUrl: item.imageUrl,
            tags: item.tags
        )
    }

    // MARK: - Pro Choices

    static func proChoiceCardPointers(fromInternalProChoiceCardPointers pointers: GomaModels.ProChoiceCardPointers) -> ProChoiceCardPointers {
        return pointers.map { proChoiceCardPointer(fromInternalProChoiceCardPointers: $0) }
    }

    static func proChoiceCardPointer(fromInternalProChoiceCardPointers pointer: GomaModels.ProChoiceCardPointer) -> ProChoiceCardPointer {
        return ProChoiceCardPointer(
            eventId: pointer.eventId,
            eventMarketId: pointer.eventMarketId,
            imageUrl: pointer.imageUrl
        )
    }


    // MARK: - TopImageCardPointer AKA Highlighted Event Mapper
    static func topImageCardPointers(fromInternaTopImageCardPointers pointers: GomaModels.TopImageCardPointers) -> TopImageCardPointers {
        return pointers.map { topImageCardPointer(fromInternaTopImageCardPointer: $0) }
    }

    static func topImageCardPointer(fromInternaTopImageCardPointer pointer: GomaModels.TopImageCardPointer) -> TopImageCardPointer {
        return TopImageCardPointer(
            eventId: pointer.eventId,
            eventMarketId: pointer.eventMarketId,
            imageUrl: pointer.imageUrl
        )
    }

    static func topCompetitionPointers(fromInternalTopCompetitionPointers pointers: GomaModels.TopCompetitionPointers) -> TopCompetitionPointers {
        return pointers.map { topCompetitionPointer(fromInternalTopCompetitionPointer: $0) }
    }

    static func topCompetitionPointer(fromInternalTopCompetitionPointer pointer: GomaModels.TopCompetitionPointer) -> TopCompetitionPointer {
        return TopCompetitionPointer.init(id: pointer, name: "", competitionId: pointer)
    }

}
