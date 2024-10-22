//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation

extension SportRadarModels {

    struct SportRadarResponse<T: Codable>: Codable {
        var data: T
        var version: Int?

        enum CodingKeys: String, CodingKey {
            case data = "data"
            case version = "value"
        }
    }


    struct EventsGroup: Codable {
        var events: [Event]
        var marketGroupId: String?

        enum CodingKeys: String, CodingKey {
            case events = "events"
            case marketGroupId = "idfwmarketgroup"
        }

        init(events: [Event], marketGroupId: String?) {
            self.events = events
            self.marketGroupId = marketGroupId
        }
    }

    struct MarketGroup: Codable {
        var markets: [Market]
        var marketGroupId: String?

        enum CodingKeys: String, CodingKey {
            case markets = "markets"
            case marketGroupId = "idfwmarketgroup"
        }

        init(events: [Market], marketGroupId: String?) {
            self.markets = events
            self.marketGroupId = marketGroupId
        }
    }
    
    enum EventStatus {
        case unknown
        case notStarted
        case inProgress(String)
        case ended

        init(value: String) {
            switch value {
            case "not_started": self = .notStarted
            case "ended": self = .ended
            default: self = .inProgress(value)
            }
        }

        var stringValue: String {
            switch self {
            case .notStarted: return "not_started"
            case .ended: return "ended"
            case .inProgress(let value): return value
            case .unknown: return ""
            }
        }
    }
    
    struct Event: Codable {
        
        var id: String
        var homeName: String?
        var awayName: String?
        var sportTypeName: String?
        var sportTypeCode: String?
        var sportIdCode: String?

        var competitionId: String?
        var competitionName: String?
        var startDate: Date?
        
        var markets: [Market]

        var tournamentCountryName: String?
        
        var numberMarkets: Int?
        var name: String?

        var homeScore: Int
        var awayScore: Int

        var matchTime: String?
        var status: EventStatus

        var scores: [String: Score]
        var activePlayerServing: ActivePlayerServe?

        var trackableReference: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoevent"
            case homeName = "participantname_home"
            case awayName = "participantname_away"
            case competitionId = "idfotournament"
            case competitionName = "tournamentname"
            case sportTypeName = "sporttypename"
            case startDate = "tsstart"
            case markets = "markets"
            case tournamentCountryName = "tournamentcountryname"
            case numberMarkets = "numMarkets"
            case name = "name"
            case sportTypeCode = "idfosporttype"
            case sportIdCode = "idfosport"
            case liveDataSummary = "liveDataSummary"

            case scoresContainer = "scores"
            case currentScores = "CURRENT_SCORE"
            case matchScores = "MATCH_SCORE"
            case homeScore = "home"
            case awayScore = "away"
            case eventStatus = "status"
            case matchTime = "matchTime"
            case activePlayerServing = "serve"
            
            case trackableReference = "externalreference"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.Event.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)

            if self.id == "_TOKEN_" {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "_TOKEN_ event found - Invalid Event on list ")
            }

            self.homeName = try container.decodeIfPresent(String.self, forKey: .homeName)
            self.awayName = try container.decodeIfPresent(String.self, forKey: .awayName)
            self.competitionId = try container.decodeIfPresent(String.self, forKey: .competitionId)
            self.competitionName = try container.decodeIfPresent(String.self, forKey: .competitionName)
            self.tournamentCountryName = try container.decodeIfPresent(String.self, forKey: .tournamentCountryName)

            if let markets = try container.decodeIfPresent([SportRadarModels.Market].self, forKey: .markets) {
                self.markets = markets
            }
            else if let market = try? Market(from: decoder) {
                // Check if we can parse a flatten event + market
                self.markets = [market]
            }
            else {
                self.markets = []
            }

            self.numberMarkets = container.contains(.numberMarkets) ? try container.decode(Int.self, forKey: .numberMarkets) : self.markets.first?.eventMarketCount

            self.name = try container.decodeIfPresent(String.self, forKey: .name)

            self.sportTypeName = try container.decodeIfPresent(String.self, forKey: .sportTypeName)
            self.sportTypeCode = try container.decodeIfPresent(String.self, forKey: .sportTypeCode)

            self.sportIdCode = try container.decodeIfPresent(String.self, forKey: .sportIdCode)

            self.trackableReference = try container.decodeIfPresent(String.self, forKey: .trackableReference)
            
