//
//  File.swift
//  
//
//  Created by Ruben Roques on 08/01/2024.
//

import Foundation

extension GomaModelMapper {
    
    static func promotionalBanners(fromBanners banners: [GomaModels.Banner]) -> [PromotionalBanner] {
        return banners.map(Self.promotionalBanner(fromBanner:))
    }
    
    static func promotionalBanner(fromBanner banner: GomaModels.Banner) -> PromotionalBanner {
        var action: BannerSpecialAction = .none
        if let url = banner.callToActionUrl, let text = banner.callToActionText {
            action = .callToAction(url: url, text: text)
        }
        
        return PromotionalBanner(id: banner.identifier,
                                 name: banner.title,
                                 bannerType: nil,
                                 imageURL: banner.imageUrl,
                                 bannerDisplay: nil,
                                 linkType: banner.callToActionUrl,
                                 location: nil,
                                 bannerContents: nil,
                                 specialAction: action)
    }
    
    static func promotionalStories(fromStories stories: [GomaModels.Story]) -> [PromotionalStory] {
        return stories.map(Self.promotionalStory(fromStory:))
    }
    
    static func promotionalStory(fromStory story: GomaModels.Story) -> PromotionalStory {
        return PromotionalStory(id: story.identifier,
                                title: story.title,
                                imageUrl: story.iconUrl,
                                linkUrl: story.callToActionUrl,
                                bodyText: story.mediaUrl, 
                                callToActionText: story.callToActionText)
    }
    
    static func alertBanners(fromAlertBanners alertBanners: [GomaModels.AlertBanner]) -> [AlertBanner] {
        return alertBanners.map(Self.alertBanner(fromAlertBanner:))
    }
    
    static func alertBanner(fromAlertBanner alertBanner: GomaModels.AlertBanner) -> AlertBanner {
        return AlertBanner(identifier: alertBanner.identifier,
                           title: alertBanner.title,
                           subtitle: alertBanner.subtitle,
                           callToActionText: alertBanner.callToActionText,
                           callToActionUrl: alertBanner.callToActionUrl,
                           isActive: (alertBanner.isActive ?? 0) == 1)
    }
    
    static func bannerAlert(fromBannerAlert bannerAlert: GomaModels.BannerAlert) -> BannerAlert {
        
        return BannerAlert(identifier: bannerAlert.identifier, title: bannerAlert.title, subtitle: bannerAlert.subtitle, ctaText: bannerAlert.callToActionText, ctaUrl: bannerAlert.callToActionUrl, isActive: bannerAlert.isActive, createdAt: bannerAlert.createdAt, updatedAt: bannerAlert.updatedAt)
    }
}
