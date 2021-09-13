//
//  Odd.swift
//  Sportsbook
//
//  Created by André Lascas on 10/09/2021.
//

import Foundation

enum Odd: Decodable {
    case match(Match)
    case bettingOffer(BettingOffer)
    case outcome(Outcome)
    case marketOutcomeRelation(MarketOutcomeRelation)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type = "_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let type = try? container.decode(OddType.self, forKey: .type) else {
            self = .unknown
            return
        }

        let objectContainer = try decoder.singleValueContainer()

        switch type {
        case .match:
            let match = try objectContainer.decode(Match.self)
            self = .match(match)
        case .bettingOffer:
            let bettingOffer = try objectContainer.decode(BettingOffer.self)
            self = .bettingOffer(bettingOffer)
        case .outcome:
            let outcome = try objectContainer.decode(Outcome.self)
            self = .outcome(outcome)
        case .marketOutcomeRelation:
            let marketOutcomeRelation = try objectContainer.decode(MarketOutcomeRelation.self)
            self = .marketOutcomeRelation(marketOutcomeRelation)
        case .unknown:
            self = .unknown
        }
    }
}

enum OddType: String, Decodable {
    case match = "MATCH"
    case bettingOffer = "BETTING_OFFER"
    case outcome = "OUTCOME"
    case marketOutcomeRelation = "MARKET_OUTCOME_RELATION"
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try container.decode(String.self)
        self = OddType(rawValue: type) ?? .unknown
    }
}
