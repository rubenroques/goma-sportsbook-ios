//
//  ServiceProviderModelMapper+AlertBanner.swift
//  Sportsbook
//
//  Created on: May 15, 2024
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {

    static func alertBannerInfo(fromAlertBanner alertBanner: AlertBanner) -> AlertBannerInfo {
        return AlertBannerInfo(
            id: alertBanner.id,
            title: alertBanner.title,
            subtitle: alertBanner.subtitle,
            ctaText: alertBanner.ctaText,
            ctaUrl: alertBanner.ctaUrl,
            platform: alertBanner.platform,
            status: alertBanner.status,
            startDate: alertBanner.startDate,
            endDate: alertBanner.endDate,
            userType: alertBanner.userType
        )
    }

} 