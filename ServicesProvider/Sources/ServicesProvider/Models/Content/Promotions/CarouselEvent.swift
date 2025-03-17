//
//  SportBanner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public typealias CarouselEventPointers = [CarouselEventPointer]
/// Sport-related promotional banner
public struct CarouselEventPointer: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier
    public let id: String

    /// Associated sport event ID
    public let eventId: String

    /// Sport event market ID
    public let eventMarketId: String

    /// Call to action URL
    public let ctaUrl: String?

    /// Image URL for the banner
    public let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "sport_event_id"
        case eventMarketId = "sport_event_market_id"
        case ctaUrl = "cta_url"
        case imageUrl = "image_url"
    }

    public init(id: String,
                eventId: String,
                eventMarketId: String,
                ctaUrl: String?,
                imageUrl: String?) {
        self.id = id
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.ctaUrl = ctaUrl
        self.imageUrl = imageUrl
    }
}
