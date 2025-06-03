//
//  Events.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import SharedModels


public class EventMetadataPointer: Codable {

    public var id: String?
    public var eventId: String
    public var eventMarketId: String
    public var callToActionURL: String?
    public var imageURL: String?

    init(id: String?, eventId: String, eventMarketId: String, callToActionURL: String?, imageURL: String?) {
        self.id = id
        self.eventId = eventId
        self.eventMarketId = eventMarketId
        self.callToActionURL = callToActionURL
        self.imageURL = imageURL
    }

}

public class EventsGroup {
    public var events: Events
    public var marketGroupId: String?
    public var title: String?

    public init(events: Events, marketGroupId: String?, title: String? = nil) {
        self.events = events
        self.marketGroupId = marketGroupId
        self.title = title
    }
}

public enum EventType: String, Equatable {
    case match
    case competition
}

public enum EventStatus: Hashable {
    case unknown
    case notStarted
    case inProgress(String)
    case ended(String)

    public init(value: String) {
        switch value {
        case "not_started": self = .notStarted
        case "ended": self = .ended(value)
        default: self = .inProgress(value)
        }
    }
}

public typealias Events = [Event]
public class Event: Codable, Hashable, Identifiable {

    public var id: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var sport: SportType
    public var sportIdCode: String?

    public var homeTeamScore: Int?
    public var awayTeamScore: Int?
    public var homeTeamLogoUrl: String?
    public var awayTeamLogoUrl: String?

    public var competitionId: String
    public var competitionName: String
    public var startDate: Date

    public var markets: [Market]

    public var venueCountry: Country?
    public var numberMarkets: Int?

    public var name: String?

    public var status: EventStatus?

    public var matchTime: String?

    public var promoImageURL: String?
    public var oldMainMarketId: String?

    public var trackableReference: String?

    public var activePlayerServing: ActivePlayerServe?

    public var boostedMarket: Market?

    public var type: EventType {
        if self.homeTeamName.isEmpty && self.awayTeamName.isEmpty {
            return .competition
        }
        else {
            return .match
        }
    }

