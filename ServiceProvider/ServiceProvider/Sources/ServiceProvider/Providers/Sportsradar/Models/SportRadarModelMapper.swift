//
//  File.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

struct SportRadarModelMapper {
    
    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {
        let events = internalEvents.map({ event in
            let markets = event.markets.map(Self.market(fromInternalMarket:))
            return Event(id: event.id,
                  homeTeamName: event.homeName,
                  awayTeamName: event.awayName,
                  sportTypeName: event.sportTypeName,
                  competitionId: event.competitionId,
                  competitionName: event.competitionName,
                  markets: markets)
        })
        
        return EventsGroup(events: events)
    }
 
    static func market(fromInternalMarket internalMarket: SportRadarModels.Market) -> Market {
        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))
        return Market(id: internalMarket.id, name: internalMarket.name, outcomes: outcomes)
    }
    
    static func outcome(fromInternalOutcome internalOutcome: SportRadarModels.Outcome) -> Outcome {
        return Outcome(id: internalOutcome.id, name: internalOutcome.name, odd: 1.0)
    }
    
    // ============================================================
    // Sports
    //
    static func sportType(fromInternalSportType internalSportType: SportRadarModels.SportType) -> SportType {
        switch internalSportType {
        case .football:
            return .football
        }
    }
    
    static func internalSportType(fromSportType sportType: SportType) -> SportRadarModels.SportType {
        switch sportType {
        case .football:
            return .football
        }
    }
    // ==========================================
    
}
