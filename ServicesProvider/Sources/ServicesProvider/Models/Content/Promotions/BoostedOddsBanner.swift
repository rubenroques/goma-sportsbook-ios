//
//  BoostedOddsBanner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public typealias BoostedOddsBanners = [BoostedOddsBanner]

/// Banner showcasing boosted odds for a sport event
public struct BoostedOddsBanner: Identifiable, Equatable, Hashable, Codable {

    public var id: String
    public var eventId: String
    public var eventMarketId: String
    public var title: String?
    public var imageUrl: String?

    public init(id: String, eventId: String, eventMarketId: String, title: String? = nil, imageUrl: String? = nil) {
        self.id = id
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.title = title
        self.imageUrl = imageUrl
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.eventMarketId = try container.decode(String.self, forKey: .eventMarketId)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
    }
    
}

