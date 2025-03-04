//
//  BoostedOddsBanner.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public typealias BoostedOddsPointers = [BoostedOddsPointer]

/// Banner showcasing boosted odds for a sport event
public struct BoostedOddsPointer: Identifiable, Equatable, Hashable, Codable {

    public var id: String
    public var eventId: String
    public var eventMarketId: String
    public var boostedEventMarketId: String
    
    public init(id: String, eventId: String, eventMarketId: String, boostedEventMarketId: String) {
        self.id = id
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.boostedEventMarketId = boostedEventMarketId
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.eventId = try container.decode(String.self, forKey: .eventId)
        self.eventMarketId = try container.decode(String.self, forKey: .eventMarketId)
        self.boostedEventMarketId = try container.decode(String.self, forKey: .boostedEventMarketId)
    }
}

