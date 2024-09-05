//
//  PromotedBetslip.swift
//  Sportsbook
//
//  Created by Ruben Roques on 02/08/2024.
//

import Foundation

struct SuggestedBetslip: Codable {
    var id: String
    var selections: [SuggestedBetslipSelection]
    
    init(selections: [SuggestedBetslipSelection]) {
        self.selections = selections
        self.id = selections.map(\.id).joined(separator: "-")
    }

    init(id: String, selections: [SuggestedBetslipSelection]) {
        self.id = id
        self.selections = selections
    }
    
}

struct SuggestedBetslipSelection: Codable, Hashable {
    
    var id: String
    
    var location: Location?
    var competitionName: String

    var participants: [Participant]
    var sport: Sport?
    var odd: Double

    var eventId: String
    var marketId: String
    var outcomeId: String

    var eventName: String
    var marketName: String
    var outcomeName: String

    init(id: String,
         location: Location? = nil,
         competitionName: String,
         participants: [Participant],
         sport: Sport? = nil,
         odd: Double,
         eventId: String,
         marketId: String,
         outcomeId: String,
         eventName: String,
         marketName: String,
         outcomeName: String)
    {
        self.id = id
        self.location = location
        self.competitionName = competitionName
        self.participants = participants
        self.sport = sport
        self.odd = odd
        self.eventId = eventId
        self.marketId = marketId
        self.outcomeId = outcomeId
        self.eventName = eventName
        self.marketName = marketName
        self.outcomeName = outcomeName
    }
    
}
