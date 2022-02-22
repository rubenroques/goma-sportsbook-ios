//
//  Tournament.swift
//  Sportsbook
//
//  Created by André Lascas on 06/09/2021.
//

import Foundation

extension EveryMatrix {

    struct Tournament: Decodable {
        
        let type: String
        let id: String
        let idAsString: String?
        let typeId: String?
        let name: String?
        let shortName: String?
        let numberOfEvents: Int?
        let numberOfMarkets: Int?
        let numberOfBettingOffers: Int?
        let numberOfLiveEvents: Int?
        let numberOfLiveMarkets: Int?
        let numberOfLiveBettingOffers: Int?
        let numberOfOutrightMarkets: Int?
        let numberOfUpcomingMatches: Int?
        let sportId: String?
        let sportName: String?
        let shortSportName: String?
        let venueId: String?
        let venueName: String?
        let shortVenueName: String?
        let categoryId: String?
        let templateId: String?
        let templateName: String?
        let rootPartId: String?
        let rootPartName: String?
        let shortRootPartName: String?
        
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
}
