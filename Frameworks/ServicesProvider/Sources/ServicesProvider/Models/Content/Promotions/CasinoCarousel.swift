//
//  CasinoCarousel.swift
//
//
//  Created on: Today
//

import Foundation

public typealias CasinoCarouselPointers = [CasinoCarouselPointer]
/// Casino-related promotional carousel banner
public struct CasinoCarouselPointer: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier
    public let id: String

    /// Type of casino carousel item (e.g., "game", "info")
    public let type: String

    /// Title of the casino carousel item
    public let title: String?

    /// Subtitle/description of the casino carousel item
    public let subtitle: String?

    /// Associated casino game ID
    public let casinoGameId: String?

    /// Call to action text
    public let ctaText: String?

    /// Call to action URL
    public let ctaUrl: String?

    /// Call to action target (e.g., "_blank")
    public let ctaTarget: String?

    /// Image URL for the carousel item
    public let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case subtitle
        case casinoGameId = "casino_game_id"
        case ctaText = "cta_text"
        case ctaUrl = "cta_url"
        case ctaTarget = "cta_target"
        case imageUrl = "image_url"
    }

    public init(id: String,
                type: String,
                title: String?,
                subtitle: String?,
                casinoGameId: String?,
                ctaText: String?,
                ctaUrl: String?,
                ctaTarget: String?,
                imageUrl: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.casinoGameId = casinoGameId
        self.ctaText = ctaText
        self.ctaUrl = ctaUrl
        self.ctaTarget = ctaTarget
        self.imageUrl = imageUrl
    }
}