    public var scores: [String: Score]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeTeamName = "homeName"
        case awayTeamName = "awayName"
        case competitionId = "competitionId"
        case competitionName = "competitionName"
        case sport = "sport"
        case sportIdCode = "sportIdCode"
        case startDate = "startDate"
        case markets = "markets"
        case venueCountry = "venueCountry"
        case numberMarkets = "numMarkets"
        case scores = "scores"
        case trackableReference = "trackableReference"
        case activePlayerServing = "activePlayerServing"
        case homeTeamLogoUrl = "homeTeamLogoUrl"
        case awayTeamLogoUrl = "awayTeamLogoUrl"
        case promoImageURL = "promoImageURL"
        case boostedMarket = "boostedMarket"
    }

    public init(id: String,
                homeTeamName: String,
                awayTeamName: String,
                homeTeamScore: Int?,
                awayTeamScore: Int?,
                homeTeamLogoUrl: String?,
                awayTeamLogoUrl: String?,
                competitionId: String,
                competitionName: String,
                sport: SportType,
                sportIdCode: String?,
                startDate: Date,
                markets: [Market],
                venueCountry: Country? = nil,
                numberMarkets: Int? = nil,
                name: String? = nil,
                trackableReference: String?,
                status: EventStatus?,
                matchTime: String?,
                activePlayerServing: ActivePlayerServe?,
                boostedMarket: Market?,
                promoImageURL: String?,
                scores: [String: Score]) {

        self.id = id
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName

        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore
        self.homeTeamLogoUrl = homeTeamLogoUrl
        self.awayTeamLogoUrl = awayTeamLogoUrl

        self.competitionId = competitionId
        self.competitionName = competitionName

        self.sport = sport
        self.sportIdCode = sportIdCode

        self.trackableReference = trackableReference

        self.startDate = startDate
        self.markets = markets
        self.venueCountry = venueCountry
        self.numberMarkets = numberMarkets

        self.name = name
        self.status = status
        self.matchTime = matchTime

        self.promoImageURL = promoImageURL
        self.oldMainMarketId = nil

        self.activePlayerServing = activePlayerServing

        self.boostedMarket = boostedMarket

        self.scores = scores
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.homeTeamName = try container.decode(String.self, forKey: .homeTeamName)
        self.awayTeamName = try container.decode(String.self, forKey: .awayTeamName)
        self.competitionId = try container.decode(String.self, forKey: .competitionId)
        self.competitionName = try container.decode(String.self, forKey: .competitionName)
        self.sport = try container.decode(SportType.self, forKey: .sport)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.markets = try container.decode([Market].self, forKey: .markets)
        self.venueCountry = try container.decodeIfPresent(Country.self, forKey: .venueCountry)
        self.numberMarkets = try container.decodeIfPresent(Int.self, forKey: .numberMarkets)
        self.sportIdCode = try container.decodeIfPresent(String.self, forKey: .sportIdCode)
        self.trackableReference = try container.decodeIfPresent(String.self, forKey: .trackableReference)
        self.activePlayerServing = try container.decodeIfPresent(ActivePlayerServe.self, forKey: .activePlayerServing)
        self.boostedMarket = try container.decodeIfPresent(Market.self, forKey: .boostedMarket)
        self.scores = (try? container.decode([String: Score].self, forKey: .scores)) ?? [:]

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.homeTeamName, forKey: .homeTeamName)
        try container.encode(self.awayTeamName, forKey: .awayTeamName)
        try container.encode(self.competitionId, forKey: .competitionId)
        try container.encode(self.competitionName, forKey: .competitionName)
        try container.encode(self.sport, forKey: .sport)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.markets, forKey: .markets)
        try container.encodeIfPresent(self.venueCountry, forKey: .venueCountry)
        try container.encodeIfPresent(self.numberMarkets, forKey: .numberMarkets)
        try container.encodeIfPresent(self.sportIdCode, forKey: .sportIdCode)
        try container.encodeIfPresent(self.trackableReference, forKey: .trackableReference)
        try container.encodeIfPresent(self.activePlayerServing, forKey: .activePlayerServing)
        try container.encodeIfPresent(self.boostedMarket, forKey: .boostedMarket)
    }

    public static func == (lhs: Event, rhs: Event) -> Bool {
        // Compare all properties for equality
        return lhs.id == rhs.id &&
        lhs.homeTeamName == rhs.homeTeamName &&
        lhs.awayTeamName == rhs.awayTeamName &&
        lhs.homeTeamScore == rhs.homeTeamScore &&
        lhs.awayTeamScore == rhs.awayTeamScore &&
        lhs.competitionId == rhs.competitionId &&
        lhs.competitionName == rhs.competitionName &&
        lhs.sport == rhs.sport &&
        lhs.startDate == rhs.startDate &&
        lhs.markets == rhs.markets &&
        lhs.venueCountry == rhs.venueCountry &&
        lhs.numberMarkets == rhs.numberMarkets &&
        lhs.name == rhs.name &&
        lhs.status == rhs.status &&
        lhs.matchTime == rhs.matchTime &&
        lhs.trackableReference == rhs.trackableReference &&
        lhs.scores == rhs.scores &&
        lhs.activePlayerServing == rhs.activePlayerServing
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(homeTeamName)
        hasher.combine(awayTeamName)
        hasher.combine(homeTeamScore)
        hasher.combine(awayTeamScore)
        hasher.combine(competitionId)
        hasher.combine(competitionName)
        hasher.combine(sport)
        hasher.combine(startDate)
        hasher.combine(markets)
        hasher.combine(venueCountry)
        hasher.combine(numberMarkets)
        hasher.combine(name)
        hasher.combine(status)
        hasher.combine(matchTime)
        hasher.combine(trackableReference)
        hasher.combine(scores)
        hasher.combine(activePlayerServing)
    }
}

public class HighlightMarket: Codable, Equatable {
    public var id: String {
        return market.id
    }
    public var market: Market
    public var enabledSelectionsCount: Int
    public var promotionImageURl: String?

    public init(market: Market, enabledSelectionsCount: Int, promotionImageURl: String?) {
        self.market = market
        self.enabledSelectionsCount = enabledSelectionsCount
        self.promotionImageURl = promotionImageURl
    }

    public static func == (lhs: HighlightMarket, rhs: HighlightMarket) -> Bool {
        // Compare all properties for equality
        return lhs.market == rhs.market &&
        lhs.enabledSelectionsCount == rhs.enabledSelectionsCount
    }
}

// Generic wrapper for any content that needs to be highlighted with an image
public typealias ImageHighlightedContents<T> = [ImageHighlightedContent<T>] where T: Codable, T: Hashable, T: Identifiable, T.ID == String

