//
//  BoostedOddsBanner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

/// Banner showcasing boosted odds for a sport event
public struct BoostedOddsBanner: Identifiable, Equatable, Hashable, Codable {
    /// Unique identifier
    public let id: String

    /// Client identifier
    public let clientId: String?

    /// Banner title
    public let title: String

    /// Banner subtitle
    public let subtitle: String?

    /// Platform compatibility
    public let platform: String?

    /// Status of the banner
    public let status: String?

    /// Image URL for the banner
    public let imageUrl: String?

    /// Coding keys for JSON mapping
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case clientId = "client_id"
        case title = "title"
        case subtitle = "subtitle"
        case platform = "platform"
        case status = "status"
        case imageUrl = "image_url"
    }

    init(id: String,
         clientId: String?,
         title: String,
         subtitle: String?,
         platform: String?,
         status: String?,
         imageUrl: String?) {
        self.id = id
        self.clientId = clientId
        self.title = title
        self.subtitle = subtitle
        self.platform = platform
        self.status = status
        self.imageUrl = imageUrl
    }
}

