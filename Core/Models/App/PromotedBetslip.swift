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
    
    var marketName: String
    var outcomeName: String
    var eventName: String
   
    
}
