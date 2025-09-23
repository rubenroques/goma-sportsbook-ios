//
//  CasinoBannerData.swift
//  BetssonCameroonApp
//
//  Created by Claude on 22/09/2025.
//

import Foundation
import UIKit

/// App-level model representing a casino promotional banner
public struct CasinoBannerData: Identifiable, Equatable, Hashable {
    /// Unique identifier
    public let id: String

    /// Type of casino banner (e.g., "game", "promotion", "info")
    public let type: String

    /// Main title/message text
    public let title: String?

    /// Subtitle/description text
    public let subtitle: String?

    /// Associated casino game ID (if banner promotes a specific game)
    public let casinoGameId: String?

    /// Call to action text for button
    public let ctaText: String?

    /// Call to action URL for navigation
    public let ctaUrl: String?

    /// Image URL for banner background
    public let imageUrl: String?

    /// Whether this banner should be visible
    public let isVisible: Bool

    public init(
        id: String,
        type: String,
        title: String? = nil,
        subtitle: String? = nil,
        casinoGameId: String? = nil,
        ctaText: String? = nil,
        ctaUrl: String? = nil,
        imageUrl: String? = nil,
        isVisible: Bool = true
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.casinoGameId = casinoGameId
        self.ctaText = ctaText
        self.ctaUrl = ctaUrl
        self.imageUrl = imageUrl
        self.isVisible = isVisible
    }
}

// MARK: - Navigation Action
extension CasinoBannerData {
    /// Determines the primary action for this banner
    public var primaryAction: CasinoBannerAction {
        // Priority: Casino game > CTA URL > No action
        if let gameId = casinoGameId, !gameId.isEmpty {
            return .launchGame(gameId: gameId)
        } else if let url = ctaUrl, !url.isEmpty {
            return .openURL(url: url)
        } else {
            return .none
        }
    }
}

/// Available actions for casino banner interaction
public enum CasinoBannerAction: Equatable {
    case launchGame(gameId: String)
    case openURL(url: String)
    case none
}