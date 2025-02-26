//
//  GomaModelMapper+Promotions.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

extension GomaModelMapper {

    // MARK: - Home Template
    static func homeTemplate(fromInternalHomeTemplate template: GomaModels.HomeTemplateResponse) -> HomeTemplate {
        let sections = template.sections.map { section in
            TemplateSection(type: section.type, title: section.title, source: section.source)
        }

        return HomeTemplate(
            id: template.id,
            clientId: template.clientId,
            title: template.title,
            platform: template.platform,
            sections: sections)
    }

    // MARK: - Alert Banner
    static func alertBanner(fromInternalAlertBanner banner: GomaModels.AlertBannerData) -> AlertBanner {
        return AlertBanner(
            id: String(banner.id),
            title: banner.title,
            subtitle: nil,
            content: banner.content,
            backgroundColor: banner.backgroundColor,
            textColor: banner.textColor,
            callToActionText: nil,
            actionType: banner.actionType,
            actionTarget: banner.actionTarget,
            isActive: banner.status.lowercased() == "active",
            startDate: isoDateFormatter.date(from: banner.startDate),
            endDate: isoDateFormatter.date(from: banner.endDate),
            status: banner.status,
            imageUrl: banner.imageUrl != nil ? URL(string: banner.imageUrl!) : nil)
    }

    // MARK: - Banners

    static func banners(fromInternalBanners banners: [GomaModels.BannerData]) -> [Banner] {
        return banners.map { banner(fromInternalBanner: $0) }
    }

    static func banner(fromInternalBanner banner: GomaModels.BannerData) -> Banner {
        return Banner(
            id: String(banner.id),
            title: banner.title,
            subtitle: banner.subtitle,
            actionType: banner.actionType,
            actionTarget: banner.actionTarget,
            callToActionText: nil,
            isActive: banner.status.lowercased() == "active",
            startDate: isoDateFormatter.date(from: banner.startDate),
            endDate: isoDateFormatter.date(from: banner.endDate),
            status: banner.status,
            imageUrl: banner.imageUrl != nil ? URL(string: banner.imageUrl!) : nil
        )
    }

    // MARK: - Sport Banners

    static func sportBanners(fromInternalSportBanners banners: [GomaModels.SportBannerData]) -> [SportBanner] {
        return banners.map { sportBanner(fromInternalSportBanner: $0) }
    }

    static func sportBanner(fromInternalSportBanner banner: GomaModels.SportBannerData) -> SportBanner {
        return SportBanner(
            id: banner.id,
            title: banner.title,
            subtitle: banner.subtitle,
            sportEventId: banner.sportEventId,
            startDate: isoDateFormatter.date(from: banner.startDate) ?? Date(),
            endDate: isoDateFormatter.date(from: banner.endDate) ?? Date(),
            status: banner.status,
            imageUrl: banner.imageUrl != nil ? URL(string: banner.imageUrl!) : nil,
            event: banner.event != nil ? sportEventSummary(fromInternalSportEvent: banner.event!) : nil
        )
    }

    static func sportEventSummary(fromInternalSportEvent event: GomaModels.SportEventData) -> SportEventSummary {
        return SportEventSummary(
            id: event.id,
            sportId: event.sportId,
            homeTeamId: event.homeTeamId,
            awayTeamId: event.awayTeamId,
            dateTime: isoDateFormatter.date(from: event.dateTime) ?? Date(),
            homeTeam: event.homeTeam.name,
            awayTeam: event.awayTeam.name,
            homeTeamLogo: event.homeTeam.logo != nil ? URL(string: event.homeTeam.logo!) : nil,
            awayTeamLogo: event.awayTeam.logo != nil ? URL(string: event.awayTeam.logo!) : nil
        )
    }

    // MARK: - Boosted Odds Banners

    static func boostedOddsBanners(fromInternalBoostedOddsBanners banners: [GomaModels.BoostedOddsBannerData]) -> [BoostedOddsBanner] {
        return banners.map { boostedOddsBanner(fromInternalBoostedOddsBanner: $0) }
    }

