//
//  Events.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct EventsGroup {
    public var events: [Event]
}

public struct Event: Codable {
    
    public var id: String
    public var homeTeamName: String
    public var awayTeamName: String
    public var sportTypeName: String
    
    public var competitionId: String
    public var competitionName: String
    public var startDate: Date
    
    public var markets: [Market]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case homeTeamName = "homeName"
        case awayTeamName = "awayName"
        case competitionId = "competitionId"
        case competitionName = "competitionName"
        case sportTypeName = "sportTypeName"
        case startDate = "startDate"
        case markets = "markets"
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
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case outcomes = "outcomes"
        case marketTypeId = "marketTypeId"
        case eventMarketTypeId = "eventMarketTypeId"
        case eventName = "eventName"
        case isMainOutright = "ismainoutright"
    }
    
}

public struct Outcome: Codable {
    
    public var id: String
    public var name: String
    public var odd: Double
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

