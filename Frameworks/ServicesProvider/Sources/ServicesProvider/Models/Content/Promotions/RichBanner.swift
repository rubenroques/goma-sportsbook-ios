//
//  RichBanner.swift
//
//
//  Created on: Today
//

import Foundation

public typealias RichBanners = [RichBanner]

/// Unified banner type supporting info, casino game, and sport event banners
/// Used by both casino carousel and sport banner endpoints
public enum RichBanner: Identifiable, Equatable, Hashable {
    case info(InfoBanner)
    case casinoGame(CasinoGameBanner)
    case sportEvent(SportEventBanner)

    public var id: String {
        switch self {
        case .info(let banner): return banner.id
        case .casinoGame(let banner): return banner.id
        case .sportEvent(let banner): return banner.id
        }
    }
}

// MARK: - Info Banner

/// Information/promotional banner with CTA
/// Shared between casino and sport banner endpoints
public struct InfoBanner: Identifiable, Equatable, Hashable, Codable {
    public let id: String
    public let title: String?
    public let subtitle: String?
    public let ctaText: String?
    public let ctaUrl: String?
    public let ctaTarget: String?
    public let imageUrl: String?

    public init(
        id: String,
        title: String?,
        subtitle: String?,
        ctaText: String?,
        ctaUrl: String?,
        ctaTarget: String?,
        imageUrl: String?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.ctaUrl = ctaUrl
        self.ctaTarget = ctaTarget
        self.imageUrl = imageUrl
    }
}

// MARK: - Sport Event Banner

/// Sport event banner with enriched event data
/// Contains full event details wrapped in ImageHighlightedContent
public struct SportEventBanner: Identifiable, Equatable, Hashable, Codable {
    public let id: String

    /// Enriched event content with promotional image
    public let eventContent: ImageHighlightedContent<Event>

    /// Market betting type identifier (e.g., "69" for 1X2)
    public let marketBettingTypeId: String?

    /// Market event part identifier (e.g., "3" for full time)
    public let marketEventPartId: String?

    public init(
        id: String,
        eventContent: ImageHighlightedContent<Event>,
        marketBettingTypeId: String?,
        marketEventPartId: String?
    ) {
        self.id = id
        self.eventContent = eventContent
        self.marketBettingTypeId = marketBettingTypeId
        self.marketEventPartId = marketEventPartId
    }
}

// MARK: - Convenience Accessors

public extension SportEventBanner {

    /// The underlying event
    var event: Event {
        return eventContent.content
    }

    /// The promotional image URL for the event
    var imageUrl: String? {
        return eventContent.imageURL
    }

    /// Number of promoted markets/outcomes to display
    var promotedChildCount: Int {
        return eventContent.promotedChildCount
    }
}