//            #if DEBUG
//            self.homeName = self.id + " " + (self.homeName ?? "")
//            self.awayName = (self.markets.first?.id ?? "") + " " + (self.awayName ?? "")
//            #endif

            if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
                if let date = Self.dateFormatter.date(from: startDateString) {
                    self.startDate = date
                }
                else if let date = Self.fallbackDateFormatter.date(from: startDateString) {
                    self.startDate = date
                }
                else {
                    let context = DecodingError.Context(codingPath: [CodingKeys.startDate], debugDescription: "Start date with wrong format.")
                    throw DecodingError.typeMismatch(Self.self, context)
                }
            }
            else {
                let context = DecodingError.Context(codingPath: [CodingKeys.startDate], debugDescription: "Not start date found.")
                throw DecodingError.valueNotFound(Self.self, context)
            }

            //
            //  ---  Live Data  ---
            //
            if let liveDataInfoContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .liveDataSummary) {

                let fullMatchTime = try liveDataInfoContainer.decodeIfPresent(String.self, forKey: .matchTime) ?? ""
                let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: fullMatchTime)
                self.matchTime = minutesPart

                // Status
                self.status = .unknown
                if let statusString = try? liveDataInfoContainer.decode(String.self, forKey: .eventStatus) {
                    self.status = EventStatus.init(value: statusString)
                }

                // ----------------------------------------------------------------------------------------------------------------
                // Legacy Scores
                self.homeScore = 0
                self.awayScore = 0

                if let scoresContainer = try? liveDataInfoContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .scoresContainer),
                    let currentScoresContainer = try? scoresContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .currentScores) {

                    if let homeScore = try? currentScoresContainer.decode(Int.self, forKey: .homeScore) {
                        self.homeScore = homeScore
                    }
                    if let awayScore = try? currentScoresContainer.decode(Int.self, forKey: .awayScore) {
                        self.awayScore = awayScore
                    }
                }
                else if let scoresContainer = try? liveDataInfoContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .scoresContainer),
                    let matchScoresContainer = try? scoresContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .matchScores) {

                    if let homeScore = try? matchScoresContainer.decode(Int.self, forKey: .homeScore) {
                        self.homeScore = homeScore
                    }
                    if let awayScore = try? matchScoresContainer.decode(Int.self, forKey: .awayScore) {
                        self.awayScore = awayScore
                    }
                }
                // ----------------------------------------------------------------------------------------------------------------
                
                
                //
                // New scores business logic
                self.scores = [:]
                
                let completeContainer = try liveDataInfoContainer.nestedContainer(keyedBy: ScoreCodingKeys.self, forKey: .scoresContainer)
                
                let scoresArray = try completeContainer.allKeys.compactMap { key -> Score? in
                    let container = try completeContainer.nestedContainer(keyedBy: Score.CompetitorCodingKeys.self, forKey: key)
                    return try Score(from: container, key: key)
                }
                self.scores = Dictionary(uniqueKeysWithValues: scoresArray.map { ($0.key, $0) })
                //
                
                //
                // Serving player
                if let activePlayerServingString = try? liveDataInfoContainer.decodeIfPresent(String.self, forKey: .activePlayerServing) {
                   if activePlayerServingString == "1" {
                       self.activePlayerServing = .home
                   }
                   else if activePlayerServingString == "2" {
                       self.activePlayerServing = .away
                   }
               }
                else if let activePlayerServingInt = try? liveDataInfoContainer.decodeIfPresent(Int.self, forKey: .activePlayerServing) {
                    if activePlayerServingInt == 1 {
                        self.activePlayerServing = .home
                    }
                    else if activePlayerServingInt == 2 {
                        self.activePlayerServing = .away
                    }
                }
                
            }
            else {
                // No live information
                self.status = .unknown
                self.homeScore = 0
                self.awayScore = 0
                
                self.scores = [:]
                self.activePlayerServing = nil
            }
        }

        func encode(to encoder: Encoder) throws {

        }

        static var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter
        }
        
        static var fallbackDateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter
        }
    }
    
    struct Market: Codable {
        
        enum OutcomesOrder: Codable {
            case none
            case odds // by odd
            case name // by name
            case setup // The original order that the server sends us
        }
        
        var id: String
        var name: String
        var outcomes: [Outcome]
        var marketTypeId: String?
        var eventMarketTypeId: String?
        var eventName: String?
        var isMainOutright: Bool?
        var eventMarketCount: Int?
        var isTradable: Bool
        var startDate: Date?
        var homeParticipant: String?
        var awayParticipant: String?
        var eventId: String?

        var isOverUnder: Bool
        var marketDigitLine: String?
        var outcomesOrder: OutcomesOrder
    
        var competitionId: String?
        var competitionName: String?
        var sportTypeName: String?
        var sportTypeCode: String?
        var sportIdCode: String?
        var tournamentCountryName: String?
        
        var customBetAvailable: Bool?
        var isMainMarket: Bool

        enum CodingKeys: String, CodingKey {
            case id = "idfomarket"
            case name = "name"
            case outcomes = "selections"
            case marketTypeId = "idefmarkettype"
            case eventMarketTypeId = "idfomarkettype"
            
            case isMainOutright = "ismainoutright"
            case eventMarketCount = "eventMarketCount"
            case isTradable = "istradable"
            case startDate = "tsstart"
            case homeParticipant = "participantname_home"
            case awayParticipant = "participantname_away"
            
            case isOverUnder = "isunderover"
            case marketDigitLine = "line"
            case outcomesOrder = "idfoselectionorder"
            case customBetAvailable = "custombetavailable"
       
            case eventId = "idfoevent"
            case eventName = "eventname"
            case competitionId = "idfotournament"
            case competitionName = "tournamentname"
            case tournamentCountryName = "tournamentcountryname"
            case sportTypeName = "sportname"
            case sportTypeCode = "idfosporttype"
            case sportIdCode = "idfosport"

            case isMainMarket = "isMainMarket"
        }

        init(id: String, name: String,
             outcomes: [Outcome],
             marketTypeId: String? = nil,
             eventMarketTypeId: String? = nil,
             eventName: String? = nil,
             isMainOutright: Bool? = nil,
             eventMarketCount: Int? = nil,
             isTradable: Bool,
             startDate: Date? = nil,
             homeParticipant: String? = nil,
             awayParticipant: String? = nil,
             eventId: String? = nil,
             isOverUnder: Bool = false,
             marketDigitLine: String?,
             outcomesOrder: OutcomesOrder,
             //
             competitionId: String? = nil,
             competitionName: String? = nil,
             sportTypeName: String? = nil,
             sportTypeCode: String? = nil,
             sportIdCode: String? = nil,
             tournamentCountryName: String? = nil,

             customBetAvailable: Bool?,
             isMainMarket: Bool
        ) {
            self.id = id
            self.name = name
            self.outcomes = outcomes
            self.marketTypeId = marketTypeId
            self.eventMarketTypeId = eventMarketTypeId
            self.eventName = eventName
            self.isMainOutright = isMainOutright
            self.eventMarketCount = eventMarketCount
            self.isTradable = isTradable
            self.startDate = startDate
            self.homeParticipant = homeParticipant
            self.awayParticipant = awayParticipant
            self.eventId = eventId
            self.isOverUnder = isOverUnder
            self.marketDigitLine = marketDigitLine
            self.outcomesOrder = outcomesOrder
            //
            self.competitionId = competitionId
            self.competitionName = competitionName
            self.sportTypeName = sportTypeName
            self.sportTypeCode = sportTypeCode
            self.sportIdCode = sportIdCode
            self.tournamentCountryName = tournamentCountryName
            
            self.customBetAvailable = customBetAvailable
            self.isMainMarket = isMainMarket
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SportRadarModels.Market.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
           
            var nameValue = try container.decode(String.self, forKey: .name)
            nameValue = nameValue.replacingOccurrences(of: "\n", with: "")
            nameValue = nameValue.replacingOccurrences(of: "\r", with: "")
            self.name = nameValue
            
            self.marketTypeId = try container.decodeIfPresent(String.self, forKey: .marketTypeId)
            self.eventMarketTypeId = try container.decodeIfPresent(String.self, forKey: .eventMarketTypeId)
            self.eventName = try container.decodeIfPresent(String.self, forKey: .eventName)
            self.isMainOutright = try container.decodeIfPresent(Bool.self, forKey: .isMainOutright)
            self.eventMarketCount = try container.decodeIfPresent(Int.self, forKey: .eventMarketCount)
            self.isTradable = try container.decodeIfPresent(Bool.self, forKey: .isTradable) ?? true
            self.outcomes = try container.decode([SportRadarModels.Outcome].self, forKey: .outcomes)
            
            self.homeParticipant = try container.decodeIfPresent(String.self, forKey: .homeParticipant)
            self.awayParticipant = try container.decodeIfPresent(String.self, forKey: .awayParticipant)
            self.eventId = try container.decodeIfPresent(String.self, forKey: .eventId)
            
            self.isMainMarket = false

            if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
                if let date = Event.dateFormatter.date(from: startDateString) {
                    self.startDate = date
                }
                else if let date = Event.fallbackDateFormatter.date(from: startDateString) {
                    self.startDate = date
                }
                else {
                    self.startDate = nil
                }
            }
            else {
                self.startDate = nil
            }
            
            self.marketDigitLine = nil
            if let marketDigitLineString = try? container.decodeIfPresent(String.self, forKey: .marketDigitLine) {
                self.marketDigitLine = marketDigitLineString
            }
            else if let marketDigitLineDouble = try? container.decodeIfPresent(Double.self, forKey: .marketDigitLine) {
                self.marketDigitLine = String(marketDigitLineDouble)
            }
            
            self.outcomesOrder = .none
            if let outcomesOrderString = (try container.decodeIfPresent(String.self, forKey: .outcomesOrder)) {
                self.isOverUnder = false
                
                switch outcomesOrderString.lowercased() {
                case "odds":
                    self.outcomesOrder = .odds
                case "name":
                    self.outcomesOrder = .name
                case "setup":
                    self.outcomesOrder = .setup
                default:
                    self.outcomesOrder = .none
                }
            }
            
            self.isOverUnder = (try container.decodeIfPresent(Bool.self, forKey: .isOverUnder)) ?? false
            if self.isOverUnder {
                for index in self.outcomes.indices {
                    if (self.outcomes[index].orderValue ?? "").lowercased() == "h" {
                        self.outcomes[index].orderValue = "a"
                    }
                    else if (self.outcomes[index].orderValue ?? "").lowercased() == "a" {
                        self.outcomes[index].orderValue = "h"
                    }
                }
                self.outcomes = self.outcomes.reversed()
            }
            
            self.customBetAvailable = try container.decodeIfPresent(Bool.self, forKey: .customBetAvailable)

            self.competitionId = try container.decodeIfPresent(String.self, forKey: .competitionId)
            self.competitionName = try container.decodeIfPresent(String.self, forKey: .competitionName)
            
            self.sportTypeName = try container.decodeIfPresent(String.self, forKey: .sportTypeName)
            self.sportTypeCode = try container.decodeIfPresent(String.self, forKey: .sportTypeCode)
            self.sportIdCode = try container.decodeIfPresent(String.self, forKey: .sportIdCode)
            self.tournamentCountryName = try container.decodeIfPresent(String.self, forKey: .tournamentCountryName)

            //Apply custom bet available from market to outcome
            if let customBetAvailable {
                for index in self.outcomes.indices {
                    self.outcomes[index].customBetAvailableMarket = customBetAvailable
                }
            }
        }
        
        func encode(to encoder: Encoder) throws {
            //
        }
        
    }
    
    struct Outcome: Codable {
        
        var id: String
        var name: String
        var hashCode: String
        var marketId: String?
        var orderValue: String?
        var externalReference: String?

        var odd: OddFormat
        
        private var priceNumerator: String?
        private var priceDenominator: String?

        var isTradable: Bool?
        var isOverUnder: Bool

        var customBetAvailableMarket: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoselection"
            case name = "name"
            case hashCode = "selectionhashcode"
            case priceNumerator = "currentpriceup"
            case priceDenominator = "currentpricedown"
            case marketId = "idfomarket"
            case orderValue = "hadvalue"
            case externalReference = "externalreference"
            case isTradable = "istradable"
            case isOverUnder = "isunderover"
            case customBetAvailableMarket = "customBetAvailableMarket"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.Outcome.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.Outcome.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SportRadarModels.Outcome.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: SportRadarModels.Outcome.CodingKeys.name)
            self.hashCode = try container.decode(String.self, forKey: SportRadarModels.Outcome.CodingKeys.hashCode)
            self.priceNumerator = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.priceNumerator)
            self.priceDenominator = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.priceDenominator)
            self.marketId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.marketId)
            self.orderValue = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.orderValue)
            self.externalReference = try container.decodeIfPresent(String.self, forKey: SportRadarModels.Outcome.CodingKeys.externalReference)

            let numerator = Double(self.priceNumerator ?? "0.0") ?? 1.0
            let denominator = Double(self.priceDenominator ?? "0.0") ?? 1.0

            self.odd = .fraction(numerator: Int(numerator), denominator: Int(denominator) )
            self.isTradable = (try? container.decode(Bool.self, forKey: .isTradable)) ?? true

            self.isOverUnder = (try container.decodeIfPresent(Bool.self, forKey: SportRadarModels.Outcome.CodingKeys.isOverUnder)) ?? false
            if self.isOverUnder {
                if (self.orderValue ?? "").lowercased() == "h" {
                    self.orderValue = "a"
                }
                else if (self.orderValue ?? "").lowercased() == "a" {
                    self.orderValue = "h"
                }
            }
            
            self.customBetAvailableMarket = nil
            
