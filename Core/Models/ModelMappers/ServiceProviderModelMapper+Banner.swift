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
        return BannerInfo(
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
            imageURL: banner.imageUrl?.absoluteString
        )
    }

}
