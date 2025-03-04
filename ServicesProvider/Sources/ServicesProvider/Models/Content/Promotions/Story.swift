//
//  Story.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public typealias Stories = [Story]

/// Ephemeral promotional story (similar to social media stories)
public struct Story: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier
    public let id: String

    /// Story title
    public let title: String

    /// Media type (image or video)
    public let mediaType: String

    /// Call to action text
    public let ctaText: String?

    /// Call to action URL
    public let ctaUrl: String?

    /// Platform compatibility
    public let platform: String?

    /// Status of the story
    public let status: String?

    /// Start date when story should be displayed
    public let startDate: Date?

    /// End date when story should stop being displayed
    public let endDate: Date?

    /// User type the story is for
    public let userType: String?

    /// Media URL for the story content
    public let mediaUrl: String?

    /// Icon URL for the story thumbnail
    public let iconUrl: String?

    /// Coding keys for JSON mapping
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case mediaType = "media_type"
        case ctaText = "cta_text"
        case ctaUrl = "cta_url"
        case platform
        case status
        case startDate = "start_date"
        case endDate = "end_date"
        case userType = "user_type"
        case mediaUrl = "media_url"
        case iconUrl = "icon_url"
    }
}
