//
//  ServiceProviderModelMapper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import ServiceProvider

struct ServiceProviderModelMapper {
    
    static func matches(fromEventsGroups eventsGroups: [EventsGroup]) -> [Match] {
        var matches = [Match]()
        for eventsGroup in eventsGroups {
            for event in eventsGroup.events {
                
//                let markets = event.markets.map { market in
//                   let market = Market(id: <#T##String#>,
//                           typeId: <#T##String#>, name: <#T##String#>, nameDigit1: <#T##Double?#>, nameDigit2: <#T##Double?#>, nameDigit3: <#T##Double?#>, eventPartId: <#T##String?#>, bettingTypeId: <#T##String?#>, outcomes: <#T##[Outcome]#>)
//                }
                
                matches.append(Match(id: event.id,
                      competitionId: event.competitionId,
                      competitionName: event.competitionName,
                      homeParticipant: Participant(id: "", name: event.homeTeamName),
                      awayParticipant: Participant(id: "", name: event.awayTeamName),
                      sportType: event.sportTypeName,
                      numberTotalOfMarkets: 1,
                      markets: [],
                      rootPartId: ""))
            }
        }
        
        return matches
    }
    
    static func markets(fromServiceProviderMarket market: ServiceProvider.Market) -> [Market] {
        return []
    }
    
}
