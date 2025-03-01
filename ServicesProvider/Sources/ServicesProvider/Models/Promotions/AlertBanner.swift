//
//  AlertBanner.swift
//  
//
//  Created on: May 15, 2024
//

import Foundation

/// Banner alert that appears at the top of the app
/// This unified model incorporates requirements from both Goma and SportRadar providers
public struct AlertBanner: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier for the alert banner
    /// Using String type for maximum compatibility across providers
    public let id: String
    
    /// Alert title - the main heading of the banner
    public let title: String
    
    /// Optional subtitle or secondary text
    public let subtitle: String?
    
    /// Optional detailed message content
    public let content: String?
    
    /// Background color in hex format (e.g. "#FF0000")
    /// May be nil if the provider doesn't support custom colors
    public let backgroundColor: String?
    
    /// Text color in hex format (e.g. "#FFFFFF")
    /// May be nil if the provider doesn't support custom colors
    public let textColor: String?
    
    /// Call-to-action button text
    /// Used by some providers to specify button text
    public let callToActionText: String?
    
    /// Type of action when banner is tapped (e.g. "url", "deeplink")
    /// Used to determine how to handle user interaction
    public let actionType: String?
    
    /// Target URL or deep link for the action
    /// Where the user should be directed when tapping the banner
    public let actionTarget: String?
    
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
    
    /// Optional image URL for the banner
    public let imageUrl: URL?
    
    /// Public initializer with default values for optional parameters
    /// This comprehensive initializer supports creation from both provider types
    /// - Parameters:
    ///   - id: Unique identifier (String for maximum compatibility)
    ///   - title: Alert title
    ///   - subtitle: Optional subtitle text
    ///   - content: Optional detailed message content
    ///   - backgroundColor: Optional background color in hex format
    ///   - textColor: Optional text color in hex format
    ///   - callToActionText: Optional button text
    ///   - actionType: Optional action type (url, deeplink, etc)
    ///   - actionTarget: Optional target URL or deep link path
    ///   - isActive: Whether the banner is currently active (default: true)
    ///   - startDate: Optional scheduling start date
    ///   - endDate: Optional scheduling end date
    ///   - status: Optional status description beyond active/inactive
    ///   - imageUrl: Optional image URL
    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        content: String? = nil,
        backgroundColor: String? = nil,
        textColor: String? = nil,
        callToActionText: String? = nil,
        actionType: String? = nil,
        actionTarget: String? = nil,
        isActive: Bool = true,
        startDate: Date? = nil,
        endDate: Date? = nil,
        status: String? = nil,
        imageUrl: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.callToActionText = callToActionText
        self.actionType = actionType
        self.actionTarget = actionTarget
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
        case content
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case callToActionText = "cta_text"
        case actionType = "action_type"
        case actionTarget = "action_target"
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
} 