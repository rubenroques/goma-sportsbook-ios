//
//  EntityRecord.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 26/06/2025.
//

import Foundation

extension EveryMatrix {
    enum EntityRecord: Codable {
        // INITIAL_DUMP records (full entities)
        case sport(SportDTO)
        case match(MatchDTO)
        case market(MarketDTO)
        case outcome(OutcomeDTO)
        case bettingOffer(BettingOfferDTO)
        case location(LocationDTO)
        case eventCategory(EventCategoryDTO)
        case marketOutcomeRelation(MarketOutcomeRelationDTO)
        case mainMarket(MainMarketDTO)
        case marketInfo(MarketInfoDTO)
        case nextMatchesNumber(NextMatchesNumberDTO)
        case tournament(TournamentDTO)
        case eventInfo(EventInfoDTO)

        // UPDATE/DELETE/CREATE records with change metadata
        case changeRecord(ChangeRecord)
        case unknown(type: String)

        private enum CodingKeys: String, CodingKey {
            case type = "_type"
            case entityType
            case changeType
            case id
            case entity
            case changedProperties
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Check if this is a change record (has changeType)
            if container.contains(.changeType) {
                let changeRecord = try ChangeRecord(from: decoder)
                self = .changeRecord(changeRecord)
                return
            }

            // Otherwise, decode as original entity type
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "SPORT":
                let sport = try SportDTO(from: decoder)
                self = .sport(sport)
            case "MATCH":
                let match = try MatchDTO(from: decoder)
                self = .match(match)
            case "MARKET":
                let market = try MarketDTO(from: decoder)
                self = .market(market)
            case "OUTCOME":
                let outcome = try OutcomeDTO(from: decoder)
                self = .outcome(outcome)
            case "BETTING_OFFER":
                let offer = try BettingOfferDTO(from: decoder)
                self = .bettingOffer(offer)
            case "LOCATION":
                let location = try LocationDTO(from: decoder)
                self = .location(location)
            case "EVENT_CATEGORY":
                let category = try EventCategoryDTO(from: decoder)
                self = .eventCategory(category)
            case "MARKET_OUTCOME_RELATION":
                let relation = try MarketOutcomeRelationDTO(from: decoder)
                self = .marketOutcomeRelation(relation)
            case "MAIN_MARKET":
                let mainMarket = try MainMarketDTO(from: decoder)
                self = .mainMarket(mainMarket)
            case "MARKET_INFO":
                let marketInfo = try MarketInfoDTO(from: decoder)
                self = .marketInfo(marketInfo)
            case "NEXT_MATCHES_NUMBER":
                let nextMatches = try NextMatchesNumberDTO(from: decoder)
                self = .nextMatchesNumber(nextMatches)
            case "TOURNAMENT":
                let tournament = try TournamentDTO(from: decoder)
                self = .tournament(tournament)
            case "EVENT_INFO":
                let eventInfo = try EventInfoDTO(from: decoder)
                self = .eventInfo(eventInfo)
            default:
                self = .unknown(type: type)
            }
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .sport(let dto):
                try dto.encode(to: encoder)
            case .match(let dto):
                try dto.encode(to: encoder)
            case .market(let dto):
                try dto.encode(to: encoder)
            case .outcome(let dto):
                try dto.encode(to: encoder)
            case .bettingOffer(let dto):
                try dto.encode(to: encoder)
            case .location(let dto):
                try dto.encode(to: encoder)
            case .eventCategory(let dto):
                try dto.encode(to: encoder)
            case .marketOutcomeRelation(let dto):
                try dto.encode(to: encoder)
            case .mainMarket(let dto):
                try dto.encode(to: encoder)
            case .marketInfo(let dto):
                try dto.encode(to: encoder)
            case .nextMatchesNumber(let dto):
                try dto.encode(to: encoder)
            case .tournament(let dto):
                try dto.encode(to: encoder)
            case .eventInfo(let dto):
                try dto.encode(to: encoder)
            case .changeRecord(let record):
                try record.encode(to: encoder)
            case .unknown:
                var container = encoder.container(keyedBy: CodingKeys.self)
                if case .unknown(let type) = self {
                    try container.encode(type, forKey: .type)
                }
            }
        }
    }
}