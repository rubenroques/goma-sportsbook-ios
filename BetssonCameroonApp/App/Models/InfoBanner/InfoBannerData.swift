//
//  InfoBannerData.swift
//  BetssonCameroonApp
//
//  Created by Claude on 03/10/2025.
//

import Foundation

/// App-level model representing an informational/promotional banner
public struct InfoBannerData: Identifiable, Equatable, Hashable {
    /// Unique identifier
    public let id: String

    /// Main title/message text
    public let title: String?

    /// Subtitle/description text
    public let subtitle: String?

    /// Call to action text for button
    public let ctaText: String?

    /// Call to action URL for navigation
    public let ctaUrl: String?

    /// Call to action target (e.g., "_blank", "_self")
    public let ctaTarget: String?

    /// Image URL for banner background
    public let imageUrl: String?

    /// Whether this banner should be visible
    public let isVisible: Bool

    public init(
        id: String,
        title: String? = nil,
        subtitle: String? = nil,
        ctaText: String? = nil,
        ctaUrl: String? = nil,
        ctaTarget: String? = nil,
        imageUrl: String? = nil,
        isVisible: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.ctaUrl = ctaUrl
        self.ctaTarget = ctaTarget
        self.imageUrl = imageUrl
        self.isVisible = isVisible
    }
}

// MARK: - Navigation Action
extension InfoBannerData {
    /// Determines the primary action for this banner
    public var primaryAction: InfoBannerAction {
        if let url = ctaUrl, !url.isEmpty {
            return .openURL(url: url, target: ctaTarget)
        } else {
            return .none
        }
    }
}

/// Available actions for info banner interaction
public enum InfoBannerAction: Equatable {
    case openURL(url: String, target: String?)
    case none
}
