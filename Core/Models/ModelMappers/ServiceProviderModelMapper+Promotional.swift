//
//  ServiceProviderModelMapper+Scores.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {

    static func promotionalStories(
        fromServiceProviderStories stories: [ServicesProvider.Story]
    ) -> [PromotionalStory] {
        return stories.map(ServiceProviderModelMapper.promotionalStory(fromServiceProviderStory:))
    }
    
    static func promotionalStory(
        fromServiceProviderStory story: ServicesProvider.Story
    ) -> PromotionalStory {
        return PromotionalStory.init(id: story.id,
                                     buttonTitle: story.title,
                                     buttonIconUrl: story.iconUrl ?? "",
                                     buttonBackgroungImageUrl: story.backgroundImageUrl,
                                     contentMediaUrl: story.mediaUrl ?? "",
                                     ctaUrl: story.ctaUrl ?? "",
                                     ctaText: story.ctaText ?? "")
    }

    static func promotionalStories(
        fromPromotionalStories promotionalStories: [ServicesProvider.PromotionalStory]
    ) -> [PromotionalStory] {
        return promotionalStories.map(ServiceProviderModelMapper.promotionalStory(fromPromotionalStory:))
    }
    
    static func promotionalStory(fromPromotionalStory promotionalStory: ServicesProvider.PromotionalStory) -> PromotionalStory {
        return PromotionalStory.init(id: promotionalStory.id,
                                     buttonTitle: promotionalStory.title,
                                     buttonIconUrl: promotionalStory.imageUrl,
                                     buttonBackgroungImageUrl: nil,
                                     contentMediaUrl: promotionalStory.bodyText,
                                     ctaUrl: promotionalStory.linkUrl,
                                     ctaText: promotionalStory.callToActionText ?? "")
    }
    
}
