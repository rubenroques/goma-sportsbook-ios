//
//  Events.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import SharedModels

public struct EventsGroup {
    public var events: [Event]

    public init(events: [Event]) {
        self.events = events
    }
}

public enum EventType: String {
    case match
    case competition
}

public class Event: Codable {

    public var id: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var sport: SportType

    public var homeTeamScore: Int?
    public var awayTeamScore: Int?

    public var competitionId: String
    public var competitionName: String
    public var startDate: Date
    
    public var markets: [Market]

    public var venueCountry: Country?
    public var numberMarkets: Int?

    public var name: String?

    public var status: Status?

    public var matchTime: String?

    public var type: EventType {
        if self.homeTeamName.isEmpty && self.awayTeamName.isEmpty {
            return .competition
        }
        else {
            return .match
        }
    }

    public enum Status {
        case unknown
        case notStarted
        case inProgress(String)
        case ended

        public init(value: String) {
            switch value {
            case "not_started": self = .notStarted
            case "ended": self = .ended
            default: self = .inProgress(value)
            }
        }
    }


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeTeamName = "homeName"
        case awayTeamName = "awayName"
        case competitionId = "competitionId"
        case competitionName = "competitionName"
        case sport = "sport"
        case startDate = "startDate"
        case markets = "markets"
        case venueCountry = "venueCountry"
        case numberMarkets = "numMarkets"
    }

    public init(id: String,
                homeTeamName: String,
                awayTeamName: String,
                homeTeamScore: Int?,
                awayTeamScore: Int?,
                competitionId: String,
                competitionName: String,
                sport: SportType,
                startDate: Date,
                markets: [Market],
                venueCountry: Country? = nil,
                numberMarkets: Int? = nil,
                name: String? = nil,
                status: Status?,
                matchTime: String?) {

        self.id = id
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName

        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore

        self.competitionId = competitionId
        self.competitionName = competitionName

        self.sport = sport

        self.startDate = startDate
        self.markets = markets
        self.venueCountry = venueCountry
        self.numberMarkets = numberMarkets

        self.name = name
        self.status = status
        self.matchTime = matchTime

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
    }

}

public class Market: Codable {
    
    public var id: String
    public var name: String
    public var outcomes: [Outcome]
    public var marketTypeId: String?
    public var eventMarketTypeId: String?
    public var eventName: String?
    public var isMainOutright: Bool?
    public var eventMarketCount: Int?
    public var isTradable: Bool
    public var startDate: String?
    public var homeParticipant: String?
    public var awayParticipant: String?
    public var eventId: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case outcomes = "outcomes"
        case marketTypeId = "marketTypeId"
        case eventMarketTypeId = "eventMarketTypeId"
        case eventName = "eventName"
        case isMainOutright = "ismainoutright"
        case eventMarketCount = "eventMarketCount"
        case isTradable = "isTradable"
        case startDate = "tsstart"
        case homeParticipant = "participantname_home"
        case awayParticipant = "participantname_away"
        case eventId = "idfoevent"
    }

    public init(id: String,
                name: String,
                outcomes: [Outcome],
                marketTypeId: String?,
                eventMarketTypeId: String?,
                eventName: String?,
                isMainOutright: Bool?,
                eventMarketCount: Int?,
                isTradable: Bool,
                startDate: String?,
                homeParticipant: String?,
                awayParticipant: String?,
                eventId: String?) {

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

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.outcomes = try container.decode([Outcome].self, forKey: .outcomes)
        self.marketTypeId = try container.decodeIfPresent(String.self, forKey: .marketTypeId)
        self.eventMarketTypeId = try container.decodeIfPresent(String.self, forKey: .eventMarketTypeId)
        self.eventName = try container.decodeIfPresent(String.self, forKey: .eventName)
        self.isMainOutright = try container.decodeIfPresent(Bool.self, forKey: .isMainOutright)
        self.eventMarketCount = try container.decodeIfPresent(Int.self, forKey: .eventMarketCount)
        self.isTradable = (try? container.decode(Bool.self, forKey: .isTradable)) ?? true
        self.eventId = try container.decodeIfPresent(String.self, forKey: .eventId)
    }

}

public class Outcome: Codable {
    
    public var id: String
    public var name: String
    public var odd: OddFormat
    public var marketId: String?
    public var orderValue: String?
    public var externalReference: String?
    public var isTradable: Bool

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case odd = "odd"
        case marketId = "marketId"
        case orderValue = "orderValue"
        case externalReference = "externalReference"
        case isTradable = "isTradable"
    }

    public init(id: String,
         name: String,
         odd: OddFormat,
         marketId: String?,
         orderValue: String?,
         externalReference: String?,
         isTradable: Bool) {

        self.id = id
        self.name = name
        self.odd = odd
        self.marketId = marketId
        self.orderValue = orderValue
        self.externalReference = externalReference
        self.isTradable = isTradable
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.odd = try container.decode(OddFormat.self, forKey: .odd)
        self.marketId = try container.decodeIfPresent(String.self, forKey: .marketId)
        self.orderValue = try container.decodeIfPresent(String.self, forKey: .orderValue)
        self.externalReference = try container.decodeIfPresent(String.self, forKey: .externalReference)
        self.isTradable = (try? container.decode(Bool.self, forKey: .isTradable)) ?? false
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

public struct EventMarket {
    public var id: String
    public var name: String
    public var marketIds: [String]

}

public struct AvailableMarket {
    public var marketId: String
    public var marketGroupId: String
    public var market: Market
}

public struct MarketGroup {

    public var type: String
    public var id: String
    public var groupKey: String?
    public var translatedName: String?
    public var position: Int?
    public var isDefault: Bool?
    public var numberOfMarkets: Int?
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

public struct SportCompetitionInfo: Codable {
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

public struct SportCompetitionMarketGroup: Codable {
    public var id: String
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwmarketgroup"
        case name = "name"
    }
}

public struct BannerResponse: Codable {
    public var bannerItems: [Banner]

    enum CodingKeys: String, CodingKey {
        case bannerItems = "headlineItems"
    }
}

public struct Banner: Codable {
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
