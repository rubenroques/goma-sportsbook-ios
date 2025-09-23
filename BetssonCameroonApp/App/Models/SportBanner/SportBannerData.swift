//
//  SportBannerData.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation

/// App-level model representing sport banner data
/// Combines CMS banner metadata with real match information
struct SportBannerData {
    /// Banner identifier from CMS
    let bannerId: String

    /// Event ID from CMS pointer
    let eventId: String

    /// Event market ID from CMS pointer
    let eventMarketId: String

    /// Call-to-action URL from CMS
    let ctaUrl: String?

    /// Custom banner image URL from CMS
    let customImageUrl: String?

    /// Full match details from mapped internal model
    let match: Match

    /// Whether banner should be visible
    let isVisible: Bool

    /// Banner type for display logic
    let bannerType: SportBannerType

    init(bannerId: String,
         eventId: String,
         eventMarketId: String,
         ctaUrl: String?,
         customImageUrl: String?,
         match: Match,
         isVisible: Bool = true) {
        self.bannerId = bannerId
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.ctaUrl = ctaUrl
        self.customImageUrl = customImageUrl
        self.match = match
        self.isVisible = isVisible

        // Determine banner type based on match data
        self.bannerType = Self.determineBannerType(for: match)
    }

    /// Determine the appropriate banner type based on match characteristics
    private static func determineBannerType(for match: Match) -> SportBannerType {
        // If match has live data and is in progress, show as match banner
        if match.status.isLive {
            return .matchBanner
        }

        // If match has participants (teams), show as match banner
        if !match.homeParticipant.name.isEmpty && !match.awayParticipant.name.isEmpty {
            return .matchBanner
        }

        // Default to single button banner for competitions or other events
        return .singleButtonBanner
    }
}

/// Sport banner action for navigation handling
enum SportBannerAction {
    case openMatchDetails(eventId: String)
    case openExternalUrl(url: String)
    case openMarket(eventId: String, marketId: String)
}

/// Sport banner display types
enum SportBannerType {
    case singleButtonBanner
    case matchBanner
}
