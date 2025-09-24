//
//  ServiceProviderModelMapper+CasinoBanner.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import ServicesProvider
import GomaUI
import UIKit

extension ServiceProviderModelMapper {

    // MARK: - Casino Banner Mapping

    /// Convert ServicesProvider CasinoCarouselPointer to app-level CasinoBannerData
    static func casinoBannerData(fromCasinoCarouselPointer pointer: CasinoCarouselPointer) -> CasinoBannerData {
        return CasinoBannerData(
            id: pointer.id,
            type: pointer.type,
            title: pointer.title,
            subtitle: pointer.subtitle,
            casinoGameId: pointer.casinoGameId,
            ctaText: pointer.ctaText,
            ctaUrl: pointer.ctaUrl,
            imageUrl: pointer.imageUrl,
            isVisible: true // CMS controls visibility, assume visible if returned
        )
    }

    /// Convert app-level CasinoBannerData to GomaUI SingleButtonBannerData
    static func singleButtonBannerData(fromCasinoBannerData bannerData: CasinoBannerData) -> SingleButtonBannerData {
        // Determine message text priority: title > subtitle > type-based fallback
        let messageText: String = {
            if let title = bannerData.title, !title.isEmpty {
                return title
            } else if let subtitle = bannerData.subtitle, !subtitle.isEmpty {
                return subtitle
            } else {
                return "Casino Promotion" // Fallback message
            }
        }()

        // Normalize image URL - fix protocol-relative URLs
        let normalizedImageURL: String? = {
            guard let imageUrl = bannerData.imageUrl else { return nil }

            // Handle protocol-relative URLs (starting with //)
            if imageUrl.hasPrefix("//") {
                return "https:" + imageUrl
            }

            // Return as-is if already complete
            return imageUrl
        }()

        // Create button config if CTA text is available
        let buttonConfig: ButtonConfig? = {
            guard let ctaText = bannerData.ctaText, !ctaText.isEmpty else {
                return nil
            }

            return ButtonConfig(
                title: ctaText,
                backgroundColor: StyleProvider.Color.primaryColor,
                textColor: StyleProvider.Color.textPrimary,
                cornerRadius: 8.0
            )
        }()

        return SingleButtonBannerData(
            type: "casino_\(bannerData.type)",
            isVisible: bannerData.isVisible,
            backgroundImageURL: normalizedImageURL,
            messageText: messageText,
            buttonConfig: buttonConfig
        )
    }

    /// Convert CasinoBannerData array to BannerType array for TopBannerSliderView
    static func bannerTypes(fromCasinoBannerData banners: [CasinoBannerData]) -> [BannerType] {
        return banners.compactMap { bannerData in
            let singleButtonData = singleButtonBannerData(fromCasinoBannerData: bannerData)
            let viewModel = CasinoBannerViewModel(bannerData: bannerData, displayData: singleButtonData)
            return .singleButton(viewModel)
        }
    }
}