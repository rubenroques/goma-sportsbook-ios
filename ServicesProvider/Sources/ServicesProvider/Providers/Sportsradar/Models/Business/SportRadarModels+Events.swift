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

    struct EventLiveDataSummary: Decodable {
        var id: String
        var homeScore: Int
        var awayScore: Int

        var matchTime: String?
        var status: Event.Status

        enum CodingKeys: String, CodingKey {
            case scoresContainer = "scores"
            case currentScores = "CURRENT_SCORE"
            case matchScores = "MATCH_SCORE"
            case homeScore = "home"
            case awayScore = "away"
            case eventStatus = "status"
            case matchTime = "matchTime"
        }

        init(id: String, homeScore: Int, awayScore: Int, matchTime: String? = nil, status: Event.Status) {
            self.id = id
            self.homeScore = homeScore
            self.awayScore = awayScore
            self.matchTime = matchTime
            self.status = status
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            self.id = ""
            
            let fullMatchTime = try container.decodeIfPresent(String.self, forKey: .matchTime) ?? ""
            let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: fullMatchTime)
            self.matchTime = minutesPart

            // Status
            self.status = .unknown
            if let statusString = try? container.decode(String.self, forKey: .eventStatus) {
                self.status = Event.Status.init(value: statusString)
            }

            // Scores
            self.homeScore = 0
            self.awayScore = 0

            if let scoresContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .scoresContainer),
                let currentScoresContainer = try? scoresContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .currentScores) {

                if let homeScore = try? currentScoresContainer.decode(Int.self, forKey: .homeScore) {
                    self.homeScore = homeScore
                }
                if let awayScore = try? currentScoresContainer.decode(Int.self, forKey: .awayScore) {
                    self.awayScore = awayScore
                }
            }
            else if let scoresContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .scoresContainer),
                let matchScoresContainer = try? scoresContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .matchScores) {

                if let homeScore = try? matchScoresContainer.decode(Int.self, forKey: .homeScore) {
                    self.homeScore = homeScore
                }
                if let awayScore = try? matchScoresContainer.decode(Int.self, forKey: .awayScore) {
                    self.awayScore = awayScore
                }
            }
        }
    }

    struct EventLiveDataExtended: Decodable {
        var id: String?

        var homeScore: Int?
        var awayScore: Int?

        var matchTime: String?
        var status: Event.Status?
        
        enum CodingKeys: String, CodingKey {
            case targetEventId = "targetEventId"
            case attributedContainer = "attributes"
            case completeContainer = "COMPLETE"
            case currentScoreContainer = "CURRENT_SCORE"
            case competitorContainer = "COMPETITOR"
            case statusContainer = "STATUS"
            case eventContainer = "EVENT"
            case emptyContainer = ""
            case matchScoreContainer = "MATCH_SCORE"
            case homeScore = "home"
            case awayScore = "away"
            case eventStatus = "status"
            case matchTime = "matchTime"
        }

        init(id: String, homeScore: Int?, awayScore: Int?, matchTime: String?, status: Event.Status?) {
            self.id = id
            self.homeScore = homeScore
            self.awayScore = awayScore
            self.matchTime = matchTime
            self.status = status
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try container.decodeIfPresent(String.self, forKey: .targetEventId)

            self.matchTime = nil
            if let fullMatchTime = try container.decodeIfPresent(String.self, forKey: .matchTime),
               let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: fullMatchTime) {
                self.matchTime = minutesPart
            }

            // Status
            self.status = nil
            if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
               let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
               let statusContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .statusContainer),
               let eventContainer = try? statusContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .eventContainer) {
                let statusValue =  try eventContainer.decode(String.self, forKey: .emptyContainer)
                self.status = Event.Status.init(value: statusValue)
            }

            // Scores
            self.homeScore = nil
            self.awayScore = nil
            if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
               let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
               let currentScoreContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .currentScoreContainer),
               let competitorContainer = try? currentScoreContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .competitorContainer) {

                if let homeScore = try? competitorContainer.decode(Int.self, forKey: .homeScore) {
                    self.homeScore = homeScore
                }
                if let awayScore = try? competitorContainer.decode(Int.self, forKey: .awayScore) {
                    self.awayScore = awayScore
                }
            }
            else if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
                    let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
                    let matchScoreContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .matchScoreContainer),
                    let competitorContainer = try? matchScoreContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .competitorContainer) {

                if let homeScore = try? competitorContainer.decode(Int.self, forKey: .homeScore) {
                    self.homeScore = homeScore
                }
                if let awayScore = try? competitorContainer.decode(Int.self, forKey: .awayScore) {
                    self.awayScore = awayScore
                }
            }

            if self.matchTime == nil, self.status == nil, self.homeScore == nil, self.awayScore == nil {
                let context = DecodingError.Context(codingPath: [CodingKeys.attributedContainer], debugDescription: "No parsed content found on EventLiveDataExtended")
                throw DecodingError.valueNotFound(ContentRoute.self, context)
            }

        }
    }
    
    struct Event: Codable {
        
        var id: String
        var homeName: String?
        var awayName: String?
        var sportTypeName: String?
        var sportTypeCode: String?

        var competitionId: String?
        var competitionName: String?
        var startDate: Date?
        
        var markets: [Market]?

        var tournamentCountryName: String?
        
        var numberMarkets: Int?
        var name: String?

        var homeScore: Int
        var awayScore: Int

        var matchTime: String?
        var status: Status

        enum Status {
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

            case liveDataSummary = "liveDataSummary"

            case scoresContainer = "scores"
            case currentScores = "CURRENT_SCORE"
            case matchScores = "MATCH_SCORE"
            case homeScore = "home"
            case awayScore = "away"
            case eventStatus = "status"
            case matchTime = "matchTime"
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

            self.markets = try container.decodeIfPresent([SportRadarModels.Market].self, forKey: .markets)

            self.numberMarkets = container.contains(.numberMarkets) ? try container.decode(Int.self, forKey: .numberMarkets) : self.markets?.first?.eventMarketCount

            self.name = try container.decodeIfPresent(String.self, forKey: .name)

            self.sportTypeName = try container.decodeIfPresent(String.self, forKey: .sportTypeName)
            self.sportTypeCode = try container.decodeIfPresent(String.self, forKey: .sportTypeCode)


            #if DEBUG
            self.homeName = self.id + " " + (self.homeName ?? "")
            self.awayName = (self.markets?.first?.id ?? "") + " " + (self.awayName ?? "")
            #endif

            if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
                if let date = Self.dateFormatter.date(from: startDateString) {
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

            //  ---  Live Data  ---
            //
            if let liveDataInfoContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .liveDataSummary) {

                let fullMatchTime = try liveDataInfoContainer.decodeIfPresent(String.self, forKey: .matchTime) ?? ""
                let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: fullMatchTime)
                self.matchTime = minutesPart

                // Status
                self.status = .unknown
                if let statusString = try? liveDataInfoContainer.decode(String.self, forKey: .eventStatus) {
                    self.status = Self.Status.init(value: statusString)
                }

                // Scores
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

            }
            else {
                // No live information
                self.status = .unknown
                self.homeScore = 0
                self.awayScore = 0
            }
        }

        func encode(to encoder: Encoder) throws {

        }

        private static var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter
        }
    }
    
    struct Market: Codable {
        
        var id: String
        var name: String
        var outcomes: [Outcome]
        var marketTypeId: String?
        var eventMarketTypeId: String?
        var eventName: String?
        var isMainOutright: Bool?
        var eventMarketCount: Int?
        var isTradable: Bool
        var startDate: String?
        var homeParticipant: String?
        var awayParticipant: String?
        var eventId: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfomarket"
            case name = "name"
            case outcomes = "selections"
            case marketTypeId = "idefmarkettype"
            case eventMarketTypeId = "idfomarkettype"
            case eventName = "eventname"
            case isMainOutright = "ismainoutright"
            case eventMarketCount = "eventMarketCount"
            case isTradable = "istradable"
            case startDate = "tsstart"
            case homeParticipant = "participantname_home"
            case awayParticipant = "participantname_away"
            case eventId = "idfoevent"
        }

        init(id: String, name: String, outcomes: [Outcome], marketTypeId: String? = nil, eventMarketTypeId: String? = nil, eventName: String? = nil, isMainOutright: Bool? = nil, eventMarketCount: Int? = nil, isTradable: Bool, startDate: String? = nil, homeParticipant: String? = nil, awayParticipant: String? = nil, eventId: String? = nil) {
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
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: SportRadarModels.Market.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.marketTypeId = try container.decodeIfPresent(String.self, forKey: .marketTypeId)
            self.eventMarketTypeId = try container.decodeIfPresent(String.self, forKey: .eventMarketTypeId)
            self.eventName = try container.decodeIfPresent(String.self, forKey: .eventName)
            self.isMainOutright = try container.decodeIfPresent(Bool.self, forKey: .isMainOutright)
            self.eventMarketCount = try container.decodeIfPresent(Int.self, forKey: .eventMarketCount)
            self.isTradable = try container.decodeIfPresent(Bool.self, forKey: .isTradable) ?? true
            self.outcomes = try container.decode([SportRadarModels.Outcome].self, forKey: .outcomes)
            self.startDate = try container.decodeIfPresent(String.self, forKey: .startDate)
            self.homeParticipant = try container.decodeIfPresent(String.self, forKey: .homeParticipant)
            self.awayParticipant = try container.decodeIfPresent(String.self, forKey: .awayParticipant)
            self.eventId = try container.decodeIfPresent(String.self, forKey: .eventId)

            #if DEBUG
            self.name = self.id + " " + self.name
            #endif

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

            #if DEBUG
            self.name = self.id + " " + self.name
            #endif

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

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case marketGroups = "marketgroups"
            case numberOutrightEvents = "numoutrightevents"
            case numberOutrightMarkets = "numoutrightmarkets"
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
    
}



