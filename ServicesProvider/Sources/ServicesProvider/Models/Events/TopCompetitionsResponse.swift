//
//  TopCompetitionsResponse.swift
//  
//
//  Created by André Lascas on 05/07/2023.
//

import Foundation
import SharedModels

public struct TopCompetitionsResponse: Codable {
    public var data: [TopCompetitionData]
}

public struct TopCompetitionData: Codable {
    public var title: String
    public var competitions: [TopCompetitionPointer]
}

public typealias TopCompetitionPointers = [TopCompetitionPointer]

public struct TopCompetitionPointer: Codable {
    public var id: String
    public var name: String
    public var competitionId: String

    public init(id: String, name: String, competitionId: String) {
        self.id = id
        self.name = name
        self.competitionId = competitionId
    }

}

public typealias TopCompetitions = [TopCompetition]
public struct TopCompetition: Codable, Equatable {

    public var id: String
    public var name: String
    public var country: Country?
    public var sportType: SportType

    public init(id: String, name: String, country: Country?, sportType: SportType) {
        self.id = id
        self.name = name
        self.country = country
        self.sportType = sportType
    }

}
