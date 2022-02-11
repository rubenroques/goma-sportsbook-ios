//
//  FavoritesAggregator.swift
//  Sportsbook
//
//  Created by André Lascas on 11/02/2022.
//

import Foundation

extension EveryMatrix {

    enum FavoritesAggregatorContentType {
        case update(content: [FavoriteContentUpdate])
        case initialDump(content: [FavoriteContent])
    }

    struct FavoritesAggregator: Decodable {

        // var content: [Content]
        var messageType: FavoritesAggregatorContentType

        enum CodingKeys: String, CodingKey {
            case content = "records"
            case messageType = "messageType"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let messageTypeString = try container.decode(String.self, forKey: .messageType)
            if messageTypeString == "UPDATE" {
                let rawItems = try container.decode([FailableDecodable<FavoriteContentUpdate>].self, forKey: .content).compactMap({ $0.base })
                let filteredItems = rawItems.filter({
                    if case .unknown = $0 {
                        return false
                    }
                    return true
                })
                messageType = .update(content: filteredItems)
            }
            else if messageTypeString == "INITIAL_DUMP" {
                let items = try container.decode([FailableDecodable<FavoriteContent>].self, forKey: .content).compactMap({ $0.base })
                messageType = .initialDump(content: items)
            }
            else {
                messageType = .update(content: [])
            }
        }

        var content: [FavoriteContent]? {
            switch self.messageType {
            case .initialDump(let content):
                return content
            default: return nil
            }
        }

        var contentUpdates: [FavoriteContentUpdate]? {
            switch self.messageType {
            case .update(let contents):
                return contents
            default: return nil
            }
        }

    }

    enum FavoriteContentUpdateError: Error {
        case uknownUpdateType
        case invalidUpdateFormat
    }

    enum FavoriteContentUpdate: Decodable {

        case bettingOfferUpdate(id: String, odd: Double?, isLive: Bool?, isAvailable: Bool?)
        case marketUpdate(id: String, isAvailable: Bool?, isClosed: Bool?)
        case matchInfo(id: String, paramFloat1: Int?, paramFloat2: Int?, paramEventPartName1: String?)
        case fullMatchInfoUpdate(matchInfo: EveryMatrix.MatchInfo)
        case unknown(typeName: String)

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case changeType = "changeType"
            case entityType = "entityType"
            case contentId = "id"
            case oddValue = "odds"
            case changedProperties = "changedProperties"
            case entity = "entity"
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

        enum MatchInfoCodingKeys: String, CodingKey {
            case contentId = "id"
            case paramFloat1 = "paramFloat1"
            case paramFloat2 = "paramFloat2"
            case paramEventPartName1 = "paramEventPartName1"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard
                let changeTypeString = try? container.decode(String.self, forKey: .changeType),
                let entityTypeString = try? container.decode(String.self, forKey: .entityType)
            else {
                throw FavoriteContentUpdateError.uknownUpdateType
            }

            self = .unknown(typeName: entityTypeString)

            var contentUpdateType: FavoriteContentUpdate?

            if changeTypeString == "UPDATE", let contentId = try? container.decode(String.self, forKey: .contentId) {

                if entityTypeString == "BETTING_OFFER" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: BettingOfferCodingKeys.self, forKey: .changedProperties) {

                        let newOddValue = try? changedPropertiesContainer.decode(Double.self, forKey: .oddValue)
                        let isAvailableValue = try? changedPropertiesContainer.decode(Bool.self, forKey: .isAvailable)
                        let isLiveValue = try? changedPropertiesContainer.decode(Bool.self, forKey: .isLive)

                        if newOddValue != nil || isAvailableValue != nil || isLiveValue != nil {
                            contentUpdateType = .bettingOfferUpdate(id: contentId,
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
                            contentUpdateType = .marketUpdate(id: contentId, isAvailable: isAvailableValue, isClosed: isClosedValue)
                        }
                    }
                }
                else if entityTypeString == "EVENT_INFO" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: MatchInfoCodingKeys.self, forKey: .changedProperties) {

                        let paramFloat1 = try? changedPropertiesContainer.decode(Int.self, forKey: .paramFloat1)

                        let paramFloat2 = try? changedPropertiesContainer.decode(Int.self, forKey: .paramFloat2)

                        let paramEventPartName1 = try? changedPropertiesContainer.decode(String.self, forKey: .paramEventPartName1)

                        if paramFloat1 != nil || paramFloat2 != nil || paramEventPartName1 != nil {
                            contentUpdateType = .matchInfo(id: contentId,
                                                           paramFloat1: paramFloat1, paramFloat2: paramFloat2,
                                                           paramEventPartName1: paramEventPartName1)
                        }

                    }
                }

            }
            else if changeTypeString == "CREATE", let contentId = try? container.decode(String.self, forKey: .contentId) {
                if entityTypeString == "EVENT_INFO" {

                    if let matchInfo = try? container.decode(EveryMatrix.MatchInfo.self, forKey: .entity) {
                        contentUpdateType = .fullMatchInfoUpdate(matchInfo: matchInfo)

                    }
                }

            }

            if let contentUpdateTypeValue = contentUpdateType {
                self = contentUpdateTypeValue
            }
            else {
                self = .unknown(typeName: entityTypeString)
            }

        }

    }

    enum FavoriteContent: Decodable {

        case match(EveryMatrix.Match)
        case matchInfo(EveryMatrix.MatchInfo)

        case tournament(EveryMatrix.Tournament)
        case bettingOffer(EveryMatrix.BettingOffer)
        case betOutcome(EveryMatrix.BetOutcome)
        case market(EveryMatrix.Market)
        case mainMarket(EveryMatrix.Market)
        case marketOutcomeRelation(EveryMatrix.MarketOutcomeRelation)
        case location(EveryMatrix.Location)
        case eventPartScore(EveryMatrix.EventPartScore)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        enum ContentTypeKey: String, Decodable {

            case match = "MATCH"
            case matchInfo = "EVENT_INFO"
            case tournament = "TOURNAMENT"
            case bettingOffer = "BETTING_OFFER"
            case betOutcome = "OUTCOME"
            case market = "MARKET"
            case mainMarket = "MAIN_MARKET"
            case marketOutcomeRelation = "MARKET_OUTCOME_RELATION"
            case location = "LOCATION"
            case eventPartScore = "EVENT_PART_SCORE"
            case unknown

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let type = try container.decode(String.self)
                if let contentTypeKey = ContentTypeKey(rawValue: type) {
                    self = contentTypeKey
                }
                else {
                    // print("Aggregator ContentTypeKey unknown [\(type)]")
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
            case .location:
                let location = try objectContainer.decode(EveryMatrix.Location.self)
                self = .location(location)
            case .eventPartScore:
                let eventPartScore = try objectContainer.decode(EveryMatrix.EventPartScore.self)
                self = .eventPartScore(eventPartScore)
            case .unknown:
                self = .unknown
            }
        }
    }
}

