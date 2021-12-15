//
//  MatchOddsContent.swift
//  Sportsbook
//
//  Created by André Lascas on 06/12/2021.
//

import Foundation

extension EveryMatrix {

    struct MatchOdds: Decodable {

        enum CodingKeys: String, CodingKey {
            case content = "records"
        }

        var content: [MatchOddsContent]?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let items = try container.decode([FailableDecodable<MatchOddsContent>].self, forKey: .content).compactMap({ $0.base })

            self.content = items

        }

    }

    enum MatchOddsContent: Decodable {

        case match(EveryMatrix.Match)

        case bettingOffer(EveryMatrix.BettingOffer)
        case betOutcome(EveryMatrix.BetOutcome)
        case market(EveryMatrix.Market)
        case marketOutcomeRelation(EveryMatrix.MarketOutcomeRelation)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        enum ContentTypeKey: String, Decodable {

            case match = "MATCH"
            case bettingOffer = "BETTING_OFFER"
            case betOutcome = "OUTCOME"
            case market = "MARKET"
            case marketOutcomeRelation = "MARKET_OUTCOME_RELATION"
            case unknown

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let type = try container.decode(String.self)
                if let contentTypeKey = ContentTypeKey(rawValue: type) {
                    print("Odds Aggregator ContentTypeKey [\(type)]")
                    self = contentTypeKey
                }
                else {
                    print("Odds Aggregator ContentTypeKey unknown [\(type)]")
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
            case .bettingOffer:
                let bettingOffer = try objectContainer.decode(EveryMatrix.BettingOffer.self)
                self = .bettingOffer(bettingOffer)
            case .betOutcome:
                let outcome = try objectContainer.decode(EveryMatrix.BetOutcome.self)
                self = .betOutcome(outcome)
            case .market:
                let market = try objectContainer.decode(EveryMatrix.Market.self)
                self = .market(market)
            case .marketOutcomeRelation:
                let marketOutcomeRelation = try objectContainer.decode(EveryMatrix.MarketOutcomeRelation.self)
                self = .marketOutcomeRelation(marketOutcomeRelation)
            case .unknown:
                self = .unknown
            }
        }
    }

}
