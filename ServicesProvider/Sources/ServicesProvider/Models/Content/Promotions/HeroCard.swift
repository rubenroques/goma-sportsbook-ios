//
//  HeroCard.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public typealias HeroCards = [HeroCard]

/// Feature card displayed prominently in the app
public struct HeroCard: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier
    public let id: String

    /// Associated sport event ID
    public let eventId: String?

    /// Market IDs related to the sport event
    public let eventMarketIds: [String]?

    /// Image URL for the card
    public let imageUrl: String?

    /// Coding keys for JSON parsing
    private enum CodingKeys: String, CodingKey {
        case id
        case eventId = "sport_event_id"
        case eventMarketIds = "sport_event_market_ids"
        case imageUrl = "image_url"
    }

    public init(id: String, eventId: String?, eventMarketIds: [String]?, imageUrl: String?) {
        self.id = id
        self.eventId = eventId
        self.eventMarketIds = eventMarketIds
        self.imageUrl = imageUrl
    }
}

