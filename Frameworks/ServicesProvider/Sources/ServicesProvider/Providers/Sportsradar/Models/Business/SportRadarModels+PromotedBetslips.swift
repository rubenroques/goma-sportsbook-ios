//
//  PromotedBetslipsResponse.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation

extension SportRadarModels {
    
    struct PromotedBetslipsBatchResponse: Codable {
        var promotedBetslips: [PromotedBetslip]
        var status: String
        
        enum CodingKeys: String, CodingKey {
            case data
            case status
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.status = try container.decode(String.self, forKey: .status)
            
            let batchData = try container.decode(VaixBatchData.self, forKey: .data)
            self.promotedBetslips = batchData.promotedBetslips
        }
        
        func encode(to encoder: Encoder) throws {
            // Note: This encoding method doesn't preserve the original structure.
            // If you need to encode back to the original format, you'll need a more complex encoding method.
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(status, forKey: .status)
        }
    }
    
    private struct PromotedBetslipsInternalRequest: Codable {
        var body: VaixBatchBody
        var name: String
        var statusCode: Int
        
        enum CodingKeys: String, CodingKey {
            case body = "body"
            case name = "name"
            case statusCode = "status_code"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PromotedBetslipsInternalRequest.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PromotedBetslipsInternalRequest.CodingKeys.self)
            self.body = try container.decode(SportRadarModels.VaixBatchBody.self, forKey: SportRadarModels.PromotedBetslipsInternalRequest.CodingKeys.body)
            self.name = try container.decode(String.self, forKey: SportRadarModels.PromotedBetslipsInternalRequest.CodingKeys.name)
            self.statusCode = try container.decode(Int.self, forKey: SportRadarModels.PromotedBetslipsInternalRequest.CodingKeys.statusCode)
        }
    }
    
    private struct VaixBatchBody: Codable {
        var data: VaixBatchData
        var status: String
        
        enum CodingKeys: String, CodingKey {
            case data = "data"
            case status = "status"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.VaixBatchBody.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.VaixBatchBody.CodingKeys.self)
            self.data = try container.decode(SportRadarModels.VaixBatchData.self, forKey: SportRadarModels.VaixBatchBody.CodingKeys.data)
            self.status = try container.decode(String.self, forKey: SportRadarModels.VaixBatchBody.CodingKeys.status)
        }
    }
    
    private struct VaixBatchData: Codable {
        var promotedBetslips: [PromotedBetslip]
        var count: Int
        
        enum CodingKeys: String, CodingKey {
            case promotedBetslips = "betslips"
            case count = "count"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.VaixBatchData.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.VaixBatchData.CodingKeys.self)
            self.promotedBetslips = try container.decode([SportRadarModels.PromotedBetslip].self, forKey: SportRadarModels.VaixBatchData.CodingKeys.promotedBetslips)
            self.count = try container.decode(Int.self, forKey: SportRadarModels.VaixBatchData.CodingKeys.count)
        }
    }
    
    struct PromotedBetslip: Codable {
        var selections: [PromotedBetslipSelection]
        var betslipCount: Int
        
        enum CodingKeys: String, CodingKey {
            case selections = "betslip"
            case betslipCount = "betslip_count"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PromotedBetslip.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PromotedBetslip.CodingKeys.self)
            self.selections = try container.decode([SportRadarModels.PromotedBetslipSelection].self, forKey: SportRadarModels.PromotedBetslip.CodingKeys.selections)
            self.betslipCount = try container.decode(Int.self, forKey: SportRadarModels.PromotedBetslip.CodingKeys.betslipCount)
        }
    }
    
    struct PromotedBetslipSelection: Codable {
        var id: String?
        var beginDate: String?
        var betOfferId: Int?
        var country: String?
        var countryId: String?
        var eventId: String?
        var eventType: String?
        var league: String?
        var leagueId: String?
        var market: String?
        var marketId: Int?
        var marketType: String?
        var marketTypeId: Int?
        var orakoEventId: String
        var orakoMarketId: String
        var orakoSelectionId: String
        var outcomeType: String?
        var outcomeId: Int?
        var participantIds: [String]?
        var participants: [String]?
        var period: String?
        var periodId: Int?
        var quote: Double?
        var quoteGroup: String?
        var sport: String?
        var sportId: String?
        var status: String?

        enum CodingKeys: String, CodingKey {
            case id = "selection_id"
            case beginDate = "begin"
            case betOfferId = "bet_offer_id"
            case country = "country"
            case countryId = "country_id"
            case eventId = "event_id"
            case eventType = "event_type"
            case league = "league"
            case leagueId = "league_id"
            case market = "market"
            case marketId = "market_id"
            case marketType = "market_type"
            case marketTypeId = "market_type_id"
            case orakoEventId = "orako_event_id"
            case orakoMarketId = "orako_market_id"
            case orakoSelectionId = "orako_selection_id"
            case outcomeType = "outcome"
            case outcomeId = "outcome_id"
            case participantIds = "participant_ids"
            case participants = "participants"
            case period = "period"
            case periodId = "period_id"
            case quote = "quote"
            case quoteGroup = "quote_group"
            case sport = "sport"
            case sportId = "sport_id"
            case status = "status"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.PromotedBetslipSelection.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.PromotedBetslipSelection.CodingKeys.self)

            // Required props
            self.orakoEventId = try container.decode(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.orakoEventId)
            self.orakoMarketId = try container.decode(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.orakoMarketId)
            self.orakoSelectionId = try container.decode(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.orakoSelectionId)

            // Optional props
            self.id = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.id)
            self.quote = try container.decodeIfPresent(Double.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.quote)
            self.beginDate = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.beginDate)
            self.league = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.league)
            self.marketType = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.marketType)
            self.participantIds = try container.decodeIfPresent([String].self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.participantIds)
            self.participants = try container.decodeIfPresent([String].self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.participants)
            self.sport = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.sport)
            self.sportId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.sportId)
            self.status = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.status)
            self.outcomeType = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.outcomeType)

            self.betOfferId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.betOfferId)
            self.country = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.country)
            self.countryId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.countryId)
            self.eventId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.eventId)
            self.eventType = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.eventType)
            self.leagueId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.leagueId)
            self.market = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.market)
            self.marketId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.marketId)
            self.marketTypeId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.marketTypeId)
            self.outcomeId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.outcomeId)
            self.period = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.period)
            self.periodId = try container.decodeIfPresent(Int.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.periodId)
            self.quoteGroup = try container.decodeIfPresent(String.self, forKey: SportRadarModels.PromotedBetslipSelection.CodingKeys.quoteGroup)

        }
    }
}
