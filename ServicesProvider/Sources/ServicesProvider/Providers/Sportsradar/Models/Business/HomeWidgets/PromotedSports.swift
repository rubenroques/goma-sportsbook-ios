//
//  File.swift
//  
//
//  Created by Ruben Roques on 09/06/2023.
//

import Foundation


extension SportRadarModels {

    struct PromotedSportsResponse: Codable {

        var promotedSports: [PromotedSport]

        enum CodingKeys: String, CodingKey {
            case node = "bonavigationnodes"
            case promotedSports = "promotedSports"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)

            // root nodes
            let rawNodes = try container.decode([FailableDecodable<PromotedSportsNodeResponse>].self, forKey: .node)
            let validNodes = rawNodes.compactMap({ $0.content })

            var promotedSportsAccumulator: [PromotedSport] = []
            for validNode in validNodes {
                promotedSportsAccumulator.append(contentsOf: validNode.promotedSports)
            }

            self.promotedSports = promotedSportsAccumulator.filter({ !$0.marketGroups.isEmpty })
        }

        init(promotedSports: [PromotedSport]) {
            self.promotedSports = promotedSports
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.promotedSports, forKey: .promotedSports)
        }

    }

    struct PromotedSportsNodeResponse: Codable {

        var promotedSports: [PromotedSport]

        enum CodingKeys: String, CodingKey {
            case node = "bonavigationnodes"
            case name = "name"
            case promotedSports = "promotedSports"
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)

            if name.lowercased() == "popular" {
                let rawPromotedSports = try container.decode([FailableDecodable<SportRadarModels.PromotedSport>].self, forKey: .node)
                self.promotedSports = rawPromotedSports.compactMap({ $0.content })
            }
            else {
                let context = DecodingError.Context(codingPath: [CodingKeys.node], debugDescription: "PromotedSportsResponse popular node not found")
                throw DecodingError.valueNotFound(ContentRoute.self, context)
            }
            print("")
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.promotedSports, forKey: .promotedSports)
        }

    }

     struct PromotedSport: Codable {

         let id: String
         let name: String
         let marketGroups: [MarketGroupPromotedSport]

        enum CodingKeys: String, CodingKey {
            case id = "idfwbonavigation"
            case name = "name"
            case marketGroups = "marketgroups"
        }

         init(from decoder: Decoder) throws {
             let container: KeyedDecodingContainer<SportRadarModels.PromotedSport.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
             self.id = try container.decode(String.self, forKey: CodingKeys.id)
             self.name = try container.decode(String.self, forKey: CodingKeys.name)
             self.marketGroups = try container.decode([SportRadarModels.MarketGroupPromotedSport].self, forKey: CodingKeys.marketGroups)
         }
    }

    struct MarketGroupPromotedSport: Codable {

        let id: String
        let typeId: String?
        let name: String?

       enum CodingKeys: String, CodingKey {
           case id = "idfwmarketgroup"
           case typeId = "idfwmarketgrouptype"
           case name = "name"
       }

   }

}



