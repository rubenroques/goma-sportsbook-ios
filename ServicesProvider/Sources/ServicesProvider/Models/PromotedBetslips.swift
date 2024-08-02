//
//  File.swift
//
//
//  Created by Ruben Roques on 01/08/2024.
//

import Foundation
import SharedModels

public struct PromotedBetslipsBatchResponse: Codable {
    public var promotedBetslips: [PromotedBetslip]
}

public struct PromotedBetslip: Codable {
    public var selections: [PromotedBetslipSelection]
    public var betslipCount: Int
}

public struct PromotedBetslipSelection: Codable {
    
    public var id: String
    public var country: Country?
    public var competitionName: String
    public var marketType: String
    public var eventId: String
    public var marketId: String
    public var outcomeId: String
    public var participantIds: [String]
    public var participants: [String]
    public var sport: SportType?
    public var odd: Double
    
    public var outcomeName: String {
        switch marketType.lowercased() {
        case "home":
            return (participants.first ?? "")
        case "draw":
            return "draw"
        case "away":
            return (participants.last ?? "")
        default:
            return ""
        }
    }
    
    public var eventName: String {
        return (participants.first ?? "") + " x " + (participants.last ?? "")
    }
    
    init(id: String, countryName: String, league: String, marketType: String, eventId: String, marketId: String, outcomeId: String, participantIds: [String], participants: [String], sport: SportType, odd: Double) {
        self.id = id
        self.competitionName = league
        self.marketType = marketType
        self.eventId = eventId
        self.marketId = marketId
        self.outcomeId = outcomeId
        self.participantIds = participantIds
        self.participants = participants
        self.sport = sport
        self.odd = odd
        self.country = Country.country(withName: countryName)
    }
    
}
