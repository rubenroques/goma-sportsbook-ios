//
//  TopCompetitionsResponse.swift
//  
//
//  Created by André Lascas on 05/07/2023.
//

import Foundation

public struct TopCompetitionsResponse: Codable {

    public var data: [TopCompetitionData]

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

public struct TopCompetitionData: Codable {
    public var title: String
    public var competitions: [TopCompetition]

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case competitions = "banneritems"
    }
}

public struct TopCompetition: Codable {
    public var id: String
    public var name: String
    public var competitionId: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwbanneritem"
        case name = "name"
        case competitionId = "location"
    }
}
