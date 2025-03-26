//
//  SportRadarModels+RecommendedBetBuilders.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation

extension SportRadarModels {

    struct RecommendedBetBuildersResponse: Codable {
        var recommendations: [RecommendedBetBuilderEvent]
        var status: String

        enum CodingKeys: String, CodingKey {
            case data
            case status
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.status = try container.decode(String.self, forKey: .status)
            self.recommendations = try container.decode([RecommendedBetBuilderEvent].self, forKey: .data)
        }

        func encode(to encoder: Encoder) throws {
            // Note: This encoding method doesn't preserve the original structure.
            // If you need to encode back to the original format, you'll need a more complex encoding method.
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status, forKey: .status)
        }
    }

    struct RecommendedBetBuilderEvent: Codable {
        var status: String
        var beginDate: String
        var country: String
        var sport: String
        var participants: [String]
        var eventId: String
        var eventType: String
        var league: String
        var leagueId: String
        var sportId: String
        var countryId: String
        var participantIds: [String]
        var betBuilders: [[BetBuilderSelection]]
        var orakoEventId: String

        enum CodingKeys: String, CodingKey {
            case status
            case beginDate = "begin"
            case country
            case sport
            case participants
            case eventId = "event_id"
            case eventType = "event_type"
            case league
            case leagueId = "league_id"
            case sportId = "sport_id"
            case countryId = "country_id"
            case participantIds = "participant_ids"
            case betBuilders = "bet_builders"
            case orakoEventId = "orako_event_id"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.RecommendedBetBuilderEvent.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.self)
            self.status = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.status)
            self.beginDate = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.beginDate)
            self.country = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.country)
            self.sport = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.sport)
            self.participants = try container.decode([String].self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.participants)
            self.eventId = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.eventId)
            self.eventType = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.eventType)
            self.league = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.league)
            self.leagueId = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.leagueId)
            self.sportId = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.sportId)
            self.countryId = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.countryId)
            self.participantIds = try container.decode([String].self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.participantIds)
            self.betBuilders = try container.decode([[SportRadarModels.BetBuilderSelection]].self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.betBuilders)
            self.orakoEventId = try container.decode(String.self, forKey: SportRadarModels.RecommendedBetBuilderEvent.CodingKeys.orakoEventId)
        }
    }

    struct BetBuilderSelection: Codable {
        var count: Int
        var period: String?
        var quote: Double
        var outcomeType: String?
        var marketName: String?
        var marketTypeName: String
        var outcomeId: Int
        var marketId: Int?
        var selectionId: String
        var marketTypeId: Int
        var periodId: Int?
        var quoteGroup: String
        var betOfferId: Int?
        var uofExternalId: String
        var orakoMarketId: String
        var orakoSelectionId: String

        enum CodingKeys: String, CodingKey {
            case count
            case period
            case quote
            case outcomeType = "outcome"
            case marketName = "market"
            case marketTypeName = "market_type"
            case outcomeId = "outcome_id"
            case marketId = "market_id"
            case selectionId = "selection_id"
            case marketTypeId = "market_type_id"
            case periodId = "period_id"
            case quoteGroup = "quote_group"
            case betOfferId = "bet_offer_id"
            case uofExternalId = "uof_external_id"
            case orakoMarketId = "orako_market_id"
            case orakoSelectionId = "orako_selection_id"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.BetBuilderSelection.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.BetBuilderSelection.CodingKeys.self)
            self.count = try container.decode(Int.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.count)
            self.period = try container.decodeIfPresent(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.period)
            self.quote = try container.decode(Double.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.quote)
            self.outcomeType = try container.decodeIfPresent(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.outcomeType)
            self.marketName = try container.decodeIfPresent(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.marketName)
            self.marketTypeName = try container.decode(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.marketTypeName)
            self.outcomeId = try container.decode(Int.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.outcomeId)
            self.marketId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.marketId)
            self.selectionId = try container.decode(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.selectionId)
            self.marketTypeId = try container.decode(Int.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.marketTypeId)
            self.periodId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.periodId)
            self.quoteGroup = try container.decode(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.quoteGroup)
            self.betOfferId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.betOfferId)
            self.uofExternalId = try container.decode(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.uofExternalId)
            self.orakoMarketId = try container.decode(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.orakoMarketId)
            self.orakoSelectionId = try container.decode(String.self, forKey: SportRadarModels.BetBuilderSelection.CodingKeys.orakoSelectionId)
        }
    }
}
