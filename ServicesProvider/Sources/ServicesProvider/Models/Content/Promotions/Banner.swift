//
//  Banner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

/// Promotional banner displayed in the app
/// This unified model incorporates requirements from both Goma and SportRadar providers
public typealias Banners = [Banner]

public struct Banner: Identifiable, Equatable, Hashable, Codable {
    
    /// Unique identifier for the banner
    /// Using String type for maximum compatibility across providers
    public let id: String

    /// Banner title - the main heading
    public let title: String

    /// Optional subtitle or secondary text
    public let subtitle: String?

    /// Call-to-action button text
    /// Used by some providers to specify button text
    public let ctaText: String?

    /// Target URL or deep link for the action
    /// Where the user should be directed when tapping the banner
    public let ctaUrl: String?

    /// Platform for the banner
    public let platform: String?

    /// Status of the banner (e.g. "active", "draft", "archived")
    /// Additional state information beyond simple active/inactive
    public let status: String?

    /// Start date when banner should begin being displayed
    /// May be nil if the provider doesn't support scheduling
    public let startDate: Date?

    /// End date when banner should stop being displayed
    /// May be nil if the provider doesn't support scheduling
    public let endDate: Date?

    /// User type for the banner
    public let userType: String?

    /// Image URL for the banner
    public let imageUrl: URL?

    /// Coding keys for JSON serialization/deserialization
    /// Ensures compatibility with API responses
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case ctaText = "cta_text"
        case ctaUrl = "cta_url"
        case platform
        case status
        case startDate = "start_date"
        case endDate = "end_date"
        case userType = "user_type"
        case imageUrl = "image_url"
    }

    public init(id: String,
                title: String,
                subtitle: String?,
                ctaText: String?,
                ctaUrl: String?,
                platform: String?,
                status: String?,
                startDate: Date?,
                endDate: Date?,
                userType: String?,
                imageUrl: URL?)
    {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.ctaUrl = ctaUrl
        self.platform = platform
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.userType = userType
        self.imageUrl = imageUrl
    }

}
