//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation

extension SportRadarModels {

    struct SportType: Codable, Hashable {
        var name: String
        var numericId: String?
        var alphaId: String?
        var numberEvents: Int
        var numberOutrightEvents: Int
        var numberOutrightMarkets: Int

        init(name: String,
                    numericId: String? = nil,
                    alphaId: String? = nil,
                    numberEvents: Int,
                    numberOutrightEvents: Int,
                    numberOutrightMarkets: Int) {

            self.name = name
            self.numericId = numericId
            self.alphaId = alphaId
            self.numberEvents = numberEvents
            self.numberOutrightEvents = numberOutrightEvents
            self.numberOutrightMarkets = numberOutrightMarkets
        }
    }

    struct SportTypeDetails: Codable {
        var sportType: SportType
        var eventsCount: Int
        var sportName: String

        enum CodingKeys: String, CodingKey {
            case sportType = "idfosporttype"
            case eventsCount = "numEvents"
            case sportName = "sporttypename"
        }

        init(sportType: SportType, eventsCount: Int, sportName: String) {
            self.sportType = sportType
            self.eventsCount = eventsCount
            self.sportName = sportName
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let sportTypeIdString = try container.decode(String.self, forKey: .sportType)
            let sportTypeName = try container.decode(String.self, forKey: .sportName)
            let eventsCount = try container.decode(Int.self, forKey: .eventsCount)

            self.sportType = SportType(name: sportTypeName,
                                           numericId: nil,
                                           alphaId: sportTypeIdString,
                                           numberEvents: eventsCount,
                                           numberOutrightEvents: 0,
                                           numberOutrightMarkets: 0)

            self.eventsCount = eventsCount
            self.sportName = sportTypeName
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.sportType, forKey: .sportType)
            try container.encode(self.eventsCount, forKey: .eventsCount)
            try container.encode(self.sportName, forKey: .sportName)
        }

    }

    struct SportsList: Codable {
        var sportNodes: [SportNode]?

        enum CodingKeys: String, CodingKey {
            case sportNodes = "bonavigationnodes"
        }
    }

    struct SportNode: Codable {
        var id: String
        var name: String
        var numberEvents: Int
        var numberOutrightEvents: Int
        var numberOutrightMarkets: Int

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case numberEvents = "numevents"
            case numberOutrightEvents = "numoutrightevents"
            case numberOutrightMarkets = "numoutrightmarkets"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.SportNode.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.SportNode.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SportRadarModels.SportNode.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: SportRadarModels.SportNode.CodingKeys.name)
            self.numberEvents = Int((try? container.decode(String.self, forKey: SportRadarModels.SportNode.CodingKeys.numberEvents)) ?? "0") ?? 0
            self.numberOutrightEvents = Int((try? container.decode(String.self, forKey: SportRadarModels.SportNode.CodingKeys.numberOutrightEvents)) ?? "0") ?? 0
            self.numberOutrightMarkets = Int((try? container.decode(String.self, forKey: SportRadarModels.SportNode.CodingKeys.numberOutrightMarkets)) ?? "0") ?? 0
        }
    }

    struct ScheduledSport: Codable {
        var id: String
        var name: String

        enum CodingKeys: String, CodingKey {
            case id = "idfosporttype"
            case name = "name"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.ScheduledSport.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.ScheduledSport.CodingKeys.self)
            self.id = try container.decode(String.self, forKey: SportRadarModels.ScheduledSport.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: SportRadarModels.ScheduledSport.CodingKeys.name)
        }
    }

}