//            #if DEBUG
//            self.name = self.id + " " + self.name
//            #endif

        }

    }

    struct SportNodeInfo: Codable {
        var id: String
        var regionNodes: [SportRegion]
        var navigationTypes: [String]?
        var name: String?
        var defaultOrder: Int?
        var numMarkets: String?
        var numEvents: String?
        var numOutrightMarkets: String?
        var numOutrightEvents: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case regionNodes = "bonavigationnodes"
            case navigationTypes = "idfwbonavigationtypes"
            case name = "name"
            case defaultOrder = "defaultOrder"
            case numMarkets = "nummarkets"
            case numEvents = "numevents"
            case numOutrightMarkets = "numoutrightmarkets"
            case numOutrightEvents = "numoutrightevents"
        }
    }

    struct SportRegion: Codable {
        var id: String
        var name: String?
        var numberEvents: String
        var numberOutrightEvents: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case numberEvents = "numevents"
            case numberOutrightEvents = "numoutrightevents"
        }
    }

    struct SportRegionInfo: Codable {
        var id: String
        var name: String
        var competitionNodes: [SportCompetition]

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case competitionNodes = "bonavigationnodes"
        }
    }

    struct SportCompetition: Codable {
        var id: String
        var name: String
        var numberEvents: String
        var numberOutrightEvents: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case numberEvents = "numevents"
            case numberOutrightEvents = "numoutrightevents"
        }
        
    }

    struct SportCompetitionInfo: Codable {

        var id: String
        var name: String
        var marketGroups: [SportCompetitionMarketGroup]
        var numberOutrightEvents: String
        var numberOutrightMarkets: String
        var parentId: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case marketGroups = "marketgroups"
            case numberOutrightEvents = "numoutrightevents"
            case numberOutrightMarkets = "numoutrightmarkets"
            case parentId = "idfwbonavigation_parent"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.SportCompetitionInfo.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.SportCompetitionInfo.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SportRadarModels.SportCompetitionInfo.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: SportRadarModels.SportCompetitionInfo.CodingKeys.name)
            self.marketGroups = try container.decode([SportRadarModels.SportCompetitionMarketGroup].self, forKey: SportRadarModels.SportCompetitionInfo.CodingKeys.marketGroups)
            self.numberOutrightEvents = try container.decode(String.self, forKey: SportRadarModels.SportCompetitionInfo.CodingKeys.numberOutrightEvents)
            self.numberOutrightMarkets = try container.decode(String.self, forKey: SportRadarModels.SportCompetitionInfo.CodingKeys.numberOutrightMarkets)
            self.parentId = try container.decodeIfPresent(String.self, forKey: SportRadarModels.SportCompetitionInfo.CodingKeys.parentId)
        }
    }

    struct SportCompetitionMarketGroup: Codable {
        var id: String
        var name: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwmarketgroup"
            case name = "name"
        }
    }

    struct CompetitionMarketGroup: Codable {
        var id: String
        var name: String
        var events: [Event]

        enum CodingKeys: String, CodingKey {
            case id = "idfwmarketgroup"
            case name = "name"
            case events = "events"
        }
    }

    struct CompetitionParentNode: Codable {
        var id: String
        var name: String
        var categoryName: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case categoryName = "contentcategoryname"
        }
    }

    // Banners
    struct BannerResponse: Codable {
        var bannerItems: [Banner]

        enum CodingKeys: String, CodingKey {
            case bannerItems = "headlineItems"
        }
    }

    struct Banner: Codable {
        var id: String
        var name: String
        var title: String
        var imageUrl: String
        var bodyText: String?
        var type: String
        var linkUrl: String?
        var marketId: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfwheadline"
            case name = "name"
            case title = "title"
            case imageUrl = "imageurl"
            case bodyText = "bodytext"
            case type = "idfwheadlinetype"
            case linkUrl = "linkurl"
            case marketId = "idfomarket"
        }
    }

    // Favorites
    struct FavoritesListResponse: Codable {
        var favoritesList: [FavoriteList]

        enum CodingKeys: String, CodingKey {
            case favoritesList = "accountFavouriteCoupons"
        }
    }

    struct FavoriteList: Codable {
        var id: Int
        var name: String
        var customerId: Int

        enum CodingKeys: String, CodingKey {
            case id = "idfwAccountFavouriteCoupon"
            case name = "name"
            case customerId = "idmmCustomer"
        }
    }

    struct FavoritesListAddResponse: Codable {
        var listId: Int

        enum CodingKeys: String, CodingKey {
            case listId = "addAccountFavouriteCouponResult"
        }
    }

    struct FavoritesListDeleteResponse: Codable {
        var listId: String?

        enum CodingKeys: String, CodingKey {
            case listId = "addAccountFavouriteCouponResult"
        }
    }

    struct FavoriteAddResponse: Codable {
        var displayOrder: Int?
        var idAccountFavorite: Int?

        enum CodingKeys: String, CodingKey {
            case displayOrder = "displayOrder"
            case idAccountFavorite = "idAccountFavourite"
        }
    }

    struct FavoriteEventResponse: Codable {
        var favoriteEvents: [FavoriteEvent]

        enum CodingKeys: String, CodingKey {
            case favoriteEvents = "accountFavourites"
        }
    }

    struct FavoriteEvent: Codable {
        var id: String
        var name: String
        var favoriteListId: Int
        var accountFavoriteId: Int

        enum CodingKeys: String, CodingKey {
            case id = "favouriteId"
            case name = "favouriteName"
            case favoriteListId = "idfwAccountFavouriteCoupon"
            case accountFavoriteId = "idfwAccountFavourites"
        }

    }
    
    struct HighlightedEventPointer : Codable {
        var status: String
        var sportId: String
        var eventId: String
        var eventType: String?
        var countryId: String

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case sportId = "sport_id"
            case eventId = "orako_event_id"
            case eventType = "event_type"
            case countryId = "country_id"
        }
        
        init(status: String, sportId: String, eventId: String, eventType: String? = nil, countryId: String) {
            self.status = status
            self.sportId = sportId
            self.eventId = eventId
            self.eventType = eventType
            self.countryId = countryId
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.HighlightedEventPointer.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.HighlightedEventPointer.CodingKeys.self)
            self.status = try container.decode(String.self, forKey: SportRadarModels.HighlightedEventPointer.CodingKeys.status)
            self.sportId = try container.decode(String.self, forKey: SportRadarModels.HighlightedEventPointer.CodingKeys.sportId)
            self.eventId = try container.decode(String.self, forKey: SportRadarModels.HighlightedEventPointer.CodingKeys.eventId)
            self.eventType = try container.decodeIfPresent(String.self, forKey: SportRadarModels.HighlightedEventPointer.CodingKeys.eventType)
            self.countryId = try container.decode(String.self, forKey: SportRadarModels.HighlightedEventPointer.CodingKeys.countryId)
        }
    }
    
}