public class ImageHighlightedContent<T>: Codable, Hashable, Identifiable where T: Codable, T: Hashable, T: Identifiable, T.ID == String {
    public var content: T
    public var promotedChildCount: Int
    public var imageURL: String?
    
    // Forward the ID from the wrapped content
    public var id: String {
        return content.id
    }

    public init(content: T, promotedChildCount: Int, imageURL: String?) {
        self.content = content
        self.promotedChildCount = promotedChildCount
        self.imageURL = imageURL
    }

    public static func == (lhs: ImageHighlightedContent<T>, rhs: ImageHighlightedContent<T>) -> Bool {
        return lhs.content == rhs.content &&
               lhs.promotedChildCount == rhs.promotedChildCount &&
               lhs.imageURL == rhs.imageURL
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(content)
        hasher.combine(promotedChildCount)
        hasher.combine(imageURL ?? "")
    }
}

public class Market: Codable, Equatable, Hashable, Identifiable {

    public enum OutcomesOrder: Codable, Hashable {
        case none
        case odds // by odd
        case name // by name
        case setup // The original order that the server sends us
    }

    public var id: String
    public var name: String
    public var outcomes: [Outcome]
    
    public var marketTypeId: String?
    public var marketTypeName: String?
    
    public var marketFilterId: String?
    public var eventMarketTypeId: String?
    public var eventName: String?
    public var isMainOutright: Bool?
    public var eventMarketCount: Int?
    public var isTradable: Bool
    public var startDate: Date?
    public var homeParticipant: String?
    public var awayParticipant: String?
    public var eventId: String?
    public var marketDigitLine: String?
    public var outcomesOrder: OutcomesOrder
    public var customBetAvailable: Bool?

    public var stats: Stats?

    public var isMainMarket: Bool

    // Event related properties
    public var competitionId: String?
    public var competitionName: String?
    public var sport: SportType?
    public var sportIdCode: String?

    public var venueCountry: Country?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case outcomes = "outcomes"
        case marketTypeId = "marketTypeId"
        case marketTypeName = "marketTypeName"
        case marketFilterId = "marketFilterId"
        case eventMarketTypeId = "eventMarketTypeId"
        case eventName = "eventName"
        case isMainOutright = "ismainoutright"
        case eventMarketCount = "eventMarketCount"
        case isTradable = "isTradable"
        case startDate = "tsstart"
        case homeParticipant = "participantname_home"
        case awayParticipant = "participantname_away"
        case eventId = "idfoevent"
        case marketDigitLine = "marketDigitLine"
        case outcomesOrder = "outcomesOrder"
        case customBetAvailable = "custombetavailable"
        case sport = "sport"
        case sportIdCode = "sportIdCode"
        case venueCountry = "venueCountry"
        case isMainMarket = "isMainMarket"
        case stats = "stats"
    }

    public init(id: String,
                name: String,
                outcomes: [Outcome],
                
                marketTypeId: String?,
                marketTypeName: String?,
                
                marketFilterId: String?,
                eventMarketTypeId: String?,
                eventName: String?,
                isMainOutright: Bool?,
                eventMarketCount: Int?,
                isTradable: Bool,
                startDate: Date?,
                homeParticipant: String?,
                awayParticipant: String?,
                eventId: String?,
                marketDigitLine: String?,
                outcomesOrder: OutcomesOrder = .none,
                competitionId: String? = nil,
                competitionName: String? = nil,
                sport: SportType? = nil,
                sportIdCode: String?,
                venueCountry: Country? = nil,
                customBetAvailable: Bool?,
                isMainMarket: Bool,
                stats: Stats? = nil) {

        self.id = id
        self.name = name
        self.outcomes = outcomes
        self.marketTypeId = marketTypeId
        self.marketTypeName = marketTypeName
        self.marketFilterId = marketFilterId
        self.eventMarketTypeId = eventMarketTypeId
        self.eventName = eventName
        self.isMainOutright = isMainOutright
        self.eventMarketCount = eventMarketCount
        self.isTradable = isTradable
        self.startDate = startDate
        self.homeParticipant = homeParticipant
        self.awayParticipant = awayParticipant
        self.eventId = eventId
        self.marketDigitLine = marketDigitLine
        self.outcomesOrder = outcomesOrder

        // Event related properties
        self.competitionId = competitionId
        self.competitionName = competitionName

        self.sport = sport
        self.sportIdCode = sportIdCode

        self.venueCountry = venueCountry

        self.customBetAvailable = customBetAvailable
        self.isMainMarket = isMainMarket
        self.stats = stats
    }

    public static func == (lhs: Market, rhs: Market) -> Bool {
        // Compare all properties for equality
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.outcomes == rhs.outcomes &&
        lhs.marketTypeId == rhs.marketTypeId &&
        lhs.eventMarketTypeId == rhs.eventMarketTypeId &&
        lhs.eventName == rhs.eventName &&
        lhs.isMainOutright == rhs.isMainOutright &&
        lhs.eventMarketCount == rhs.eventMarketCount &&
        lhs.isTradable == rhs.isTradable &&
        lhs.startDate == rhs.startDate &&
        lhs.homeParticipant == rhs.homeParticipant &&
        lhs.awayParticipant == rhs.awayParticipant &&
        lhs.eventId == rhs.eventId &&
        lhs.outcomesOrder == rhs.outcomesOrder &&
        lhs.customBetAvailable == rhs.customBetAvailable &&
        lhs.isMainMarket == rhs.isMainMarket
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(outcomes)
        hasher.combine(marketTypeId)
        hasher.combine(eventMarketTypeId)
        hasher.combine(eventName)
        hasher.combine(isMainOutright)
        hasher.combine(eventMarketCount)
        hasher.combine(isTradable)
        hasher.combine(startDate)
        hasher.combine(homeParticipant)
        hasher.combine(awayParticipant)
        hasher.combine(eventId)
        hasher.combine(outcomesOrder)
        hasher.combine(customBetAvailable)
        hasher.combine(isMainMarket)
    }
}


