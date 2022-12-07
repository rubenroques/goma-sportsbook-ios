//
//  File.swift
//  
//
//  Created by Ruben Roques on 26/10/2022.
//

import Foundation

extension SportRadarModels {
    
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
        
    }
    
    struct Market: Codable {
        
        var id: String
        var name: String
        var outcomes: [Outcome]
        var marketTypeId: String?
        var eventMarketTypeId: String?
        var eventName: String?

        enum CodingKeys: String, CodingKey {
            case id = "idfomarket"
            case name = "name"
            case outcomes = "selections"
            case marketTypeId = "idefmarkettype"
            case eventMarketTypeId = "idfomarkettype"
            case eventName = "eventname"
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
        }

    }
    
}
