//
//  ServiceProviderModelMapper+RichBanners.swift
//  BetssonCameroonApp
//
//  Created by Claude on 03/10/2025.
//

import Foundation
import ServicesProvider
import GomaUI
import UIKit

extension ServiceProviderModelMapper {

    // MARK: - Rich Banner Mapping

    /// Convert ServicesProvider RichBanners to GomaUI BannerType array
    /// This is the main entry point for converting rich banners from the network layer to UI layer
    static func bannerTypes(fromRichBanners richBanners: RichBanners) -> [BannerType] {
        print("[BANNER-DEBUG] 🗺️ Mapper: Converting \(richBanners.count) RichBanners to BannerTypes...")

        let bannerTypes = richBanners.compactMap { richBanner in
            return bannerType(fromRichBanner: richBanner)
        }

        print("[BANNER-DEBUG] 🗺️ Mapper: Produced \(bannerTypes.count) BannerTypes (filtered from \(richBanners.count) input)")
        return bannerTypes
    }

    /// Convert a single RichBanner to BannerType
    private static func bannerType(fromRichBanner richBanner: RichBanner) -> BannerType? {
        switch richBanner {
        case .info(let infoBanner):
            print("[BANNER-DEBUG] 🗺️ Mapper: Converting .info banner (id: \(infoBanner.id))")
            return infoBannerType(fromInfoBanner: infoBanner)

        case .casinoGame(let casinoGameBanner):
            print("[BANNER-DEBUG] 🗺️ Mapper: Converting .casinoGame banner (id: \(casinoGameBanner.bannerMetadata.bannerId))")
            return casinoBannerType(fromCasinoGameBanner: casinoGameBanner)

        case .sportEvent(let sportEventBanner):
            print("[BANNER-DEBUG] 🗺️ Mapper: Converting .sportEvent banner (id: \(sportEventBanner.eventContent.content.name ?? ""))")
            return matchBannerType(fromSportEventBanner: sportEventBanner)
        }
    }

    // MARK: - Info Banner Conversion

    /// Convert ServicesProvider InfoBanner to BannerType.info
    private static func infoBannerType(fromInfoBanner infoBanner: InfoBanner) -> BannerType? {
        // Convert to app-level InfoBannerData
        let infoBannerData = InfoBannerData(
            id: infoBanner.id,
            title: infoBanner.title,
            subtitle: infoBanner.subtitle,
            ctaText: infoBanner.ctaText,
            ctaUrl: infoBanner.ctaUrl,
            ctaTarget: infoBanner.ctaTarget,
            imageUrl: infoBanner.imageUrl,
            isVisible: true // CMS controls visibility, assume visible if returned
        )

        // Convert to GomaUI SingleButtonBannerData
        let singleButtonData = singleButtonBannerData(fromInfoBannerData: infoBannerData)

        // Create ViewModel
        let viewModel = InfoBannerViewModel(bannerData: infoBannerData, displayData: singleButtonData)

        print("[BANNER-DEBUG] 🗺️ Mapper: ✅ Successfully created BannerType.info")
        return .info(viewModel)
    }

    /// Convert InfoBannerData to GomaUI SingleButtonBannerData
    private static func singleButtonBannerData(fromInfoBannerData bannerData: InfoBannerData) -> SingleButtonBannerData {
        // Determine message text priority: title > subtitle > fallback
        let messageText: String = {
            if let title = bannerData.title, !title.isEmpty {
                return title
            } else if let subtitle = bannerData.subtitle, !subtitle.isEmpty {
                return subtitle
            } else {
                return "Promotional Banner" // Fallback message
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
                backgroundColor: StyleProvider.Color.highlightPrimary,
                textColor: StyleProvider.Color.textPrimary,
                cornerRadius: 8.0
            )
        }()

        return SingleButtonBannerData(
            type: "info_banner",
            isVisible: bannerData.isVisible,
            backgroundImageURL: normalizedImageURL,
            messageText: messageText,
            buttonConfig: buttonConfig
        )
    }

    // MARK: - Casino Banner Conversion

    /// Convert ServicesProvider CasinoGameBanner to BannerType.casino
    private static func casinoBannerType(fromCasinoGameBanner casinoGameBanner: CasinoGameBanner) -> BannerType? {
        let metadata = casinoGameBanner.bannerMetadata
        let casinoGame = casinoGameBanner.casinoGame

        // Convert to app-level CasinoBannerData
        let casinoBannerData = CasinoBannerData(
            id: metadata.bannerId,
            type: metadata.type,
            title: metadata.title,
            subtitle: metadata.subtitle,
            casinoGameId: casinoGame.id,
            ctaText: metadata.ctaText,
            ctaUrl: metadata.ctaUrl,
            imageUrl: metadata.customImageUrl ?? casinoGame.thumbnail, // Prefer custom banner image
            isVisible: true
        )

        // Convert to GomaUI SingleButtonBannerData
        let singleButtonData = singleButtonBannerData(fromCasinoBannerData: casinoBannerData)

        // Create ViewModel
        let viewModel = CasinoBannerViewModel(bannerData: casinoBannerData, displayData: singleButtonData)

        print("[BANNER-DEBUG] 🗺️ Mapper: ✅ Successfully created BannerType.casino")
        return .casino(viewModel)
    }


    // MARK: - Match Banner Conversion

    /// Convert ServicesProvider SportEventBanner to BannerType.match
    private static func matchBannerType(fromSportEventBanner sportEventBanner: SportEventBanner) -> BannerType? {
        let imageHighlightedEvent = sportEventBanner.eventContent
        let event = imageHighlightedEvent.content

        // Map ServicesProvider.Event to app's Match model
        guard let match = ServiceProviderModelMapper.match(fromEvent: event) else {
            print("[BANNER-DEBUG] 🗺️ Mapper: ❌ Failed to convert Event to Match (event id: \(event.id))")
            return nil // Skip if event can't be mapped to match
        }

        // Create MatchBannerViewModel with the match and CMS image URL
        let viewModel = MatchBannerViewModel(match: match, imageURL: imageHighlightedEvent.imageURL)

        print("[BANNER-DEBUG] 🗺️ Mapper: ✅ Successfully created BannerType.match (match id: \(match.id))")
        return .match(viewModel)
    }
}