public class Outcome: Codable, Equatable, Hashable {

    public var id: String
    public var name: String
    public var odd: OddFormat
    public var marketId: String?
    public var bettingOfferId: String?
    public var orderValue: String?
    public var externalReference: String?

    public var isTradable: Bool
    public var isTerminated: Bool

    public var customBetAvailableMarket: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case odd = "odd"
        case marketId = "marketId"
        case bettingOfferId = "bettingOfferId"
        case orderValue = "orderValue"
        case externalReference = "externalReference"
        case isTradable = "isTradable"
        case isTerminated = "isTerminated"
        case customBetAvailableMarket = "customBetAvailableMarket"
    }

    public init(id: String,
                name: String,
                odd: OddFormat,
                marketId: String? = nil,
                bettingOfferId: String? = nil,
                orderValue: String? = nil,
                externalReference: String? = nil,
                isTradable: Bool = true,
                isTerminated: Bool = false,
                customBetAvailableMarket: Bool?) {

        self.id = id
        self.name = name
        self.odd = odd
        self.marketId = marketId
        self.bettingOfferId = bettingOfferId
        self.orderValue = orderValue
        self.externalReference = externalReference
        self.isTradable = isTradable
        self.isTerminated = isTerminated
        self.customBetAvailableMarket = customBetAvailableMarket
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.odd = try container.decode(OddFormat.self, forKey: .odd)
        self.marketId = try container.decodeIfPresent(String.self, forKey: .marketId)
        self.bettingOfferId = try container.decodeIfPresent(String.self, forKey: .bettingOfferId)
        self.orderValue = try container.decodeIfPresent(String.self, forKey: .orderValue)
        self.externalReference = try container.decodeIfPresent(String.self, forKey: .externalReference)
        self.isTradable = (try? container.decode(Bool.self, forKey: .isTradable)) ?? false
        self.isTerminated = (try? container.decode(Bool.self, forKey: .isTerminated)) ?? false
        self.customBetAvailableMarket = try container.decodeIfPresent(Bool.self, forKey: .customBetAvailableMarket)
    }

    public static func == (lhs: Outcome, rhs: Outcome) -> Bool {
        // Compare all properties for equality
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.odd == rhs.odd &&
        lhs.marketId == rhs.marketId &&
        lhs.bettingOfferId == rhs.bettingOfferId &&
        lhs.orderValue == rhs.orderValue &&
        lhs.externalReference == rhs.externalReference &&
        lhs.isTradable == rhs.isTradable &&
        lhs.isTerminated == rhs.isTerminated &&
        lhs.customBetAvailableMarket == rhs.customBetAvailableMarket
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(odd)
        hasher.combine(marketId)
        hasher.combine(bettingOfferId)
        hasher.combine(orderValue)
        hasher.combine(externalReference)
        hasher.combine(isTradable)
        hasher.combine(isTerminated)
        hasher.combine(customBetAvailableMarket)
    }
}

