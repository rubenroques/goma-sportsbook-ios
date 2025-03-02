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
            startDate: alertBanner.startDate,
            endDate: alertBanner.endDate,
            userType: alertBanner.userType)

    }

    // MARK: - Banners
    static func banners(fromInternalBanners banners: [GomaModels.Banner]) -> [Banner] {
        return banners.map { banner(fromInternalBanner: $0) }
    }

    static func banner(fromInternalBanner banner: GomaModels.Banner) -> Banner {
        return Banner(
            id: banner.id,
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

    static func boostedOddsBanners(fromInternalBoostedOddsBanners banners: [GomaModels.BoostedOddsBanner]) -> [BoostedOddsBanner] {
        return banners.map { boostedOddsBanner(fromInternalBoostedOddsBanner: $0) }
    }

    static func boostedOddsBanner(fromInternalBoostedOddsBanner banner: GomaModels.BoostedOddsBanner) -> BoostedOddsBanner {
        return BoostedOddsBanner(
            id: String(banner.id),
            clientId: banner.clientId != nil ? String(banner.clientId!) : nil,
            title: banner.title,
            subtitle: banner.subtitle,
            platform: banner.platform,
            status: banner.status,
            imageUrl: banner.imageUrl)
    }

    // MARK: - Hero Cards

    static func heroCards(fromInternalHeroCards cards: [GomaModels.HeroCard]) -> [HeroCard] {
        return cards.map { heroCard(fromInternalHeroCard: $0) }
    }

    static func heroCard(fromInternalHeroCard heroCard: GomaModels.HeroCard) -> HeroCard {
        return HeroCard.init(
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

    static func newsItems(fromInternalNewsItems items: [GomaModels.NewsItem]) -> [NewsItem] {
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

    static func proChoices(fromInternalProChoices choices: [GomaModels.ProChoice]) -> [ProChoice] {
        return choices.map { proChoice(fromInternalProChoice: $0) }
    }

    static func proChoice(fromInternalProChoice choice: GomaModels.ProChoice) -> ProChoice {
        return ProChoice(
            eventId: choice.eventId,
            eventMarketId: choice.eventMarketId,
            imageUrl: choice.imageUrl
        )
    }
}
