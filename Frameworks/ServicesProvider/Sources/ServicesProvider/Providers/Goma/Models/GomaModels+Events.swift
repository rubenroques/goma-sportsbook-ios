//
//  File.swift
//
//
//  Created by Ruben Roques on 22/12/2023.
//

import Foundation

extension GomaModels {
    
    struct EventMetadataPointer: Codable {
        var id: String?
        var eventId: String
        var eventMarketId: String
        var callToActionURL: String?
        var imageURL: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case eventId = "sport_event_id"
            case eventMarketId = "sport_event_market_id"
            case callToActionURL = "cta_url"
            case imageURL = "image_url"
            case meta
        }
        
        enum MetaKeys: String, CodingKey {
            case imgURL = "img_url"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try? container.decodeIfPresent(String.self, forKey: .id)
            self.eventId = try container.decode(String.self, forKey: .eventId)
            self.eventMarketId = try container.decode(String.self, forKey: .eventMarketId)
            self.callToActionURL = try? container.decodeIfPresent(String.self, forKey: .callToActionURL)
            self.imageURL = try? container.decodeIfPresent(String.self, forKey: .imageURL)

            if self.imageURL == nil, let metaContainer = try? container.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta) {
                self.imageURL = try? metaContainer.decodeIfPresent(String.self, forKey: .imgURL)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(id, forKey: .id)
            try container.encode(eventId, forKey: .eventId)
            try container.encode(eventMarketId, forKey: .eventMarketId)
            try container.encodeIfPresent(callToActionURL, forKey: .callToActionURL)
            try container.encodeIfPresent(imageURL, forKey: .imageURL)
        }
        
    }

    
    struct GomaPagedResponse<T: Codable>: Codable {
        var data: T
        var currentPage: Int?
        var itemsPerPage: Int?
        
        enum CodingKeys: String, CodingKey {
            case data = "data"
            case currentPage = "current_page"
            case itemsPerPage = "per_page"
        }
    }
    
    struct EventsPointerGroup: Codable {
        var events: [String]
        var title: String?
        
        enum CodingKeys: String, CodingKey {
            case events = "events"
            case title = "title"
        }
        
        init(events: [String], title: String? = nil) {
            self.events = events
            self.title = title
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.events = try container.decode([String].self, forKey: .events)
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
        }
        
    }
    
    struct EventsGroup: Codable {
        var events: Events
        var marketGroupId: String?
        
        enum CodingKeys: String, CodingKey {
            case events = "events"
            case marketGroupId = "market_id"
        }
        
        init(events: Events, marketGroupId: String?) {
            self.events = events
            self.marketGroupId = marketGroupId
        }
    }
    
    struct PopularEvent: Codable {
        var title: String?
        var events: [Event]
        
        enum CodingKeys: String, CodingKey {
            case title = "title"
            case events = "events"
        }
    }
    
    typealias Events = [Event]
    struct Event: Codable, Equatable {
        
        /*
         ,"home_team_meta":{"country":"Israel","name_livefeed":"Hapoel Haifa"},
         "away_team_meta":{"country":"Israel","name_livefeed":"Hapoel Hadera"},
         */
        
        var identifier: String
        
        var homeName: String
        var awayName: String
        
        var homeLogoUrl: String?
        var awayLogoUrl: String?
        
        var homeScore: Int?
        var awayScore: Int?
        
        var startDate: Date
        
        var sport: Sport
        var competition: Competition
        
        var status: EventStatus
        var isLive: Bool
        
        var placardInfo: PlacardInfo?
        var region: Region
        
        var matchTime: String?
        
        var markets: [Market]
        
        var metaDetails: MetaDetails?
        
        var scores: [String: Score]
        
        var imageUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case homeName = "home_team"
            case awayName = "away_team"
            
            case homeScore = "home_score"
            case awayScore = "away_score"
            
            case specialFTScore = "ft_score"
            case specialHTScore = "ht_score"
            case specialETScore = "et_score"
            
            case homeMetaInfo = "home_team_meta"
            case awayMetaInfo = "away_team_meta"
            
            case startDate = "date_time"
            
            case sport = "sport"
            case competition = "competition"
            case status = "status"
            case isLive = "is_live"
            
            case placardInfo = "placard_info"
            case region = "region"
            
            case matchTime = "timer"
            
            case markets = "markets"
            case market = "market"
            
            case metaDetails = "meta"
            
            case p1Score = "p1_score"
            case p2Score = "p2_score"
            case p3Score = "p3_score"
            case p4Score = "p4_score"
            case p5Score = "p5_score"
                   
            case imageUrl = "image_url"
        }
        
        enum TeamsMetaCodingKeys: String, CodingKey {
            case country = "country"
            case name = "name_livefeed"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.homeName = try container.decode(String.self, forKey: CodingKeys.homeName)
            self.awayName = try container.decode(String.self, forKey: CodingKeys.awayName)
            
            self.startDate = try container.decode(Date.self, forKey: CodingKeys.startDate)
            
            self.sport = try container.decode(GomaModels.Sport.self, forKey: CodingKeys.sport)
            self.competition = try container.decode(GomaModels.Competition.self, forKey: CodingKeys.competition)
            
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
            
            self.imageUrl = try? container.decodeIfPresent(String.self, forKey: CodingKeys.imageUrl)
            
            self.placardInfo = try container.decodeIfPresent(GomaModels.PlacardInfo.self, forKey: CodingKeys.placardInfo)
            self.region = try container.decode(GomaModels.Region.self, forKey: CodingKeys.region)
            
            self.matchTime = try container.decodeIfPresent(String.self, forKey: CodingKeys.matchTime)
            
            if let singleMarket = try? container.decode(GomaModels.Market.self, forKey: CodingKeys.market) {
                self.markets = [singleMarket]
            }
            else if let multipleMarkets = try? container.decode([GomaModels.Market].self, forKey: CodingKeys.markets) {
                self.markets = multipleMarkets
            }
            else {
                self.markets = []
            }
            
            if let homeMetaContainer = try? container.nestedContainer(keyedBy: TeamsMetaCodingKeys.self, forKey: .homeMetaInfo) {
                let country = try homeMetaContainer.decodeIfPresent(String.self, forKey: TeamsMetaCodingKeys.country)
                let name = try homeMetaContainer.decodeIfPresent(String.self, forKey: TeamsMetaCodingKeys.name)
                
                self.homeLogoUrl = "/\(country ?? "")/\(name ?? "")"
            }
            
            if let awayMetaContainer = try? container.nestedContainer(keyedBy: TeamsMetaCodingKeys.self, forKey: .awayMetaInfo) {
                let country = try awayMetaContainer.decodeIfPresent(String.self, forKey: TeamsMetaCodingKeys.country)
                let name = try awayMetaContainer.decodeIfPresent(String.self, forKey: TeamsMetaCodingKeys.name)
                
                self.awayLogoUrl = "/\(country ?? "")/\(name ?? "")"
            }
            
            self.metaDetails = try container.decodeIfPresent(MetaDetails.self, forKey: CodingKeys.metaDetails)
            
            self.homeScore = try container.decodeIfPresent(Int.self, forKey: CodingKeys.homeScore)
            self.awayScore = try container.decodeIfPresent(Int.self, forKey: CodingKeys.awayScore)
            
            // NEW SCORES
            var newScores = [String: Score]()
            
            // Current Score
            let score = Score.matchFull(home: self.homeScore, away: self.awayScore)
            newScores["matchFull"] = score
            
            // Part scores
            if let p1Score = try container.decodeIfPresent(String.self, forKey: CodingKeys.p1Score) {
                var homeScore = 0
                var awayScore = 0
                
                let stringWithoutBrackets = p1Score.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let numbers = stringWithoutBrackets.components(separatedBy: "-")

                // Convert the strings to integers
                if let home = Int(numbers[0]), let away = Int(numbers[1]) {
                    homeScore = home
                    awayScore = away
                }
                
                let p1NewScore = Score.set(index: 0, home: homeScore, away: awayScore)
                newScores["set1"] = p1NewScore

            }
            
            if let p2Score = try container.decodeIfPresent(String.self, forKey: CodingKeys.p2Score) {
                var homeScore = 0
                var awayScore = 0
                
                let stringWithoutBrackets = p2Score.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let numbers = stringWithoutBrackets.components(separatedBy: "-")

                // Convert the strings to integers
                if let home = Int(numbers[0]), let away = Int(numbers[1]) {
                    homeScore = home
                    awayScore = away
                }
                
                let p2NewScore = Score.set(index: 1, home: homeScore, away: awayScore)
                newScores["set2"] = p2NewScore

            }
            
            if let p3Score = try container.decodeIfPresent(String.self, forKey: CodingKeys.p3Score) {
                var homeScore = 0
                var awayScore = 0
                
                let stringWithoutBrackets = p3Score.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let numbers = stringWithoutBrackets.components(separatedBy: "-")

                // Convert the strings to integers
                if let home = Int(numbers[0]), let away = Int(numbers[1]) {
                    homeScore = home
                    awayScore = away
                }
                
                let p3NewScore = Score.set(index: 2, home: homeScore, away: awayScore)
                newScores["set3"] = p3NewScore

            }
            
            if let p4Score = try container.decodeIfPresent(String.self, forKey: CodingKeys.p4Score) {
                var homeScore = 0
                var awayScore = 0
                
                let stringWithoutBrackets = p4Score.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let numbers = stringWithoutBrackets.components(separatedBy: "-")

                // Convert the strings to integers
                if let home = Int(numbers[0]), let away = Int(numbers[1]) {
                    homeScore = home
                    awayScore = away
                }
                
                let p4NewScore = Score.set(index: 3, home: homeScore, away: awayScore)
                newScores["set4"] = p4NewScore

            }
            
            if let p5Score = try container.decodeIfPresent(String.self, forKey: CodingKeys.p5Score) {
                var homeScore = 0
                var awayScore = 0
                
                let stringWithoutBrackets = p5Score.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let numbers = stringWithoutBrackets.components(separatedBy: "-")

                // Convert the strings to integers
                if let home = Int(numbers[0]), let away = Int(numbers[1]) {
                    homeScore = home
                    awayScore = away
                }
                
                let p5NewScore = Score.set(index: 4, home: homeScore, away: awayScore)
                newScores["set5"] = p5NewScore

            }
            
            // Tennis
            // TODO: Add game_score when available
            if self.sport.identifier == "2" {
                let score = Score.gamePart(index: nil, home: self.homeScore, away: self.awayScore)
                newScores["gamePart"] = score
            }
            
            self.scores = newScores
            
            switch self.status {
            case .unknown, .notStarted, .inProgress:
                self.homeScore = try container.decodeIfPresent(Int.self, forKey: CodingKeys.homeScore)
                self.awayScore = try container.decodeIfPresent(Int.self, forKey: CodingKeys.awayScore)
                
            case .ended(let details):
                var scoreString: String = ""
                
                switch details?.lowercased() {
                case "ft":
                    scoreString = (try? container.decode(String.self, forKey: CodingKeys.specialFTScore)) ?? ""
                case "et":
                    scoreString = (try? container.decode(String.self, forKey: CodingKeys.specialETScore)) ?? ""
                case "ht":
                    scoreString = (try? container.decode(String.self, forKey: CodingKeys.specialHTScore)) ?? ""
                default:
                    scoreString = "\(self.homeScore ?? 0)-\(self.awayScore ?? 0)"
                }
                
                scoreString = scoreString.replacingOccurrences(of: "[", with: "")
                scoreString = scoreString.replacingOccurrences(of: "]", with: "")
                let resultParts = scoreString.components(separatedBy: "-")
                let homeScoreString = resultParts.first ?? ""
                let awayScoreString = resultParts.last ?? ""
                
                self.homeScore = Int(homeScoreString)
                self.awayScore = Int(awayScoreString)

            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: CodingKeys.identifier)
            try container.encodeIfPresent(self.homeName, forKey: CodingKeys.homeName)
            try container.encodeIfPresent(self.awayName, forKey: CodingKeys.awayName)
            try container.encodeIfPresent(self.startDate, forKey: CodingKeys.startDate)
            try container.encode(self.sport, forKey: CodingKeys.sport)
            try container.encode(self.competition, forKey: CodingKeys.competition)
            try container.encode(self.markets, forKey: CodingKeys.markets)
            try container.encodeIfPresent(self.imageUrl, forKey: CodingKeys.imageUrl)
        }
        
    }
    
    struct Region: Codable, Equatable {
        var identifier: String
        var name: String
        var isoCode: String?
        var preLiveEventsCount: Int?
        var liveEventsCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name = "name"
            case isoCode = "iso_code"
            case preLiveEventsCount = "pre_live_count"
            case liveEventsCount = "live_count"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.Region.CodingKeys> = try decoder.container(keyedBy: GomaModels.Region.CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: GomaModels.Region.CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: GomaModels.Region.CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.name = try container.decode(String.self, forKey: GomaModels.Region.CodingKeys.name)
            self.isoCode = try container.decodeIfPresent(String.self, forKey: GomaModels.Region.CodingKeys.isoCode)
            
            if let countString = try? container.decode(String.self, forKey: .preLiveEventsCount), let count = Int(countString) {
                self.preLiveEventsCount = count
            } else if let countInt = try container.decodeIfPresent(Int.self, forKey: .preLiveEventsCount) {
                self.preLiveEventsCount = countInt
            }
            else {
                self.preLiveEventsCount = 0
            }
            
            if let countString = try? container.decode(String.self, forKey: .liveEventsCount), let count = Int(countString) {
                self.liveEventsCount = count
            } else if let countInt = try container.decodeIfPresent(Int.self, forKey: .liveEventsCount) {
                self.liveEventsCount = countInt
            }
            else {
                self.liveEventsCount = 0
            }
        }
        
    }
    
    struct PlacardInfo: Codable, Equatable {
        var eventCode: String
        var tvChannelCode: String
        
        enum CodingKeys: String, CodingKey {
            case eventCode = "event_code"
            case tvChannelCode = "tv_channel"
        }
        
    }
    
    typealias Competitions = [Competition]
    
    struct Competition: Codable, Equatable {
        var identifier: String
        var name: String
        var region: Region?
        var sport: Sport?
        var preLiveEventsCount: Int?
        var liveEventsCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name = "name"
            case region = "region"
            case sport = "sport"
            case preLiveEventsCount = "pre_live_count"
            case liveEventsCount = "live_count"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.Competition.CodingKeys> = try decoder.container(keyedBy: GomaModels.Competition.CodingKeys.self)
            
            if let idValue = try? container.decode(Int.self, forKey: GomaModels.Competition.CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: GomaModels.Competition.CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.name = try container.decode(String.self, forKey: GomaModels.Competition.CodingKeys.name)
            
            if let regionContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .region) {
                self.sport = try regionContainer.decodeIfPresent(Sport.self, forKey: GomaModels.Competition.CodingKeys.sport)
                self.region = try container.decode(Region.self, forKey: GomaModels.Competition.CodingKeys.region)
            }
            
            if let countString = try? container.decode(String.self, forKey: .preLiveEventsCount), let count = Int(countString) {
                self.preLiveEventsCount = count
            } else if let countInt = try container.decodeIfPresent(Int.self, forKey: .preLiveEventsCount) {
                self.preLiveEventsCount = countInt
            }
            else {
                self.preLiveEventsCount = nil
            }
            
            if let countString = try? container.decode(String.self, forKey: .liveEventsCount), let count = Int(countString) {
                self.liveEventsCount = count
            } else if let countInt = try container.decodeIfPresent(Int.self, forKey: .liveEventsCount) {
                self.liveEventsCount = countInt
            }
            else {
                self.liveEventsCount = nil
            }
            
        }
        
    }
    
    enum EventStatus: Codable, Equatable {
        case unknown
        case notStarted
        case inProgress(String)
        case ended(details: String?)
        
        init(value: String, isLive: Bool) {
            if value.lowercased() == "not_started" {
                self = .notStarted
            }
            else if isLive {
                self = .inProgress(value)
            }
            else {
                self = .ended(details: value.lowercased())
            }
        }
        
        var stringValue: String {
            switch self {
            case .notStarted: return "not_started"
            case .ended(let details): return "ended(\(details ?? "")"
            case .inProgress(let value): return value
            case .unknown: return ""
            }
        }
        
    }
    
    
    struct Market: Codable, Equatable {
        
        var identifier: String
        var name: String
        var groupId: String
        var outcomes: [Outcome]
        var stats: Stats?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name = "name"
            case groupId = "sport_event_market_id"
            case outcomes = "outcomes"
            case stats = "stats"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.Market.CodingKeys> = try decoder.container(keyedBy: GomaModels.Market.CodingKeys.self)
            
            // Check if the identifier is Int or String
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.name = try container.decode(String.self, forKey: CodingKeys.name)
            
            if let singleOutcome = try? container.decode(GomaModels.Outcome.self, forKey: CodingKeys.outcomes) {
                self.outcomes = [singleOutcome]
            }
            else if let multipleOutcomes = try? container.decode([GomaModels.Outcome].self, forKey: CodingKeys.outcomes) {
                self.outcomes = multipleOutcomes
            }
            else {
                self.outcomes = []
            }
            
            self.stats = try? container.decode(Stats.self, forKey: CodingKeys.stats)
            
            if let groupId = try container.decodeIfPresent(Int.self, forKey: .groupId) {
                self.groupId = "\(groupId)"
            } else if let groupId = try container.decodeIfPresent(String.self, forKey: .groupId) {
                self.groupId = groupId
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.groupId, context)
                throw error
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.Market.CodingKeys.self)
            try container.encode(self.identifier, forKey: GomaModels.Market.CodingKeys.identifier)
            try container.encode(self.name, forKey: GomaModels.Market.CodingKeys.name)
            try container.encode(self.outcomes, forKey: GomaModels.Market.CodingKeys.outcomes)
        }
        
    }
    
    struct Outcome: Codable, Equatable {
        
        var identifier: String
        var name: String
        var code: String
        var odd: OddFormat
        var oddLive: OddFormat?
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name = "name"
            case code = "code"
            case oddValue = "price"
            case oddLiveValue = "price_live"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Check if the identifier is Int or String
            if let idValue = try? container.decode(Int.self, forKey: CodingKeys.identifier) {
                self.identifier = String(idValue)
            }
            else if let idStringValue = try? container.decode(String.self, forKey: CodingKeys.identifier) {
                self.identifier = idStringValue
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.identifier, context)
                throw error
            }
            
            self.name = try container.decode(String.self, forKey: .name)
            
            self.code = try container.decode(String.self, forKey: .code)
            
            if let oddValue = try? container.decode(String.self, forKey: CodingKeys.oddValue), let oddValueDouble = Double(oddValue) {
                self.odd = OddFormat.decimal(odd: oddValueDouble)
            }
            else if let oddValue = try? container.decode(Double.self, forKey: CodingKeys.oddValue) {
                self.odd = OddFormat.decimal(odd: oddValue)
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.oddValue, context)
                throw error
            }
            
            if let oddLiveValue = try? container.decode(String.self, forKey: CodingKeys.oddLiveValue), let oddLiveValueDouble = Double(oddLiveValue) {
                self.oddLive = OddFormat.decimal(odd: oddLiveValueDouble)
            }
            else if let oddLiveValue = try? container.decode(Double.self, forKey: CodingKeys.oddLiveValue) {
                self.oddLive = OddFormat.decimal(odd: oddLiveValue)
            }
            else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Key not found")
                let error = DecodingError.keyNotFound(CodingKeys.oddLiveValue, context)
                throw error
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.identifier, forKey: .identifier)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.code, forKey: .code)
            try container.encode(self.odd.decimalOdd, forKey: .oddValue)
        }
        
    }
    
    
    // MARK: - Meta
    struct MetaDetails: Codable, Equatable {
        var imageUrl: String
        
        enum CodingKeys: String, CodingKey {
            case imageUrl = "img_url"
        }
        
        init(imageUrl: String) {
            self.imageUrl = imageUrl
        }
    }
    
    struct Stats: Codable, Equatable {
        
        let awayParticipant: ParticipantStats
        let homeParticipant: ParticipantStats
        
        enum CodingKeys: String, CodingKey {
            case statsString = "stats"
            case data = "data"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let statsString = try container.decode(String.self, forKey: .statsString)
            
            let statsData = statsString.data(using: .utf8) ?? Data()
            let statsJSON = try JSONSerialization.jsonObject(with: statsData, options: []) as! [String: Any]
            
            let normalJSONData = try JSONSerialization.data(withJSONObject: statsJSON, options: [.prettyPrinted])
      
            let statsDataContainer = try JSONDecoder().decode(StatsDataContainer.self, from: normalJSONData)
            
            self.homeParticipant = statsDataContainer.data.homeParticipant
            self.awayParticipant = statsDataContainer.data.awayParticipant
        }
        
        func encode(to encoder: Encoder) throws {
            
        }
        
    }
    
    struct StatsDataContainer: Codable {
        var data: StatsData
    }

    struct StatsData: Codable {
        let homeParticipant: ParticipantStats
        let awayParticipant: ParticipantStats
        
        enum CodingKeys: String, CodingKey {
            case homeParticipant = "home_participant"
            case awayParticipant = "away_participant"
        }
        
    }

    struct ParticipantStats: Codable, Equatable {
        let total: Int
        let wins: Int?
        let draws: Int?
        let losses: Int?
        let over: Int?
        let under: Int?
        
        private enum CodingKeys: String, CodingKey {
            case total = "Total"
            case wins = "Wins"
            case draws = "Draws"
            case losses = "Losses"
            case over = "Over"
            case under = "Under"
            case yes = "Yes"
            case no = "No"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<GomaModels.ParticipantStats.CodingKeys> = try decoder.container(keyedBy: GomaModels.ParticipantStats.CodingKeys.self)
            self.total = try container.decode(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.total)
            self.wins = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.wins)
            self.draws = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.draws)
            self.losses = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.losses)
            
            if let overValue = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.over) {
                self.over = overValue
            }
            else if let yesValue = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.yes) {
                self.over = yesValue
            }
            else {
                self.over = nil
            }
            
            if let underValue = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.under) {
                self.under = underValue
            }
            else if let noValue = try container.decodeIfPresent(Int.self, forKey: GomaModels.ParticipantStats.CodingKeys.no) {
                self.under = noValue
            }
            else {
                self.under = nil
            }
            
        }
        
        init(total: Int, wins: Int?, draws: Int?, losses: Int?, over: Int?, under: Int?) {
            self.total = total
            self.wins = wins
            self.draws = draws
            self.losses = losses
            self.over = over
            self.under = under
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: GomaModels.ParticipantStats.CodingKeys.self)
            try container.encode(self.total, forKey: GomaModels.ParticipantStats.CodingKeys.total)
            try container.encodeIfPresent(self.wins, forKey: GomaModels.ParticipantStats.CodingKeys.wins)
            try container.encodeIfPresent(self.draws, forKey: GomaModels.ParticipantStats.CodingKeys.draws)
            try container.encodeIfPresent(self.losses, forKey: GomaModels.ParticipantStats.CodingKeys.losses)
            try container.encodeIfPresent(self.over, forKey: GomaModels.ParticipantStats.CodingKeys.over)
            try container.encodeIfPresent(self.under, forKey: GomaModels.ParticipantStats.CodingKeys.under)
        }
    }

}
