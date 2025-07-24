//
//  ProChoice.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public typealias ProChoiceCardPointers = [ProChoiceCardPointer]

/// Expert betting tip
public struct ProChoiceCardPointer: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier based on the sport event
    public var id: String { eventId }

    /// Sport event identifier
    public let eventId: String

    /// Sport event market identifier
    public let eventMarketId: String

    /// Image URL for the pro choice
    public let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case eventId = "sport_event_id"
        case eventMarketId = "sport_event_market_id"
        case imageUrl = "image_url"
    }

    /// Public initializer
    /// - Parameters:
    ///   - sportEventId: Sport event identifier
    ///   - sportEventMarketId: Sport event market identifier
    ///   - imageUrl: Image URL for the pro choice
    public init(
        eventId: String,
        eventMarketId: String,
        imageUrl: String?
    ) {
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.imageUrl = imageUrl
    }
}

public struct ProChoiceMarketCard: Identifiable, Equatable, Hashable, Codable {
    public var id: String {
        return market.id
    }
    public var market: Market
    public var enabledSelectionsCount: Int
    public var promotionImageURl: String?

    public init(market: Market, enabledSelectionsCount: Int, promotionImageURl: String?) {
        self.market = market
        self.enabledSelectionsCount = enabledSelectionsCount
        self.promotionImageURl = promotionImageURl
    }

    public static func == (lhs: ProChoiceMarketCard, rhs: ProChoiceMarketCard) -> Bool {
        // Compare all properties for equality
        return lhs.market == rhs.market &&
        lhs.enabledSelectionsCount == rhs.enabledSelectionsCount
    }
}
