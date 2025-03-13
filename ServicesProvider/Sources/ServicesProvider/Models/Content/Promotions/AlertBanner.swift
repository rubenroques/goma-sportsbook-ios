//
//  AlertBanner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

/// Alert banner displayed in the app
/// This model represents alert banners from the API
public typealias AlertBanners = [AlertBanner]

public struct AlertBanner: Identifiable, Equatable, Hashable, Codable {

    /// Unique identifier for the alert banner
    /// Using String type for maximum compatibility across providers
    public let id: String
    
    /// Alert banner title - the main heading
    public let title: String
    
    /// Optional subtitle or secondary text
    public let subtitle: String?
    
    /// Call-to-action button text
    /// Used to specify button text
    public let ctaText: String?
    
    /// Target URL or deep link for the action
    /// Where the user should be directed when tapping the alert banner
    public let ctaUrl: String?
    
    /// Platform for the alert banner
    public let platform: String?
    
    /// Status of the alert banner (e.g. "published", "draft")
    /// Additional state information
    public let status: String?
    
    /// Start date when alert banner should begin being displayed
    public let startDate: Date?
    
    /// End date when alert banner should stop being displayed
    public let endDate: Date?
    
    /// User type for the alert banner
    public let userType: String?

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
                userType: String?)
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
    }
}
