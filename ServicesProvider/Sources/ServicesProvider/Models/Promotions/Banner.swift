//
//  Banner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

/// Promotional banner displayed in the app
/// This unified model incorporates requirements from both Goma and SportRadar providers
public struct Banner: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier for the banner
    /// Using String type for maximum compatibility across providers
    public let id: String

    /// Banner title - the main heading
    public let title: String

    /// Optional subtitle or secondary text
    public let subtitle: String?

    /// Type of action when banner is tapped (e.g. "url", "deeplink")
    /// Used to determine how to handle user interaction
    public let actionType: String?

    /// Target URL or deep link for the action
    /// Where the user should be directed when tapping the banner
    public let actionTarget: String?

    /// Call-to-action button text
    /// Used by some providers to specify button text
    public let callToActionText: String?

    /// Whether the banner is currently active/visible
    public let isActive: Bool

    /// Start date when banner should begin being displayed
    /// May be nil if the provider doesn't support scheduling
    public let startDate: Date?

    /// End date when banner should stop being displayed
    /// May be nil if the provider doesn't support scheduling
    public let endDate: Date?

    /// Status of the banner (e.g. "active", "draft", "archived")
    /// Additional state information beyond simple active/inactive
    public let status: String?

    /// Image URL for the banner
    public let imageUrl: URL?

    /// Public initializer with default values for optional parameters
    /// This comprehensive initializer supports creation from both provider types
    /// - Parameters:
    ///   - id: Unique identifier (String for maximum compatibility)
    ///   - title: Banner title
    ///   - subtitle: Optional subtitle text
    ///   - actionType: Optional action type (url, deeplink, etc)
    ///   - actionTarget: Optional target URL or deep link path
    ///   - callToActionText: Optional button text
    ///   - isActive: Whether the banner is currently active (default: true)
    ///   - startDate: Optional scheduling start date
    ///   - endDate: Optional scheduling end date
    ///   - status: Optional status description beyond active/inactive
    ///   - imageUrl: Optional image URL
    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        actionType: String? = nil,
        actionTarget: String? = nil,
        callToActionText: String? = nil,
        isActive: Bool = true,
        startDate: Date? = nil,
        endDate: Date? = nil,
        status: String? = nil,
        imageUrl: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.actionType = actionType
        self.actionTarget = actionTarget
        self.callToActionText = callToActionText
        self.isActive = isActive
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.imageUrl = imageUrl
    }

    /// Coding keys for JSON serialization/deserialization
    /// Ensures compatibility with API responses
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case actionType = "action_type"
        case actionTarget = "action_target"
        case callToActionText = "cta_text"
        case isActive = "is_active"
        case startDate = "start_date"
        case endDate = "end_date"
        case status
        case imageUrl = "image_url"
    }

    // MARK: - Identifiable Conformance

    /// Identifier for Identifiable protocol
    /// Required for SwiftUI integration
    public var identifier: ID { id }

    // MARK: - Helper Methods

    /// Indicates if the banner is currently valid for display based on its date range
    /// Returns true if the current date is between startDate and endDate
    /// If startDate or endDate are nil, they are not considered in the calculation
    public var isInDateRange: Bool {
        let now = Date()
        let afterStart = startDate.map { now >= $0 } ?? true
        let beforeEnd = endDate.map { now <= $0 } ?? true
        return afterStart && beforeEnd
    }
}