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
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case outcomes = "outcomes"
        case marketTypeId = "marketTypeId"
        case eventMarketTypeId = "eventMarketTypeId"
        case eventName = "eventName"
    }
    
}

public struct Outcome: Codable {
    
    public var id: String
    public var name: String
    public var odd: Double
    public var marketId: String?
    public var orderValue: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case odd = "odd"
        case marketId = "marketId"
        case orderValue = "orderValue"
    }
    
}