    static func boostedOddsBanner(fromInternalBoostedOddsBanner banner: GomaModels.BoostedOddsBannerData) -> BoostedOddsBanner {
        return BoostedOddsBanner(
            id: banner.id,
            title: banner.title,
            originalOdd: banner.originalOdd,
            boostedOdd: banner.boostedOdd,
            sportEventId: banner.sportEventId,
            startDate: isoDateFormatter.date(from: banner.startDate) ?? Date(),
            endDate: isoDateFormatter.date(from: banner.endDate) ?? Date(),
            status: banner.status,
            imageUrl: banner.imageUrl != nil ? URL(string: banner.imageUrl!) : nil,
            event: banner.event != nil ? sportEventSummary(fromInternalSportEvent: banner.event!) : nil
        )
    }

    // MARK: - Hero Cards

    static func heroCards(fromInternalHeroCards cards: [GomaModels.HeroCardData]) -> [HeroCard] {
        return cards.map { heroCard(fromInternalHeroCard: $0) }
    }

    static func heroCard(fromInternalHeroCard card: GomaModels.HeroCardData) -> HeroCard {
        return HeroCard(
            id: card.id,
            title: card.title,
            subtitle: card.subtitle,
            actionType: card.actionType,
            actionTarget: card.actionTarget,
            startDate: isoDateFormatter.date(from: card.startDate) ?? Date(),
            endDate: isoDateFormatter.date(from: card.endDate) ?? Date(),
            status: card.status,
            imageUrl: card.imageUrl != nil ? URL(string: card.imageUrl!) : nil,
            eventId: card.eventId
        )
    }

    // MARK: - Stories

    static func stories(fromInternalStories stories: [GomaModels.StoryData]) -> [Story] {
        return stories.map { story(fromInternalStory: $0) }
    }

    static func story(fromInternalStory story: GomaModels.StoryData) -> Story {
        return Story(
            id: story.id,
            title: story.title,
            content: story.content,
            actionType: story.actionType,
            actionTarget: story.actionTarget,
            startDate: isoDateFormatter.date(from: story.startDate) ?? Date(),
            endDate: isoDateFormatter.date(from: story.endDate) ?? Date(),
            status: story.status,
            imageUrl: story.imageUrl != nil ? URL(string: story.imageUrl!) : nil,
            duration: story.duration
        )
    }

    // MARK: - News

    static func newsItems(fromInternalNewsItems items: [GomaModels.NewsItemData]) -> [NewsItem] {
        return items.map { newsItem(fromInternalNewsItem: $0) }
    }

    static func newsItem(fromInternalNewsItem item: GomaModels.NewsItemData) -> NewsItem {
        return NewsItem(
            id: item.id,
            title: item.title,
            subtitle: item.subtitle,
            content: item.content,
            author: item.author,
            publishedDate: isoDateFormatter.date(from: item.publishedDate) ?? Date(),
            status: item.status,
            imageUrl: item.imageUrl != nil ? URL(string: item.imageUrl!) : nil,
            tags: item.tags ?? []
        )
    }

    // MARK: - Pro Choices

    static func proChoices(fromInternalProChoices choices: [GomaModels.ProChoiceData]) -> [ProChoice] {
        return choices.map { proChoice(fromInternalProChoice: $0) }
    }

    static func proChoice(fromInternalProChoice choice: GomaModels.ProChoiceData) -> ProChoice {
        return ProChoice(
            id: choice.id,
            title: choice.title,
            tipster: tipster(fromInternalTipster: choice.tipster),
            event: eventSummary(fromInternalEventSummary: choice.event),
            selection: selection(fromInternalSelection: choice.selection),
            reasoning: choice.reasoning
        )
    }

    static func tipster(fromInternalTipster tipster: GomaModels.ProChoiceData.TipsterData) -> Tipster {
        return Tipster(
            id: tipster.id,
            name: tipster.name,
            winRate: tipster.winRate,
            avatar: tipster.avatar != nil ? URL(string: tipster.avatar!) : nil
        )
    }

    static func eventSummary(fromInternalEventSummary event: GomaModels.ProChoiceData.EventSummaryData) -> EventSummary {
        return EventSummary(
            id: event.id,
            homeTeam: event.homeTeam,
            awayTeam: event.awayTeam,
            dateTime: isoDateFormatter.date(from: event.dateTime) ?? Date()
        )
    }

    static func selection(fromInternalSelection selection: GomaModels.ProChoiceData.SelectionData) -> Selection {
        return Selection(
            marketName: selection.marketName,
            outcomeName: selection.outcomeName,
            odds: selection.odds
        )
    }
}
