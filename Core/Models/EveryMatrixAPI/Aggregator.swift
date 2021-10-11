//
//  Aggregator.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

struct Aggregator: Decodable {

    var content: [Content]
    var messageType: ContentType

    enum ContentType: Decodable {
        case update
        case initialDump
    }

    enum CodingKeys: String, CodingKey {
        case content = "records"
        case messageType = "messageType"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let messageTypeString = try container.decode(String.self, forKey: .messageType)
        if messageTypeString == "UPDATE" {
            messageType = .initialDump
        }
        else if messageTypeString == "INITIAL_DUMP" {
            messageType = .update
        }
        else {
            messageType = .update
        }
        self.content = try container.decode([Content].self, forKey: .content)
    }

}

enum Content: Decodable {

    case match(EveryMatrix.Match)
    case tournament(Tournament)
    case event(Event)
    case bettingOffer(BettingOffer)
    case betOutcome(BetOutcome)
    case market(Market)
    case mainMarket(Market)
    case marketOutcomeRelation(MarketOutcomeRelation)
    case location(Location)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type = "_type"
    }

    enum ContentTypeKey: String, Decodable {

        case match = "MATCH"
        case tournament = "TOURNAMENT"
        case event = "EVENT"
        case bettingOffer = "BETTING_OFFER"
        case betOutcome = "OUTCOME"
        case market = "MARKET"
        case mainMarket = "MAIN_MARKET"
        case marketOutcomeRelation = "MARKET_OUTCOME_RELATION"
        case location = "LOCATION"
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(String.self)
            if let contentTypeKey = ContentTypeKey(rawValue: type) {
                self = contentTypeKey
            }
            else {
                print("Aggregator ContentTypeKey unknown [\(type)]")
                self = .unknown
            }
        }
    }


    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let type = try? container.decode(ContentTypeKey.self, forKey: .type) else {
            self = .unknown
            return
        }

        let objectContainer = try decoder.singleValueContainer()

        switch type {
        case .match:
            let match = try objectContainer.decode(EveryMatrix.Match.self)
            self = .match(match)
        case .tournament:
            let tournament = try objectContainer.decode(Tournament.self)
            self = .tournament(tournament)
        case .event:
            let event = try objectContainer.decode(Event.self)
            self = .event(event)
        case .bettingOffer:
            let bettingOffer = try objectContainer.decode(BettingOffer.self)
            self = .bettingOffer(bettingOffer)
        case .betOutcome:
            let outcome = try objectContainer.decode(BetOutcome.self)
            self = .betOutcome(outcome)
        case .market:
            let market = try objectContainer.decode(Market.self)
            self = .market(market)
        case .mainMarket:
            var market = try objectContainer.decode(Market.self)
            market.setAsMainMarket()
            self = .mainMarket(market)
        case .marketOutcomeRelation:
            let marketOutcomeRelation = try objectContainer.decode(MarketOutcomeRelation.self)
            self = .marketOutcomeRelation(marketOutcomeRelation)
        case .location:
            let location = try objectContainer.decode(Location.self)
            self = .location(location)
        case .unknown:
            self = .unknown
        }
    }
}