public struct EventLiveData: Equatable {

    public var id: String
    public var homeScore: Int?
    public var awayScore: Int?
    public var matchTime: String?
    public var status: EventStatus?
    public var detailedScores: [String: Score]?
    public var activePlayerServing: ActivePlayerServe?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeScore = "homeScore"
        case awayScore = "awayScore"
        case matchTime = "matchTime"
        case status = "status"
        case detailedScores = "detailedScores"
        case activePlayerServing = "activePlayerServing"
    }

    public init(id: String,
                homeScore: Int?,
                awayScore: Int?,
                matchTime: String?,
                status: EventStatus?,
                detailedScores: [String: Score]?,
                activePlayerServing: ActivePlayerServe?)
    {
        self.id = id
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.matchTime = matchTime
        self.status = status
        self.detailedScores = detailedScores
        self.activePlayerServing = activePlayerServing
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        homeScore = try container.decodeIfPresent(Int.self, forKey: .homeScore)
        awayScore = try container.decodeIfPresent(Int.self, forKey: .awayScore)
        matchTime = try container.decodeIfPresent(String.self, forKey: .matchTime)

        // Decode the status based on the "status" key
        let statusValue = try container.decode(String.self, forKey: .status)
        status = EventStatus(value: statusValue)

        detailedScores = try container.decodeIfPresent([String: Score].self, forKey: .detailedScores)
        activePlayerServing = try container.decodeIfPresent(ActivePlayerServe.self, forKey: .activePlayerServing)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(homeScore, forKey: .homeScore)
        try container.encodeIfPresent(awayScore, forKey: .awayScore)
        try container.encodeIfPresent(matchTime, forKey: .matchTime)
        try container.encodeIfPresent(detailedScores, forKey: .detailedScores)
        try container.encodeIfPresent(activePlayerServing, forKey: .activePlayerServing)

        if let status = self.status {
            switch status {
            case .unknown:
                try container.encode("unknown", forKey: .status)
            case .notStarted:
                try container.encode("not_started", forKey: .status)
            case .inProgress(let value):
                try container.encode(value, forKey: .status)
            case .ended:
                try container.encode("ended", forKey: .status)
            }
        }
    }

}

public struct FieldWidget: Codable {
    public var data: String?
    public var version: Int?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case version = "version"
    }
}

public struct MarketGroupPointer {
    public var id: String
    public var name: String
    public var marketGroupIds: [String]
    public var groupOrder: Int
}

public struct AvailableMarket {
    public var marketId: String
    public var marketGroupId: String
    public var market: Market
    public var orderGroupOrder: Int
}

public struct MarketGroup {

    public var type: String
    public var id: String
    public var groupKey: String?
    public var translatedName: String?
    public var position: Int?
    public var isDefault: Bool?
    public var numberOfMarkets: Int?
    public var loaded: Bool
    public var markets: [Market]?
}

public struct FieldWidgetRenderData {
    public var url: URL?
    public var htmlString: String?
}

public enum FieldWidgetRenderDataType {
    case url(url: URL)
    case htmlString(url: URL, htmlString: String)
}

public enum StatsWidgetRenderDataType {
    case url(url: URL)
    case htmlString(url: URL, htmlString: String)
}

public struct SportNodeInfo: Codable {
    public var id: String
    public var regionNodes: [SportRegion]
    public var navigationTypes: [String]?
    public var name: String?
    public var defaultOrder: Int?
    public var numMarkets: String?
    public var numEvents: String?
    public var numOutrightMarkets: String?
    public var numOutrightEvents: String?

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

public struct SportRegion: Codable {
    public var id: String
    public var name: String?
    public var numberEvents: String
    public var numberOutrightEvents: String
    public var country: Country?

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case numberEvents = "numevents"
        case numberOutrightEvents = "numoutrightevents"
    }
}

public struct SportRegionInfo: Codable {
    public var id: String
    public var name: String
    public var competitionNodes: [SportCompetition]

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case competitionNodes = "bonavigationnodes"
    }
}

