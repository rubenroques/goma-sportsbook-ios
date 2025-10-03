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
        
        let startDate = alertBanner.startDate.flatMap { Self.isoDateFormatter.date(from: $0) }
        let endDate = alertBanner.endDate.flatMap { Self.isoDateFormatter.date(from: $0) }
        
        return AlertBanner(
            id: String(alertBanner.id),
            title: alertBanner.title,
            subtitle: alertBanner.subtitle,
            ctaText: alertBanner.ctaText,
            ctaUrl: alertBanner.ctaUrl,
            platform: alertBanner.platform,
            status: alertBanner.status,
            startDate: startDate,
            endDate: endDate,
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

    static func carouselEventPointers(fromInternalCarouselEventPointers carousels: GomaModels.CarouselEventPointers) -> CarouselEventPointers {
        return carousels.map { carouselEventPointer(fromInternalCarouselEventPointer: $0) }
    }

    static func carouselEventPointer(fromInternalCarouselEventPointer carousel: GomaModels.CarouselEventPointer) -> CarouselEventPointer {
        return CarouselEventPointer(
            id: String(carousel.id),
            eventId: carousel.eventId,
            eventMarketId: carousel.eventMarketId,
            ctaUrl: carousel.ctaUrl,
            imageUrl: carousel.imageUrl)
    }

    // MARK: - Casino Carousel Banners

    static func casinoCarouselPointers(fromInternalCasinoCarouselPointers carousels: GomaModels.CasinoCarouselPointers) -> CasinoCarouselPointers {
        return carousels.map { casinoCarouselPointer(fromInternalCasinoCarouselPointer: $0) }
    }

    static func casinoCarouselPointer(fromInternalCasinoCarouselPointer carousel: GomaModels.CasinoCarouselPointer) -> CasinoCarouselPointer {
        return CasinoCarouselPointer(
            id: String(carousel.id),
            type: carousel.type,
            title: carousel.title,
            subtitle: carousel.subtitle,
            casinoGameId: carousel.casinoGameId,
            ctaText: carousel.ctaText,
            ctaUrl: carousel.ctaUrl,
            ctaTarget: carousel.ctaTarget,
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
            iconUrl: story.iconUrl,
            backgroundImageUrl: story.backgroundImageUrl)
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
    
    static func promotionInfo(fromInternalPromotionInfo promotionInfo: GomaModels.PromotionInfo) -> PromotionInfo {
        
        let staticPage = self.staticPage(fromInternalStaticPage: promotionInfo.staticPage ?? nil)
        
        let startDate = GomaProvider.parseGomaDateString(promotionInfo.startDate ?? "")
        
        let endDate = GomaProvider.parseGomaDateString(promotionInfo.endDate ?? "")
        
        let categories = promotionInfo.categories?.map { self.promotionCategory(fromInternalPromotionCategory: $0) }
        
        return PromotionInfo(
            id: promotionInfo.id,
            title: promotionInfo.title,
            slug: promotionInfo.slug,
            tag: promotionInfo.tag,
            hasReadMoreButton: promotionInfo.hasReadMoreButton,
            ctaText: promotionInfo.ctaText,
            ctaUrl: promotionInfo.ctaUrl,
            ctaTarget: promotionInfo.ctaTarget,
            sortOrder: promotionInfo.sortOrder,
            platform: promotionInfo.platform,
            status: promotionInfo.status,
            userType: promotionInfo.userType,
            listDisplayNote: promotionInfo.listDisplayNote,
            listDisplayDescription: promotionInfo.listDisplayDescription,
            listDisplayImageUrl: promotionInfo.listDisplayImageUrl,
            startDate: startDate,
            endDate: endDate,
            staticPageSlug: promotionInfo.staticPageSlug,
            staticPage: staticPage,
            categories: categories
        )
    }
    
    static func staticPage(fromInternalStaticPage staticPage: GomaModels.StaticPage?) -> StaticPage? {
        
        if let staticPage {
            let sections = staticPage.sections.map { self.sectionBlock(fromInternalSectionBlock: $0)
            }
            
            var terms: TermItem? = nil
            
            if let staticPageTerms = staticPage.terms {
                terms = self.termItem(fromInternalTermItem: staticPageTerms)
            }
            
            let startDate = GomaProvider.parseGomaDateString(staticPage.startDate ?? "")
            
            let endDate = GomaProvider.parseGomaDateString(staticPage.endDate ?? "")
            
            return StaticPage(title: staticPage.title, slug: staticPage.slug, headerImageUrl: staticPage.headerImageUrl, isActive: staticPage.isActive, usedForPromotions: staticPage.usedForPromotions, platform: staticPage.platform, status: staticPage.status, userType: staticPage.userType, startDate: startDate, endDate: endDate, sections: sections, terms: terms)
        }
        
        return nil
    }
    
    static func sectionBlock(fromInternalSectionBlock section: GomaModels.SectionBlock) -> SectionBlock {
        
        let textBlock = section.text.map { self.textBlock(fromInternalTextBlock: $0)
        }
        
        let listBlock = section.list.map { self.listBlock(fromInternalListBlock: $0)
        }
        
        return SectionBlock(
            type: SectionPromoType(rawValue: section.type),
            sortOrder: section.sortOrder,
            isActive: section.isActive,
            banner: section.banner.map { bannerBlock(fromInternalBannerBlock: $0)
            },
            text: textBlock,
            list: listBlock
        )
    }

    static func bannerBlock(fromInternalBannerBlock banner: GomaModels.BannerBlock) -> BannerBlock {
        
        return BannerBlock(
            bannerLinkUrl: banner.bannerLinkUrl,
            bannerType: BannerPromoType(rawValue: banner.bannerType),
            bannerLinkTarget: banner.bannerLinkTarget,
            imageUrl: banner.imageUrl,
            videoUrl: banner.videoUrl
        )
    }

    static func textBlock(fromInternalTextBlock text: GomaModels.TextBlock) -> TextBlock {
        let contentBlocks = text.contentBlocks.map { textContentBlock(fromInternalTextContentBlock: $0)
        }
        
        return TextBlock(
            sectionHighlighted: text.sectionHighlighted,
            contentBlocks: contentBlocks,
            itemIcon: text.itemIcon
        )
    }

    static func textContentBlock(fromInternalTextContentBlock content: GomaModels.TextContentBlock) -> TextContentBlock {
        
        let bulletedListItems = content.bulletedListItems?.map { bulletedListItem(fromInternalBulletedListItem: $0)
        }
        
        return TextContentBlock(
            title: content.title,
            blockType: BlockPromoType(rawValue: content.blockType),
            description: content.description,
            image: content.image,
            video: content.video,
            buttonURL: content.buttonURL,
            buttonText: content.buttonText,
            buttonTarget: content.buttonTarget,
            bulletedListItems: bulletedListItems
        )
    }

    static func bulletedListItem(fromInternalBulletedListItem item: GomaModels.BulletedListItem) -> BulletedListItem {
        return BulletedListItem(text: item.text)
    }

    static func listBlock(fromInternalListBlock list: GomaModels.ListBlock) -> ListBlock {
        let items = list.items.map { textBlock(fromInternalTextBlock: $0) }
        
        return ListBlock(
            title: list.title,
            genericListItemsIcon: list.genericListItemsIcon,
            items: items
        )
    }

    static func termItem(fromInternalTermItem term: GomaModels.TermItem) -> TermItem {

        let bulletedListItems = term.bulletedListItems?.map { self.bulletedListItem(fromInternalBulletedListItem: $0)
        }

        return TermItem(displayType: TermsDisplayType(rawValue: term.displayType), richText: term.richText, bulletedListItems: bulletedListItems, sortOrder: term.sortOrder)
    }
    
    static func promotionCategory(fromInternalPromotionCategory category: GomaModels.PromotionCategory) -> PromotionCategory {
        return PromotionCategory(
            id: category.id,
            name: category.name
        )
    }
    
    // MARK: - Rich Banners

    /// Maps an array of internal rich banners to public rich banners with enrichment
    /// - Parameters:
    ///   - internalBanners: Internal GomaModels.RichBanner array from API
    ///   - casinoGames: Array of casino games for enriching casino game banners
    ///   - events: Array of events for enriching sport event banners
    /// - Returns: Array of enriched public RichBanner
    static func richBanners(
        fromInternalRichBanners internalBanners: GomaModels.RichBanners,
        casinoGames: [CasinoGame],
        events: [Event]
    ) -> RichBanners {
        return internalBanners.compactMap { internalBanner in
            return richBanner(
                fromInternalRichBanner: internalBanner,
                casinoGames: casinoGames,
                events: events
            )
        }
    }

    /// Maps a single internal rich banner to public rich banner with enrichment
    /// - Parameters:
    ///   - internalBanner: Internal GomaModels.RichBanner from API
    ///   - casinoGames: Array of casino games for enriching casino game banners
    ///   - events: Array of events for enriching sport event banners
    /// - Returns: Enriched public RichBanner, or nil if enrichment data is missing
    static func richBanner(
        fromInternalRichBanner internalBanner: GomaModels.RichBanner,
        casinoGames: [CasinoGame],
        events: [Event]
    ) -> RichBanner? {
        switch internalBanner {
        case .info(let data):
            let infoBanner = InfoBanner(
                id: String(data.id),
                title: data.title,
                subtitle: data.subtitle,
                ctaText: data.ctaText,
                ctaUrl: data.ctaUrl,
                ctaTarget: data.ctaTarget,
                imageUrl: data.imageUrl
            )
            return .info(infoBanner)

        case .casinoGame(let data):
            // Lookup casino game by ID
            guard let casinoGame = casinoGames.first(where: { $0.id == data.casinoGameId }) else {
                return nil // Skip if game not found
            }

            let bannerMetadata = CasinoGameBanner.BannerMetadata(
                bannerId: String(data.id),
                type: "game",
                title: data.title,
                subtitle: data.subtitle,
                ctaText: data.ctaText,
                ctaUrl: data.ctaUrl,
                ctaTarget: data.ctaTarget,
                customImageUrl: data.imageUrl
            )

            let casinoGameBanner = CasinoGameBanner(
                casinoGame: casinoGame,
                bannerMetadata: bannerMetadata
            )
            return .casinoGame(casinoGameBanner)

        case .sportEvent(let data):
            // Lookup event by ID
            guard let event = events.first(where: { $0.id == data.sportEventId }) else {
                return nil // Skip if event not found
            }

            let imageHighlightedContent = ImageHighlightedContent(
                content: event,
                promotedChildCount: 1,
                imageURL: data.imageUrl
            )

            let sportEventBanner = SportEventBanner(
                id: String(data.id),
                eventContent: imageHighlightedContent,
                marketBettingTypeId: data.marketBettingTypeId,
                marketEventPartId: data.marketEventPartId
            )
            return .sportEvent(sportEventBanner)
        }
    }
}
