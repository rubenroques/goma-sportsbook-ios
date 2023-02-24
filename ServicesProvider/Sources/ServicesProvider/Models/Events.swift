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

public struct Event: Codable {

    public var id: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var sportTypeName: String

    public var homeTeamScore: Int?
    public var awayTeamScore: Int?

    public var competitionId: String
    public var competitionName: String
    public var startDate: Date
    
    public var markets: [Market]

    public var venueCountry: Country?
    public var numberMarkets: Int?

    public var name: String?

    public var type: EventType {
        if self.homeTeamName.isEmpty && self.awayTeamName.isEmpty {
            return .competition
        }
        else {
            return .match
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeTeamName = "homeName"
        case awayTeamName = "awayName"
        case competitionId = "competitionId"
        case competitionName = "competitionName"
        case sportTypeName = "sportTypeName"
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
                sportTypeName: String,
                competitionId: String,
                competitionName: String,
                startDate: Date,
                markets: [Market],
                venueCountry: Country? = nil,
                numberMarkets: Int? = nil,
                name: String? = nil) {

        self.id = id
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName

        self.homeTeamScore = homeTeamScore
        self.awayTeamScore = awayTeamScore

        self.sportTypeName = sportTypeName
        self.competitionId = competitionId
        self.competitionName = competitionName
        self.startDate = startDate
        self.markets = markets
        self.venueCountry = venueCountry
        self.numberMarkets = numberMarkets

        self.name = name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.homeTeamName = try container.decode(String.self, forKey: .homeTeamName)
        self.awayTeamName = try container.decode(String.self, forKey: .awayTeamName)
        self.competitionId = try container.decode(String.self, forKey: .competitionId)
        self.competitionName = try container.decode(String.self, forKey: .competitionName)
        self.sportTypeName = try container.decode(String.self, forKey: .sportTypeName)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.markets = try container.decode([Market].self, forKey: .markets)
        self.venueCountry = try container.decodeIfPresent(Country.self, forKey: .venueCountry)
        self.numberMarkets = try container.decodeIfPresent(Int.self, forKey: .numberMarkets)
    }

}

public struct Market: Codable {
    
    public var id: String
    public var name: String
    public var outcomes: [Outcome]
    public var marketTypeId: String?
    public var eventMarketTypeId: String?
    public var eventName: String?
    public var isMainOutright: Bool?
    public var eventMarketCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case outcomes = "outcomes"
        case marketTypeId = "marketTypeId"
        case eventMarketTypeId = "eventMarketTypeId"
        case eventName = "eventName"
        case isMainOutright = "ismainoutright"
        case eventMarketCount = "eventMarketCount"
    }
    
}

public struct Outcome: Codable {
    
    public var id: String
    public var name: String
    public var odd: OddFormat
    public var marketId: String?
    public var orderValue: String?
    public var externalReference: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case odd = "odd"
        case marketId = "marketId"
        case orderValue = "orderValue"
        case externalReference = "externalReference"
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

    enum CodingKeys: String, CodingKey {
        case id = "idfwheadline"
        case name = "name"
        case title = "title"
        case imageUrl = "imageurl"
        case bodyText = "bodytext"
        case type = "idfwheadlinetype"
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
