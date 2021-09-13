//
//  Event.swift
//  Sportsbook
//
//  Created by André Lascas on 09/09/2021.
//

import Foundation

enum Event: Decodable {
    case match(Match)
    case tournament(Tournament)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type = "_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let type = try? container.decode(EventType.self, forKey: .type) else {
            self = .unknown
            return
        }

        let objectContainer = try decoder.singleValueContainer()

        switch type {
        case .match:
            let match = try objectContainer.decode(Match.self)
            self = .match(match)
        case .tournament:
            let tournament = try objectContainer.decode(Tournament.self)
            self = .tournament(tournament)
        case .unknown:
            self = .unknown
        }
    }
}

enum EventType: String, Decodable {
    case match = "MATCH"
    case tournament = "TOURNAMENT"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try container.decode(String.self)
        self = EventType(rawValue: type) ?? .unknown
    }
}
