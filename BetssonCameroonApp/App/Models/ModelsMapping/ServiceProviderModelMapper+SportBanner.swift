//
//  ServiceProviderModelMapper+SportBanner.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import ServicesProvider
import GomaUI
import UIKit

extension ServiceProviderModelMapper {

    // MARK: - Sport Banner Mapping

    /// Convert ServicesProvider CarouselEventPointer + Event to app-level SportBannerData
    static func sportBannerData(fromCarouselEventPointer pointer: CarouselEventPointer, event: Event) -> SportBannerData? {
        // Map ServicesProvider.Event to app's Match model first
        guard let match = self.match(fromEvent: event) else {
            return nil // Skip if event can't be mapped to match
        }

        return SportBannerData(
            bannerId: pointer.id,
            eventId: pointer.eventId,
            eventMarketId: pointer.eventMarketId,
            ctaUrl: pointer.ctaUrl,
            customImageUrl: pointer.imageUrl,
            match: match,
            isVisible: true // CMS controls visibility, assume visible if returned
        )
    }

    /// Convert ImageHighlightedContent<Event> to app-level SportBannerData
    static func sportBannerData(fromImageHighlightedContent highlighted: ImageHighlightedContent<Event>) -> SportBannerData? {
        let event = highlighted.content

        // Map ServicesProvider.Event to app's Match model first
        guard let match = self.match(fromEvent: event) else {
            return nil // Skip if event can't be mapped to match
        }

        return SportBannerData(
            bannerId: event.id, // Use event ID as banner ID
            eventId: event.id,
            eventMarketId: "1", // Default to main market
            ctaUrl: nil, // No external URL for ImageHighlightedContent mapping
            customImageUrl: highlighted.imageURL, // Use CMS-provided image URL from ImageHighlightedContent
            match: match,
            isVisible: true // Assume visible if returned by getCarouselEvents
        )
    }

    /// Convert app-level SportBannerData array to BannerType array for TopBannerSliderView
    static func bannerTypes(fromSportBannerData banners: [SportBannerData],
                          onBannerAction: @escaping (SportBannerAction) -> Void) -> [BannerType] {
        return banners.compactMap { bannerData in
            let sportBannerViewModel = SportBannerViewModel(bannerData: bannerData)
            // Set up the callback for this banner
            sportBannerViewModel.onBannerAction = onBannerAction

            switch bannerData.bannerType {
            case .matchBanner:
                if let matchViewModel = sportBannerViewModel.createBannerViewModel() as? MatchBannerViewModelProtocol {
                    return .matchBanner(matchViewModel)
                }
            case .singleButtonBanner:
                if let singleButtonViewModel = sportBannerViewModel.createBannerViewModel() as? SingleButtonBannerViewModelProtocol {
                    return .singleButton(singleButtonViewModel)
                }
            }

            return nil
        }
    }

    /// Create SportBannerAction from banner data (for callback handling)
    static func sportBannerAction(fromBannerData bannerData: SportBannerData) -> SportBannerAction {
        if let ctaUrl = bannerData.ctaUrl, !ctaUrl.isEmpty {
            return .openExternalUrl(url: ctaUrl)
        } else if !bannerData.eventMarketId.isEmpty {
            return .openMarket(eventId: bannerData.eventId, marketId: bannerData.eventMarketId)
        } else {
            return .openMatchDetails(eventId: bannerData.eventId)
        }
    }
}
