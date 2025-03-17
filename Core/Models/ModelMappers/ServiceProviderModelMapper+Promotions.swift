//
//  ServiceProviderModelMapper+Promotions.swift
//  Sportsbook
//
//  Created by André Lascas on 17/03/2025.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func promotionInfo(fromInternalPromotionInfo promotionInfo: ServicesProvider.PromotionInfo) -> PromotionInfo {
        
        let staticPage = self.staticPage(fromInternalStaticPage: promotionInfo.staticPage)
        
        return PromotionInfo(id: promotionInfo.id, title: promotionInfo.title, slug: promotionInfo.slug, sortOrder: promotionInfo.sortOrder, platform: promotionInfo.platform, status: promotionInfo.status, userType: promotionInfo.userType, listDisplayNote: promotionInfo.listDisplayNote, listDisplayDescription: promotionInfo.listDisplayDescription, listDisplayImageUrl: promotionInfo.listDisplayImageUrl, startDate: promotionInfo.startDate, endDate: promotionInfo.endDate, staticPage: staticPage)
    }
    
    static func staticPage(fromInternalStaticPage staticPage: ServicesProvider.StaticPage) -> StaticPage {
        
        let sections = staticPage.sections.map { self.sectionBlock(fromInternalSectionBlock: $0)
        }
        let terms = staticPage.terms.map { self.termItem(fromInternalTermItem: $0)
        }
        
        return StaticPage(title: staticPage.title, slug: staticPage.slug, headerTitle: staticPage.headerTitle, headerImageUrl: staticPage.headerImageUrl, isActive: staticPage.isActive, usedForPromotions: staticPage.usedForPromotions, platform: staticPage.platform, status: staticPage.status, userType: staticPage.userType, startDate: staticPage.startDate, endDate: staticPage.endDate, sections: sections, terms: terms)
    }
    
    static func sectionBlock(fromInternalSectionBlock section: ServicesProvider.SectionBlock) -> SectionBlock {
        
        let textBlock = section.text.map { self.textBlock(fromInternalTextBlock: $0)
        }
        
        let listBlock = section.list.map { self.listBlock(fromInternalListBlock: $0)
        }
        
        return SectionBlock(
            type: section.type,
            sortOrder: section.sortOrder,
            isActive: section.isActive,
            banner: section.banner.map { bannerBlock(fromInternalBannerBlock: $0)
            },
            text: textBlock,
            list: listBlock
        )
    }

    static func bannerBlock(fromInternalBannerBlock banner: ServicesProvider.BannerBlock) -> BannerBlock {
        
        return BannerBlock(
            bannerLinkUrl: banner.bannerLinkUrl,
            bannerType: banner.bannerType,
            bannerLinkTarget: banner.bannerLinkTarget,
            imageUrl: banner.imageUrl
        )
    }

    static func textBlock(fromInternalTextBlock text: ServicesProvider.TextBlock) -> TextBlock {
        let contentBlocks = text.contentBlocks.map { textContentBlock(fromInternalTextContentBlock: $0)
        }
        
        return TextBlock(
            sectionHighlighted: text.sectionHighlighted,
            contentBlocks: contentBlocks,
            itemIcon: text.itemIcon
        )
    }

    static func textContentBlock(fromInternalTextContentBlock content: ServicesProvider.TextContentBlock) -> TextContentBlock {
        
        let bulletedListItems = content.bulletedListItems?.map { bulletedListItem(fromInternalBulletedListItem: $0)
        }
        
        return TextContentBlock(
            title: content.title,
            blockType: content.blockType,
            description: content.description,
            image: content.image,
            video: content.video,
            buttonURL: content.buttonURL,
            buttonText: content.buttonText,
            buttonTarget: content.buttonTarget,
            bulletedListItems: bulletedListItems
        )
    }

    static func bulletedListItem(fromInternalBulletedListItem item: ServicesProvider.BulletedListItem) -> BulletedListItem {
        return BulletedListItem(text: item.text)
    }

    static func listBlock(fromInternalListBlock list: ServicesProvider.ListBlock) -> ListBlock {
        let items = list.items.map { textBlock(fromInternalTextBlock: $0) }
        
        return ListBlock(
            title: list.title,
            genericListItemsIcon: list.genericListItemsIcon,
            items: items
        )
    }

    static func termItem(fromInternalTermItem term: ServicesProvider.TermItem) -> TermItem {
        return TermItem(
            label: term.label,
            sortOrder: term.sortOrder
        )
    }
}
