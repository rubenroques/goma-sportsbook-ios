//
//  SearchV2Response.swift
//  Sportsbook
//
//  Created by André Lascas on 21/01/2022.
//

import Foundation

struct SearchV2Response: Decodable {

    var records: [Event]
    var includedData: [SearchContent]?

    enum CodingKeys: String, CodingKey {
        case records = "records"
        case includedData = "includedData"
    }

    enum SearchContent: Decodable {

        case matchInfo(EveryMatrix.MatchInfo)
        case event(Event)
        case bettingOffer(EveryMatrix.BettingOffer)
        case betOutcome(EveryMatrix.BetOutcome)
        case market(EveryMatrix.Market)
        case mainMarket(EveryMatrix.Market)
        case marketOutcomeRelation(EveryMatrix.MarketOutcomeRelation)
        case marketGroup(EveryMatrix.MarketGroup)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        enum ContentTypeKey: String, Decodable {

            case matchInfo = "EVENT_INFO"
            case event = "EVENT"
            case bettingOffer = "BETTING_OFFER"
            case betOutcome = "OUTCOME"
            case market = "MARKET"
            case mainMarket = "MAIN_MARKET"
            case marketOutcomeRelation = "MARKET_OUTCOME_RELATION"
            case marketGroup = "MARKET_GROUP"
            case unknown

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let type = try container.decode(String.self)
                if let contentTypeKey = ContentTypeKey(rawValue: type) {
                    self = contentTypeKey
                }
                else {
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
//            case .match:
//                let match = try objectContainer.decode(EveryMatrix.Match.self)
//                self = .match(match)
            case .matchInfo:
                let matchInfo = try objectContainer.decode(EveryMatrix.MatchInfo.self)
                self = .matchInfo(matchInfo)
//            case .tournament:
//                let tournament = try objectContainer.decode(EveryMatrix.Tournament.self)
//                self = .tournament(tournament)
            case .event:
                let event = try objectContainer.decode(Event.self)
                self = .event(event)
            case .bettingOffer:
                let bettingOffer = try objectContainer.decode(EveryMatrix.BettingOffer.self)
                self = .bettingOffer(bettingOffer)
            case .betOutcome:
                let outcome = try objectContainer.decode(EveryMatrix.BetOutcome.self)
                self = .betOutcome(outcome)
            case .market:
                let market = try objectContainer.decode(EveryMatrix.Market.self)
                self = .market(market)
            case .mainMarket:
                var market = try objectContainer.decode(EveryMatrix.Market.self)
                market.setAsMainMarket()
                self = .mainMarket(market)
            case .marketOutcomeRelation:
                let marketOutcomeRelation = try objectContainer.decode(EveryMatrix.MarketOutcomeRelation.self)
                self = .marketOutcomeRelation(marketOutcomeRelation)
            case .marketGroup:
                let marketGroup = try objectContainer.decode(EveryMatrix.MarketGroup.self)
                self = .marketGroup(marketGroup)
            case .unknown:
                self = .unknown
            }
        }
    }
}
