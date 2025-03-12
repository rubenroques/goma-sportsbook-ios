//
//  ServiceProviderModelMapper+Scores.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func bannerInfo(fromBanner banner: Banner) -> BannerInfo {
        let specialAction: BannerSpecialAction = banner.ctaUrl != nil ?
            .callToAction(url: banner.ctaUrl!, text: banner.ctaText ?? "") : .none

        return BannerInfo(
            id: banner.id,
            title: banner.title,
            subtitle: banner.subtitle,
            ctaText: banner.ctaText,
            ctaUrl: banner.ctaUrl,
            imageURL: banner.imageUrl?.absoluteString,
            userType: banner.userType,
            specialAction: specialAction
        )
    }
    
}