public struct SportCompetition: Codable {
    public var id: String
    public var name: String
    public var numberEvents: String
    public var numberOutrightEvents: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case numberEvents = "numevents"
        case numberOutrightEvents = "numoutrightevents"
    }
}

public struct SportCompetitionInfo: Codable, Hashable {
    public var id: String
    public var name: String
    public var marketGroups: [SportCompetitionMarketGroup]
    public var numberOutrightEvents: String
    public var numberOutrightMarkets: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case marketGroups = "marketgroups"
        case numberOutrightEvents = "numoutrightevents"
        case numberOutrightMarkets = "numoutrightmarkets"
    }

}

public struct SportCompetitionMarketGroup: Codable, Hashable {
    public var id: String
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwmarketgroup"
        case name = "name"
    }
}

public struct BannerResponse: Codable {
    public var bannerItems: [EventBanner]

    enum CodingKeys: String, CodingKey {
        case bannerItems = "headlineItems"
    }
}

// Renamed from Banner to EventBanner to avoid conflict with the consolidated version in Promotions
public struct EventBanner: Codable {
    public var id: String
    public var name: String
    public var title: String
    public var imageUrl: String
    public var bodyText: String?
    public var type: String
    public var linkUrl: String?
    public var marketId: String?

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
public struct FavoritesListResponse: Codable {
    public var favoritesList: [FavoriteList]

    enum CodingKeys: String, CodingKey {
        case favoritesList = "accountFavouriteCoupons"
    }
}

public struct FavoriteList: Codable {
    public var id: Int
    public var name: String
    public var customerId: Int

    enum CodingKeys: String, CodingKey {
        case id = "idfwAccountFavouriteCoupon"
        case name = "name"
        case customerId = "idmmCustomer"
    }
}

public struct FavoritesListAddResponse: Codable {
    public var listId: Int

    enum CodingKeys: String, CodingKey {
        case listId = "addAccountFavouriteCouponResult"
    }
}

public struct FavoritesListDeleteResponse: Codable {
    public var listId: String?

    enum CodingKeys: String, CodingKey {
        case listId = "addAccountFavouriteCouponResult"
    }
}

public struct FavoriteAddResponse: Codable {
    public var displayOrder: Int?
    public var idAccountFavorite: Int?

    enum CodingKeys: String, CodingKey {
        case displayOrder = "displayOrder"
        case idAccountFavorite = "idAccountFavourite"
    }
}

public struct FavoriteEventResponse: Codable {
    public var favoriteEvents: [FavoriteEvent]

    enum CodingKeys: String, CodingKey {
        case favoriteEvents = "accountFavourites"
    }
}

public struct FavoriteEvent: Codable {
    public var id: String
    public var name: String
    public var favoriteListId: Int
    public var accountFavoriteId: Int

    enum CodingKeys: String, CodingKey {
        case id = "favouriteId"
        case name = "favouriteName"
        case favoriteListId = "idfwAccountFavouriteCoupon"
        case accountFavoriteId = "idfwAccountFavourites"
    }

}

public struct HighlightedEventPointer : Codable {
    public var status: String
    public var sportId: String
    public var eventId: String
    public var eventType: String?
    public var countryId: String

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case sportId = "sport_id"
        case eventId = "event_id"
        case eventType = "event_type"
        case countryId = "country_id"
    }
}

public struct Stats: Codable, Equatable {
    public var homeParticipant: ParticipantStats
    public var awayParticipant: ParticipantStats
}

public struct ParticipantStats: Codable, Equatable {
    public var total: Int
    public var wins: Int?
    public var draws: Int?
    public var losses: Int?
    public var over: Int?
    public var under: Int?
}

public enum Score: Codable, Hashable {

    case set(index: Int, home: Int?, away: Int?)
    case gamePart(home: Int?, away: Int?)
    case matchFull(home: Int?, away: Int?)

    public var sortValue: Int {
        switch self {
        case .set(let index, _, _):
            return index
        case .gamePart:
            return 100
        case .matchFull:
            return 200
        }
    }

    public var key: String {
        switch self {
        case .set(let index, _, _):
            return "set\(index)"
        case .gamePart:
            return "gamePart"
        case .matchFull:
            return "matchFull"
        }
    }

}


public enum ActivePlayerServe: String, Codable {
    case home
    case away
}

public struct HeroGameEvent: Codable {
    public var event: Event
    public var image: String
}
