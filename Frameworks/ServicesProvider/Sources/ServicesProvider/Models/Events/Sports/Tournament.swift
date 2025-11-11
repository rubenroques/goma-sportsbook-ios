//
//  Tournament.swift
//
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

public struct Tournament: Codable, Hashable, Identifiable {
    public let type: String
    public let id: String
    public let idAsString: String?
    public let typeId: String?
    public let name: String?
    public let shortName: String?
    public let numberOfEvents: Int
    public let numberOfMarkets: Int?
    public let numberOfBettingOffers: Int?
    public let numberOfLiveEvents: Int
    public let numberOfLiveMarkets: Int?
    public let numberOfLiveBettingOffers: Int?
    public let numberOfOutrightMarkets: Int?
    public let numberOfUpcomingMatches: Int?
    public let sportId: String?
    public let sportName: String?
    public let shortSportName: String?
    public let venueId: String?
    public let venueName: String?
    public let shortVenueName: String?
    public let categoryId: String?
    public let templateId: String?
    public let templateName: String?
    public let rootPartId: String?
    public let rootPartName: String?
    public let shortRootPartName: String?

    public init(
        type: String,
        id: String,
        idAsString: String?,
        typeId: String?,
        name: String?,
        shortName: String?,
        numberOfEvents: Int,
        numberOfMarkets: Int?,
        numberOfBettingOffers: Int?,
        numberOfLiveEvents: Int,
        numberOfLiveMarkets: Int?,
        numberOfLiveBettingOffers: Int?,
        numberOfOutrightMarkets: Int?,
        numberOfUpcomingMatches: Int?,
        sportId: String?,
        sportName: String?,
        shortSportName: String?,
        venueId: String?,
        venueName: String?,
        shortVenueName: String?,
        categoryId: String?,
        templateId: String?,
        templateName: String?,
        rootPartId: String?,
        rootPartName: String?,
        shortRootPartName: String?
    ) {
        self.type = type
        self.id = id
        self.idAsString = idAsString
        self.typeId = typeId
        self.name = name
        self.shortName = shortName
        self.numberOfEvents = numberOfEvents
        self.numberOfMarkets = numberOfMarkets
        self.numberOfBettingOffers = numberOfBettingOffers
        self.numberOfLiveEvents = numberOfLiveEvents
        self.numberOfLiveMarkets = numberOfLiveMarkets
        self.numberOfLiveBettingOffers = numberOfLiveBettingOffers
        self.numberOfOutrightMarkets = numberOfOutrightMarkets
        self.numberOfUpcomingMatches = numberOfUpcomingMatches
        self.sportId = sportId
        self.sportName = sportName
        self.shortSportName = shortSportName
        self.venueId = venueId
        self.venueName = venueName
        self.shortVenueName = shortVenueName
        self.categoryId = categoryId
        self.templateId = templateId
        self.templateName = templateName
        self.rootPartId = rootPartId
        self.rootPartName = rootPartName
        self.shortRootPartName = shortRootPartName
    }

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id = "id"
        case idAsString = "idAsString"
        case typeId = "typeId"
        case name = "name"
        case shortName = "shortName"
        case numberOfEvents = "numberOfEvents"
        case numberOfMarkets = "numberOfMarkets"
        case numberOfBettingOffers = "numberOfBettingOffers"
        case numberOfLiveEvents = "numberOfLiveEvents"
        case numberOfLiveMarkets = "numberOfLiveMarkets"
        case numberOfLiveBettingOffers = "numberOfLiveBettingOffers"
        case numberOfOutrightMarkets = "numberOfOutrightMarkets"
        case numberOfUpcomingMatches = "numberOfUpcomingMatches"
        case sportId = "sportId"
        case sportName = "sportName"
        case shortSportName = "shortSportName"
        case venueId = "venueId"
        case venueName = "venueName"
        case shortVenueName = "shortVenueName"
        case categoryId = "categoryId"
        case templateId = "templateId"
        case templateName = "templateName"
        case rootPartId = "rootPartId"
        case rootPartName = "rootPartName"
        case shortRootPartName = "shortRootPartName"
    }
}
