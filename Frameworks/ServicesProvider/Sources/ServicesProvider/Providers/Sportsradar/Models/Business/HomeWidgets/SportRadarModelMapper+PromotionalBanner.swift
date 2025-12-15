//
//  File.swift
//  
//
//  Created by Ruben Roques on 30/05/2023.
//

import Foundation

extension SportRadarModelMapper {

    static func promotionalBannersResponse(fromInternalPromotionalBannersResponse internalBannerResponse: SportRadarModels.PromotionalBannersResponse)
    -> PromotionalBannersResponse {
        let promotionalBanners = internalBannerResponse.promotionalBannerItems.map({
             Self.promotionalBanner(fromInternalPromotionalBanner: $0)
        })
        return PromotionalBannersResponse(promotionalBannerItems: promotionalBanners)
    }

    static func promotionalBanner(fromInternalPromotionalBanner internalPromotionalBanner: SportRadarModels.PromotionalBanner) -> PromotionalBanner {

        var bannerSpecialAction = BannerSpecialAction.none

        if let location = internalPromotionalBanner.location {
            if location.contains("#register") {
                bannerSpecialAction = .register
            }
        }

        return PromotionalBanner(id: internalPromotionalBanner.id,
                                 name: internalPromotionalBanner.name,
                                 bannerType: internalPromotionalBanner.bannerType,
                                 imageURL: internalPromotionalBanner.imageURL,
                                 bannerDisplay: internalPromotionalBanner.bannerDisplay,
                                 linkType: internalPromotionalBanner.linkType,
                                 location: internalPromotionalBanner.location,
                                 bannerContents: internalPromotionalBanner.bannerContents,
                                 specialAction: bannerSpecialAction)
    }

}
