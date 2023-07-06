//
//  SportRadarModels+TopCompetitionsResponse.swift
//  
//
//  Created by André Lascas on 05/07/2023.
//

import Foundation

extension SportRadarModels {

    struct TopCompetitionsResponse: Codable {

        var data: [TopCompetitionData]

        enum CodingKeys: String, CodingKey {
            case data = "data"
        }
    }

    struct TopCompetitionData: Codable {
        var title: String
        var competitions: [TopCompetition]

        enum CodingKeys: String, CodingKey {
            case title = "title"
            case competitions = "banneritems"
        }
    }

    struct TopCompetition: Codable {
        var id: String
        var name: String
        var competitionId: String

        enum CodingKeys: String, CodingKey {
            case id = "idfwbanneritem"
            case name = "name"
            case competitionId = "location"
        }
    }

}
