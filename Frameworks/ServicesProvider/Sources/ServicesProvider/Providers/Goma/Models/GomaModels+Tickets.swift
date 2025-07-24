//
//  File.swift
//  
//
//  Created by André Lascas on 22/01/2024.
//

import Foundation

extension GomaModels {
    
    struct MyTicketsResponse: Codable {
        var currentPage: Int
        var data: [MyTicket]
        
        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case data = "data"
        }
    }
    
    struct MyTicket: Codable {
        var id: Int
        var userId: Int?
        var stake: Double
        var odds: Double
        var possibleWinnings: Double?
        var winnings: Double?
        var status: MyTicketStatus
        var type: String
        var shareId: String
        var createdAt: String?
        var updatedAt: String?
        var selections: [MyTicketSelection]
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case userId = "user_id"
            case stake = "stake"
            case odds = "odds"
            case possibleWinnings = "possible_winnings"
            case winnings = "winnings"
            case status = "status"
            case type = "type"
            case shareId = "share_id"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case selections = "selections"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.id) {
                self.id = idValue
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.id) {
                self.id = Int(idStringValue) ?? 0
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.id, context)
                throw error
            }
            
            self.userId = try container.decodeIfPresent(Int.self, forKey: CodingKeys.userId)
            
            self.stake = try container.decode(Double.self, forKey: CodingKeys.stake)
            
            // Decode Odd
            if let priceValue = try? container.decode(Double.self, forKey: .odds) {
                self.odds = priceValue
            } else if let priceString = try? container.decode(String.self, forKey: .odds), let priceValue = Double(priceString) {
                self.odds = priceValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odds, in: container, debugDescription: "Odds is not a Double or String")
            }
            
            self.possibleWinnings = try container.decodeIfPresent(Double.self, forKey: CodingKeys.possibleWinnings)
            self.winnings = try container.decodeIfPresent(Double.self, forKey: CodingKeys.winnings)
            
            if let statusString = try? container.decode(String.self, forKey: CodingKeys.status) {
                self.status = MyTicketStatus(rawValue: statusString)
            }
            else {
                self.status = .undefined
            }
            
            self.type = try container.decode(String.self, forKey: CodingKeys.type)
            self.shareId = try container.decode(String.self, forKey: CodingKeys.shareId)
            self.createdAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.createdAt)
            
            self.updatedAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.updatedAt)
            
            self.selections = try container.decode([MyTicketSelection].self, forKey: CodingKeys.selections)
            
        }
    }
    
    struct MyTicketSelection: Codable {
        var id: Int
        var bettingTicketId: Int
        var sportEventId: Int
        var outcomeId: Int
        var odd: Double
        var status: MyTicketStatus
        var createdAt: String?
        var updatedAt: String?
        var outcome: MyTicketOutcome
        var event: MyTicketEvent
        
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case bettingTicketId = "betting_ticket_id"
            case sportEventId = "sport_event_id"
            case outcomeId = "outcome_id"
            case odd = "odd"
            case status = "status"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case outcome = "outcome"
            case event = "event"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.id) {
                self.id = idValue
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.id) {
                self.id = Int(idStringValue) ?? 0
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.id, context)
                throw error
            }
            
            self.bettingTicketId = try container.decode(Int.self, forKey: CodingKeys.bettingTicketId)
            self.sportEventId = try container.decode(Int.self, forKey: CodingKeys.sportEventId)
            self.outcomeId = try container.decode(Int.self, forKey: CodingKeys.outcomeId)
            // Decode Odd
            if let priceValue = try? container.decode(Double.self, forKey: .odd) {
                self.odd = priceValue
            } else if let priceString = try? container.decode(String.self, forKey: .odd), let priceValue = Double(priceString) {
                self.odd = priceValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .odd, in: container, debugDescription: "Odds is not a Double or String")
            }
            
            if let statusString = try? container.decode(String.self, forKey: CodingKeys.status) {
                self.status = MyTicketStatus(rawValue: statusString)
            }
            else {
                self.status = .undefined
            }
            
            self.createdAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.createdAt)
            self.updatedAt = try container.decodeIfPresent(String.self, forKey: CodingKeys.updatedAt)
            
            self.outcome = try container.decode(MyTicketOutcome.self, forKey: CodingKeys.outcome)
            self.event = try container.decode(MyTicketEvent.self, forKey: CodingKeys.event)
        }
    }
    
    struct MyTicketOutcome: Codable {
        var id: Int
        var name: String
        var code: String?
        var price: Double
        var market: MyTicketMarket
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case code = "code"
            case price = "price"
            case market = "market"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.MyTicketOutcome.CodingKeys> = try decoder.container(keyedBy: GomaModels.MyTicketOutcome.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: GomaModels.MyTicketOutcome.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: GomaModels.MyTicketOutcome.CodingKeys.name)
            self.code = try container.decodeIfPresent(String.self, forKey: GomaModels.MyTicketOutcome.CodingKeys.code)
            self.market = try container.decode(GomaModels.MyTicketMarket.self, forKey: GomaModels.MyTicketOutcome.CodingKeys.market)
            
            // Decode Odd
            if let priceValue = try? container.decode(Double.self, forKey: .price) {
                self.price = priceValue
            } else if let priceString = try? container.decode(String.self, forKey: .price), let priceValue = Double(priceString) {
                self.price = priceValue
            } else {
                throw DecodingError.dataCorruptedError(forKey: .price, in: container, debugDescription: "Price is not a Double or String")
            }
        }
    }
    
    struct MyTicketMarket: Codable {
        var id: Int
        var sportEventMarketId: Int?
        var name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case sportEventMarketId = "sport_event_market_id"
            case name = "name"
        }
    }
    
    struct MyTicketEvent: Codable {
        var id: Int
        var homeTeamId: Int
        var awayTeamId: Int
        var homeTeam: String
        var awayTeam: String
        var date: String
        var dateTime: Date
        var time: String
        var homeScore: Int?
        var awayScore: Int?
        var halfTimeScore: String?
        var fullTimeScore: String?
        var extraTimeScore: String?
        var timer: String?
        var status: EventStatus
        var isLive: Bool
        var p1Score: Int?
        var p2Score: Int?
        var p3Score: Int?
        var p4Score: Int?
        var p5Score: Int?
        var sport: Sport
        var region: Region?
        var competition: Competition?
        var placardInfo: PlacardInfo?
        var homeMetaInfo: String?
        var awayMetaInfo: String?
        var homeLogoUrl: String?
        var awayLogoUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case homeTeamId = "home_team_id"
            case awayTeamId = "away_team_id"
            case homeTeam = "home_team"
            case awayTeam = "away_team"
            case date = "date"
            case dateTime = "date_time"
            case time = "time"
            case homeScore = "home_score"
            case awayScore = "away_score"
            case halfTimeScore = "ht_score"
            case fullTimeScore = "ft_score"
            case extraTimeScore = "et_score"
            case timer = "timer"
            case status = "status"
            case isLive = "is_live"
            case p1Score = "p1_score"
            case p2Score = "p2_score"
            case p3Score = "p3_score"
            case p4Score = "p4_score"
            case p5Score = "p5_score"
            case sport = "sport"
            case region = "region"
            case competition = "competition"
            case placardInfo = "placard_info"
            case homeMetaInfo = "home_team_meta"
            case awayMetaInfo = "away_team_meta"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.id) {
                self.id = idValue
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.id) {
                self.id = Int(idStringValue) ?? 0
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.id, context)
                throw error
            }
            
            self.homeTeamId = try container.decode(Int.self, forKey: CodingKeys.homeTeamId)
            self.awayTeamId = try container.decode(Int.self, forKey: CodingKeys.awayTeamId)

            self.homeTeam = try container.decode(String.self, forKey: CodingKeys.homeTeam)
            self.awayTeam = try container.decode(String.self, forKey: CodingKeys.awayTeam)
            
            self.date = try container.decode(String.self, forKey: CodingKeys.date)
            self.dateTime = try container.decode(Date.self, forKey: CodingKeys.dateTime)
            self.time = try container.decode(String.self, forKey: CodingKeys.time)
            
            self.homeScore = try? container.decode(Int.self, forKey: CodingKeys.homeScore)
            self.awayScore = try? container.decode(Int.self, forKey: CodingKeys.awayScore)
            self.halfTimeScore = try? container.decode(String.self, forKey: CodingKeys.halfTimeScore)
            self.fullTimeScore = try? container.decode(String.self, forKey: CodingKeys.fullTimeScore)
            self.extraTimeScore = try? container.decode(String.self, forKey: CodingKeys.extraTimeScore)
            
            self.timer = try container.decodeIfPresent(String.self, forKey: CodingKeys.timer)
            
            self.isLive = false
            if let isLiveIntValue = try? container.decode(Int.self, forKey: CodingKeys.isLive) {
                self.isLive = isLiveIntValue != 0
            }
            else if let isLiveValue = try? container.decode(Bool.self, forKey: CodingKeys.isLive) {
                self.isLive = isLiveValue
            }
            
            if let statusString = try? container.decode(String.self, forKey: CodingKeys.status) {
                self.status = EventStatus(value: statusString, isLive: self.isLive)
            }
            else {
                self.status = .unknown
            }
            
            self.p1Score = try? container.decode(Int.self, forKey: CodingKeys.p1Score)
            self.p2Score = try? container.decode(Int.self, forKey: CodingKeys.p2Score)
            self.p3Score = try? container.decode(Int.self, forKey: CodingKeys.p3Score)
            self.p4Score = try? container.decode(Int.self, forKey: CodingKeys.p4Score)
            self.p5Score = try? container.decode(Int.self, forKey: CodingKeys.p5Score)

            self.sport = try container.decode(GomaModels.Sport.self, forKey: CodingKeys.sport)
            
            self.region = try container.decodeIfPresent(GomaModels.Region.self, forKey: CodingKeys.region)
            
            self.competition = try container.decodeIfPresent(GomaModels.Competition.self, forKey: CodingKeys.competition)
            
            self.placardInfo = try container.decodeIfPresent(GomaModels.PlacardInfo.self, forKey: CodingKeys.placardInfo)
            
            if let homeMetaContainer = try? container.nestedContainer(keyedBy: Event.TeamsMetaCodingKeys.self, forKey: .homeMetaInfo) {
                let country = try homeMetaContainer.decodeIfPresent(String.self, forKey: Event.TeamsMetaCodingKeys.country)
                let name = try homeMetaContainer.decodeIfPresent(String.self, forKey: Event.TeamsMetaCodingKeys.name)
                
                self.homeLogoUrl = "/\(country ?? "")/\(name ?? "")"
            }
            
            if let awayMetaContainer = try? container.nestedContainer(keyedBy: Event.TeamsMetaCodingKeys.self, forKey: .awayMetaInfo) {
                let country = try awayMetaContainer.decodeIfPresent(String.self, forKey: Event.TeamsMetaCodingKeys.country)
                let name = try awayMetaContainer.decodeIfPresent(String.self, forKey: Event.TeamsMetaCodingKeys.name)
                
                self.awayLogoUrl = "/\(country ?? "")/\(name ?? "")"
            }
        }
    }
    
    enum MyTicketResult: String, CaseIterable, Codable {
        case pending = "pending"
        case won = "win"
        case lost = "lost"
        case push = "push"
        case undefined = "undefined"
        
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "pending":
                self = .pending
            case "win":
                self = .won
            case "lost":
                self = .lost
            case "push":
                self = .push
            default:
                self = .undefined
            }
        }
    }
    
    enum MyTicketStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case won = "win"
        case lost = "lost"
        case push = "push"
        case undefined = "undefined"

        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "pending":
                self = .pending
            case "win":
                self = .won
            case "lost":
                self = .lost
            case "push":
                self = .push
            default:
                self = .undefined
            }
        }
    }
    
    struct MyTicketQRCode: Codable {
        var qrCode: String?
        var expirationDate: String?
        var message: String?
        
        enum CodingKeys: String, CodingKey {
            case qrCode = "qrCode"
            case expirationDate = "expirationDateTime"
            case message = "message"
        }
    }
}
