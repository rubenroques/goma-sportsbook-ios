//
//  Aggregator.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

extension EveryMatrix {

    enum AggregatorContentType {
        case update(content: [ContentUpdate])
        case initialDump(content: [Content])
    }

    struct Aggregator: Decodable {

        //var content: [Content]
        var messageType: AggregatorContentType

        enum CodingKeys: String, CodingKey {
            case content = "records"
            case messageType = "messageType"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let messageTypeString = try container.decode(String.self, forKey: .messageType)
            if messageTypeString == "UPDATE" {
                let rawItems = try container.decode([FailableDecodable<ContentUpdate>].self, forKey: .content).compactMap({ $0.base })
                let filteredItems = rawItems.filter({
                    if case .unknown = $0 {
                        return false
                      }
                      return true
                })
                messageType = .update(content: filteredItems)
            }
            else if messageTypeString == "INITIAL_DUMP" {
                let items = try container.decode([FailableDecodable<Content>].self, forKey: .content).compactMap({ $0.base })
                messageType = .initialDump(content: items)
            }
            else {
                messageType = .update(content: [])
            }
        }

        var content: [Content]? {
            switch self.messageType {
            case .initialDump(let content):
                return content
            default: return nil
            }
        }

        var contentUpdates: [ContentUpdate]? {
            switch self.messageType {
            case .update(let contents):
                return contents
            default: return nil
            }
        }

    }

    enum ContentUpdateError: Error {
        case uknownUpdateType
        case invalidUpdateFormat
    }

    enum ContentUpdate: Decodable {

        case bettingOfferUpdate(id: String, odd: Double?, isLive: Bool?, isAvailable: Bool?)
        case marketUpdate(id: String, isAvailable: Bool?, isClosed: Bool?)
        case cashoutUpdate(id: String, value: Double?, stake: Double?)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case changeType = "changeType"
            case entityType = "entityType"
            case contentId = "id"
            case oddValue = "odds"
            case changedProperties = "changedProperties"
        }

        enum BettingOfferCodingKeys: String, CodingKey {
            case contentId = "id"
            case oddValue = "odds"
            case isAvailable = "isAvailable"
            case isLive = "isLive"
            case changedProperties = "changedProperties"
        }

        enum MarketCodingKeys: String, CodingKey {
            case contentId = "id"
            case changedProperties = "changedProperties"
            case isAvailable = "isAvailable"
            case isClosed = "isClosed"
        }

        enum CashoutCodingKeys: String, CodingKey {
            case contentId = "id"
            case value = "value"
            case stake = "stake"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard
                let changeTypeString = try? container.decode(String.self, forKey: .changeType),
                let entityTypeString = try? container.decode(String.self, forKey: .entityType)
            else {
                throw ContentUpdateError.uknownUpdateType
            }
            self = .unknown

            if changeTypeString == "UPDATE", let contentId = try? container.decode(String.self, forKey: .contentId) {

                if entityTypeString == "BETTING_OFFER" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: BettingOfferCodingKeys.self, forKey: .changedProperties) {

                        let newOddValue = try? changedPropertiesContainer.decode(Double.self, forKey: .oddValue)
                        let isAvailableValue = try? changedPropertiesContainer.decode(Bool.self, forKey: .isAvailable)
                        let isLiveValue = try? changedPropertiesContainer.decode(Bool.self, forKey: .isLive)

                        if newOddValue != nil || isAvailableValue != nil || isLiveValue != nil {
                            self = .bettingOfferUpdate(id: contentId,
                                                   odd: newOddValue,
                                                   isLive: isLiveValue,
                                                   isAvailable: isAvailableValue)
                        }
                    }
                }
                else if entityTypeString == "MARKET" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: MarketCodingKeys.self, forKey: .changedProperties) {

                        let isAvailableValue = try? changedPropertiesContainer.decode(Bool.self, forKey: .isAvailable)
                        let isClosedValue = try? changedPropertiesContainer.decode(Bool.self, forKey: .isClosed)
                        if isAvailableValue != nil || isClosedValue != nil {
                            self = .marketUpdate(id: contentId, isAvailable: isAvailableValue, isClosed: isClosedValue)
                        }
                    }
                }
                else if entityTypeString == "MATCH" {
                    print("AggregatorUpdates - MATCH")

                }
                else if entityTypeString == "CASHOUT" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: CashoutCodingKeys.self, forKey: .changedProperties) {

                        let value = try? changedPropertiesContainer.decode(Double.self, forKey: .value)
                        let stake = try? changedPropertiesContainer.decode(Double.self, forKey: .stake)
                        self = .cashoutUpdate(id: contentId, value: value, stake: stake)

                    }
                }

            }

        }

    }

    enum Content: Decodable {

        case match(EveryMatrix.Match)
        case matchInfo(EveryMatrix.MatchInfo)

        case tournament(EveryMatrix.Tournament)
        case event(Event)
        case bettingOffer(EveryMatrix.BettingOffer)
        case betOutcome(EveryMatrix.BetOutcome)
        case market(EveryMatrix.Market)
        case mainMarket(EveryMatrix.Market)
        case marketOutcomeRelation(EveryMatrix.MarketOutcomeRelation)
        case marketGroup(EveryMatrix.MarketGroup)
        case location(EveryMatrix.Location)
        case cashout(EveryMatrix.Cashout)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        enum ContentTypeKey: String, Decodable {

            case match = "MATCH"
            case matchInfo = "EVENT_INFO"
            case tournament = "TOURNAMENT"
            case event = "EVENT"
            case bettingOffer = "BETTING_OFFER"
            case betOutcome = "OUTCOME"
            case market = "MARKET"
            case mainMarket = "MAIN_MARKET"
            case marketOutcomeRelation = "MARKET_OUTCOME_RELATION"
            case marketGroup = "MARKET_GROUP"
            case location = "LOCATION"
            case cashout = "CASHOUT"
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
            case .matchInfo:
                let matchInfo = try objectContainer.decode(EveryMatrix.MatchInfo.self)
                self = .matchInfo(matchInfo)
            case .tournament:
                let tournament = try objectContainer.decode(EveryMatrix.Tournament.self)
                self = .tournament(tournament)
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
            case .location:
                let location = try objectContainer.decode(EveryMatrix.Location.self)
                self = .location(location)
            case .cashout:
                let cashout = try objectContainer.decode(EveryMatrix.Cashout.self)
                self = .cashout(cashout)
            case .unknown:
                self = .unknown
            }
        }
    }
}
