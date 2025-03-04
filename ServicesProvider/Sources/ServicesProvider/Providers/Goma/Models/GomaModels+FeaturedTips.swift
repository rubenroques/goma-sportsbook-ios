//
//  File.swift
//  
//
//  Created by Ruben Roques on 17/01/2024.
//

import Foundation

extension GomaModels {
    
    struct FeaturedTipsPagedResponse: Codable {
        var currentPage: Int
        var featuredTips: [FeaturedTip]
        var perPage: Int
        
        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case featuredTips = "data"
            case perPage = "per_page"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.FeaturedTipsPagedResponse.CodingKeys> = try decoder.container(keyedBy: GomaModels.FeaturedTipsPagedResponse.CodingKeys.self)
            self.currentPage = try container.decode(Int.self, forKey: GomaModels.FeaturedTipsPagedResponse.CodingKeys.currentPage)
            self.featuredTips = try container.decode([GomaModels.FeaturedTip].self, forKey: GomaModels.FeaturedTipsPagedResponse.CodingKeys.featuredTips)
            self.perPage = try container.decode(Int.self, forKey: GomaModels.FeaturedTipsPagedResponse.CodingKeys.perPage)
        }
        
        init(currentPage: Int, featuredTips: [FeaturedTip], perPage: Int) {
            self.currentPage = currentPage
            self.featuredTips = featuredTips
            self.perPage = perPage
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.FeaturedTipsPagedResponse.CodingKeys.self)
            try container.encode(self.currentPage, forKey: GomaModels.FeaturedTipsPagedResponse.CodingKeys.currentPage)
            try container.encode(self.featuredTips, forKey: GomaModels.FeaturedTipsPagedResponse.CodingKeys.featuredTips)
            try container.encode(self.perPage, forKey: GomaModels.FeaturedTipsPagedResponse.CodingKeys.perPage)
        }
        
    }
    
    struct FeaturedTip: Codable {
        var id: Int
        var stake: Double
        var odds: Double
        var possibleWinnings: Double
        var winnings: Double?
        var status: String
        var type: String
        var shareId: String
        var selections: [FeaturedTipSelection]
        var user: TipUser
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case stake = "stake"
            case odds = "odds"
            case possibleWinnings = "possible_winnings"
            case winnings = "winnings"
            case status = "status"
            case type = "type"
            case shareId = "share_id"
            case selections = "selections"
            case user = "user"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try container.decode(Int.self, forKey: .id)
            self.status = try container.decode(String.self, forKey: .status)
            self.type = try container.decode(String.self, forKey: .type)
            self.shareId = try container.decode(String.self, forKey: .shareId)
            self.selections = try container.decode([FeaturedTipSelection].self, forKey: .selections)
            self.user = try container.decode(TipUser.self, forKey: .user)

            // Decode stake
            if let stakeValue = try? container.decode(Double.self, forKey: .stake) {
                self.stake = stakeValue
            } else if let stakeString = try? container.decode(String.self, forKey: .stake), let stakeValue = Double(stakeString) {
                self.stake = stakeValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .stake, in: container, debugDescription: "Stake is not a Double or String")
            }

            // Decode odds
            if let oddsValue = try? container.decode(Double.self, forKey: .odds) {
                self.odds = oddsValue
            } else if let oddsString = try? container.decode(String.self, forKey: .odds), let oddsValue = Double(oddsString) {
                self.odds = oddsValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odds, in: container, debugDescription: "Odds is not a Double or String")
            }

            // Decode possibleWinnings
            if let possibleWinningsValue = try? container.decode(Double.self, forKey: .possibleWinnings) {
                self.possibleWinnings = possibleWinningsValue
            } else if let possibleWinningsString = try? container.decode(String.self, forKey: .possibleWinnings), let possibleWinningsValue = Double(possibleWinningsString) {
                self.possibleWinnings = possibleWinningsValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .possibleWinnings, in: container, debugDescription: "Possible Winnings is not a Double or String")
            }

            // Decode winnings
            if let winningsValue = try? container.decode(Double.self, forKey: .winnings) {
                self.winnings = winningsValue
            } else if let winningsString = try? container.decode(String.self, forKey: .winnings), let winningsValue = Double(winningsString) {
                self.winnings = winningsValue
            } else {
                self.winnings = nil // It's optional, so it's okay if it doesn't exist
            }
        }

        
        init(id: Int,
             stake: Double,
             odds: Double,
             possibleWinnings: Double,
             winnings: Double?,
             status: String,
             type: String,
             shareId: String,
             selections: [FeaturedTipSelection],
             user: TipUser) {
            self.id = id
            self.stake = stake
            self.odds = odds
            self.possibleWinnings = possibleWinnings
            self.winnings = winnings
            self.status = status
            self.type = type
            self.shareId = shareId
            self.selections = selections
            self.user = user
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.FeaturedTip.CodingKeys.self)
            try container.encode(self.id, forKey: GomaModels.FeaturedTip.CodingKeys.id)
            try container.encode(self.stake, forKey: GomaModels.FeaturedTip.CodingKeys.stake)
            try container.encode(self.odds, forKey: GomaModels.FeaturedTip.CodingKeys.odds)
            try container.encode(self.possibleWinnings, forKey: GomaModels.FeaturedTip.CodingKeys.possibleWinnings)
            try container.encodeIfPresent(self.winnings, forKey: GomaModels.FeaturedTip.CodingKeys.winnings)
            try container.encode(self.status, forKey: GomaModels.FeaturedTip.CodingKeys.status)
            try container.encode(self.type, forKey: GomaModels.FeaturedTip.CodingKeys.type)
            try container.encode(self.shareId, forKey: GomaModels.FeaturedTip.CodingKeys.shareId)
            try container.encode(self.selections, forKey: GomaModels.FeaturedTip.CodingKeys.selections)
            try container.encode(self.user, forKey: GomaModels.FeaturedTip.CodingKeys.user)
        }
        
    }
    
    struct FeaturedTipSelection: Codable {
        var id: Int
        var bettingTicketId: Int
        var sportEventId: Int
        var outcomeId: Int
        var odd: Double
        var status: String
        var outcome: TipOutcome
        var event: Event
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case bettingTicketId = "betting_ticket_id"
            case sportEventId = "sport_event_id"
            case outcomeId = "outcome_id"
            case odd = "odd"
            case status = "status"
            case outcome = "outcome"
            case event = "event"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.FeaturedTipSelection.CodingKeys> = try decoder.container(keyedBy: GomaModels.FeaturedTipSelection.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.id)
            self.bettingTicketId = try container.decode(Int.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.bettingTicketId)
            self.sportEventId = try container.decode(Int.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.sportEventId)
            self.outcomeId = try container.decode(Int.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.outcomeId)
            
            // Decode Odd
            if let oddValue = try? container.decode(Double.self, forKey: .odd) {
                self.odd = oddValue
            } else if let oddString = try? container.decode(String.self, forKey: .odd), let oddValue = Double(oddString) {
                self.odd = oddValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odd, in: container, debugDescription: "Odd is not a Double or String")
            }
            
            self.status = try container.decode(String.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.status)
            self.outcome = try container.decode(GomaModels.TipOutcome.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.outcome)
            self.event = try container.decode(GomaModels.Event.self, forKey: GomaModels.FeaturedTipSelection.CodingKeys.event)
        }
        
        init(id: Int, bettingTicketId: Int, sportEventId: Int, outcomeId: Int, odd: Double, status: String, outcome: TipOutcome, event: Event) {
            self.id = id
            self.bettingTicketId = bettingTicketId
            self.sportEventId = sportEventId
            self.outcomeId = outcomeId
            self.odd = odd
            self.status = status
            self.outcome = outcome
            self.event = event
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.FeaturedTipSelection.CodingKeys.self)
            try container.encode(self.id, forKey: GomaModels.FeaturedTipSelection.CodingKeys.id)
            try container.encode(self.bettingTicketId, forKey: GomaModels.FeaturedTipSelection.CodingKeys.bettingTicketId)
            try container.encode(self.sportEventId, forKey: GomaModels.FeaturedTipSelection.CodingKeys.sportEventId)
            try container.encode(self.outcomeId, forKey: GomaModels.FeaturedTipSelection.CodingKeys.outcomeId)
            try container.encode(self.odd, forKey: GomaModels.FeaturedTipSelection.CodingKeys.odd)
            try container.encode(self.status, forKey: GomaModels.FeaturedTipSelection.CodingKeys.status)
            try container.encode(self.outcome, forKey: GomaModels.FeaturedTipSelection.CodingKeys.outcome)
            try container.encode(self.event, forKey: GomaModels.FeaturedTipSelection.CodingKeys.event)
        }
        
    }
    
    
    // MARK: - Outcome
    struct TipOutcome: Codable {
        var id: Int
        var name: String
        var code: String
        var price: Double
        var market: TipMarket
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case code = "code"
            case price = "price"
            case market = "market"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.TipOutcome.CodingKeys> = try decoder.container(keyedBy: GomaModels.TipOutcome.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: GomaModels.TipOutcome.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: GomaModels.TipOutcome.CodingKeys.name)
            self.code = try container.decode(String.self, forKey: GomaModels.TipOutcome.CodingKeys.code)
            self.market = try container.decode(GomaModels.TipMarket.self, forKey: GomaModels.TipOutcome.CodingKeys.market)
            
            // Decode Odd
            if let priceValue = try? container.decode(Double.self, forKey: .price) {
                self.price = priceValue
            } else if let priceString = try? container.decode(String.self, forKey: .price), let priceValue = Double(priceString) {
                self.price = priceValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .price, in: container, debugDescription: "Price is not a Double or String")
            }
            
        }
        
        init(id: Int, name: String, code: String, price: Double, market: TipMarket) {
            self.id = id
            self.name = name
            self.code = code
            self.price = price
            self.market = market
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.TipOutcome.CodingKeys.self)
            try container.encode(self.id, forKey: GomaModels.TipOutcome.CodingKeys.id)
            try container.encode(self.name, forKey: GomaModels.TipOutcome.CodingKeys.name)
            try container.encode(self.code, forKey: GomaModels.TipOutcome.CodingKeys.code)
            try container.encode(self.price, forKey: GomaModels.TipOutcome.CodingKeys.price)
            try container.encode(self.market, forKey: GomaModels.TipOutcome.CodingKeys.market)
        }
    }
    
    // MARK: - Market
    struct TipMarket: Codable {
        var id: Int
        var sportEventMarketId: Int
        var name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case sportEventMarketId = "sport_event_market_id"
            case name = "name"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.TipMarket.CodingKeys> = try decoder.container(keyedBy: GomaModels.TipMarket.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: GomaModels.TipMarket.CodingKeys.id)
            self.sportEventMarketId = try container.decode(Int.self, forKey: GomaModels.TipMarket.CodingKeys.sportEventMarketId)
            self.name = try container.decode(String.self, forKey: GomaModels.TipMarket.CodingKeys.name)
        }
        
        init(id: Int, sportEventMarketId: Int, name: String) {
            self.id = id
            self.sportEventMarketId = sportEventMarketId
            self.name = name
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.TipMarket.CodingKeys.self)
            try container.encode(self.id, forKey: GomaModels.TipMarket.CodingKeys.id)
            try container.encode(self.sportEventMarketId, forKey: GomaModels.TipMarket.CodingKeys.sportEventMarketId)
            try container.encode(self.name, forKey: GomaModels.TipMarket.CodingKeys.name)
        }
        
    }
    
    // MARK: - User
    struct TipUser: Codable {
        var id: Int
        var name: String?
        var code: String?
        var avatar: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case code = "code"
            case avatar = "avatar"
        }
             
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.TipUser.CodingKeys> = try decoder.container(keyedBy: GomaModels.TipUser.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: GomaModels.TipUser.CodingKeys.id)
            self.name = try container.decodeIfPresent(String.self, forKey: GomaModels.TipUser.CodingKeys.name)
            self.code = try container.decodeIfPresent(String.self, forKey: GomaModels.TipUser.CodingKeys.code)
            self.avatar = try container.decodeIfPresent(String.self, forKey: GomaModels.TipUser.CodingKeys.avatar)
        }
        
        init(id: Int, name: String?, code: String?, avatar: String?) {
            self.id = id
            self.name = name
            self.code = code
            self.avatar = avatar
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.TipUser.CodingKeys.self)
            try container.encode(self.id, forKey: GomaModels.TipUser.CodingKeys.id)
            try container.encodeIfPresent(self.name, forKey: GomaModels.TipUser.CodingKeys.name)
            try container.encodeIfPresent(self.code, forKey: GomaModels.TipUser.CodingKeys.code)
            try container.encodeIfPresent(self.avatar, forKey: GomaModels.TipUser.CodingKeys.avatar)
        }
    }
}
