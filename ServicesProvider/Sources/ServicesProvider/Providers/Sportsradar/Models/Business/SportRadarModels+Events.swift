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
    
    struct Event: Codable {
        
        var id: String
        var homeName: String?
        var awayName: String?
        var sportTypeName: String?
        
        var competitionId: String?
        var competitionName: String?
        var startDate: Date?
        
        var markets: [Market]?
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoevent"
            case homeName = "participantname_home"
            case awayName = "participantname_away"
            case competitionId = "idfotournament"
            case competitionName = "tournamentname"
            case sportTypeName = "sporttypename"
            case startDate = "tsstart"
            case markets = "markets"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)

            self.homeName = container.contains(.homeName) ? try container.decode(String.self, forKey: .homeName) : nil
            self.awayName = container.contains(.awayName) ? try container.decode(String.self, forKey: .awayName) : nil
            self.competitionId = container.contains(.competitionId) ? try container.decode(String.self, forKey: .competitionId) : nil
            self.competitionName = container.contains(.competitionName) ? try container.decode(String.self, forKey: .competitionName) : nil
            self.sportTypeName = container.contains(.sportTypeName) ? try container.decode(String.self, forKey: .sportTypeName) : nil
            self.markets = container.contains(.markets) ? try container.decode([Market].self, forKey: .markets) : nil

            let dateString = container.contains(.startDate) ? try container.decode(String.self, forKey: .startDate) : nil

            if let dateString {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let date = formatter.date(from: dateString) {
                    self.startDate = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .startDate,
                                                           in: container,
                                                           debugDescription: "Date string does not match format expected by formatter.")
                }
            }


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

        enum CodingKeys: String, CodingKey {
            case id = "idfomarket"
            case name = "name"
            case outcomes = "selections"
            case marketTypeId = "idefmarkettype"
            case eventMarketTypeId = "idfomarkettype"
            case eventName = "eventname"
            case isMainOutright = "ismainoutright"
        }
        
    }
    
    struct Outcome: Codable {
        
        var id: String
        var name: String
        var hashCode: String
        var marketId: String?
        var orderValue: String?
        var externalReference: String?

        var odd: Double {
            let priceNumerator = Double(self.priceNumerator ?? "0.0") ?? 1.0
            let priceDenominator = Double(self.priceDenominator ?? "0.0") ?? 1.0
            return (priceNumerator/priceDenominator) + 1.0
        }
        
        private var priceNumerator: String?
        private var priceDenominator: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "idfoselection"
            case name = "name"
            case hashCode = "selectionhashcode"
            case priceNumerator = "currentpriceup"
            case priceDenominator = "currentpricedown"
            case marketId = "idfomarket"
            case orderValue = "hadvalue"
            case externalReference = "externalreference"
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
    
}



