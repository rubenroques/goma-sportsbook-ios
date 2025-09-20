//
//  CasinoGameBanner.swift
//
//
//  Created on: Today
//

import Foundation

public typealias CasinoGameBanners = [CasinoGameBanner]

/// A casino game enriched with promotional banner metadata
/// Combines full casino game data with CMS promotional fields
public struct CasinoGameBanner: Identifiable, Equatable, Hashable, Codable {

    /// The full casino game object with all game details
    public let casinoGame: CasinoGame

    /// Promotional banner metadata from CMS
    public let bannerMetadata: BannerMetadata

    /// Identifiable conformance - uses casino game ID
    public var id: String { casinoGame.id }

    public init(casinoGame: CasinoGame, bannerMetadata: BannerMetadata) {
        self.casinoGame = casinoGame
        self.bannerMetadata = bannerMetadata
    }

    /// Promotional banner metadata from casino carousel CMS
    public struct BannerMetadata: Equatable, Hashable, Codable {
        /// Banner ID from CMS
        public let bannerId: String

        /// Type of banner (e.g., "game", "info")
        public let type: String

        /// Banner title (may override game name)
        public let title: String?

        /// Banner subtitle/description
        public let subtitle: String?

        /// Call to action text
        public let ctaText: String?

        /// Call to action URL
        public let ctaUrl: String?

        /// Call to action target (e.g., "_blank")
        public let ctaTarget: String?

        /// Custom banner image URL (may override game thumbnail)
        public let customImageUrl: String?

        public init(
            bannerId: String,
            type: String,
            title: String? = nil,
            subtitle: String? = nil,
            ctaText: String? = nil,
            ctaUrl: String? = nil,
            ctaTarget: String? = nil,
            customImageUrl: String? = nil
        ) {
            self.bannerId = bannerId
            self.type = type
            self.title = title
            self.subtitle = subtitle
            self.ctaText = ctaText
            self.ctaUrl = ctaUrl
            self.ctaTarget = ctaTarget
            self.customImageUrl = customImageUrl
        }
    }
}

// MARK: - Convenience Accessors
public extension CasinoGameBanner {

    /// The display title - uses banner title if available, otherwise game name
    var displayTitle: String {
        return bannerMetadata.title ?? casinoGame.name
    }

    /// The display image URL - uses custom banner image if available, otherwise game thumbnail
    var displayImageUrl: String {
        return bannerMetadata.customImageUrl ?? casinoGame.thumbnail
    }

    /// Whether this banner has custom promotional content
    var hasCustomContent: Bool {
        return bannerMetadata.title != nil ||
               bannerMetadata.subtitle != nil ||
               bannerMetadata.customImageUrl != nil
    }

    /// Whether this banner has a call-to-action
    var hasCallToAction: Bool {
        return bannerMetadata.ctaText != nil && bannerMetadata.ctaUrl != nil
    }
}
