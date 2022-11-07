//
//  ServiceProviderModelMapper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import ServiceProvider

struct ServiceProviderModelMapper {
    
    // Matches
    static func matches(fromEventsGroups eventsGroups: [EventsGroup]) -> [Match] {
        var matches = [Match]()
        for eventsGroup in eventsGroups {
            for event in eventsGroup.events {
                matches.append(Match(id: event.id,
                                     competitionId: event.competitionId,
                                     competitionName: event.competitionName,
                                     homeParticipant: Participant(id: "", name: event.homeTeamName),
                                     awayParticipant: Participant(id: "", name: event.awayTeamName),
                                     date: event.startDate,
                                     sportType: event.sportTypeName,
                                     numberTotalOfMarkets: 1,
                                     markets: Self.markets(fromServiceProviderMarkets: event.markets),
                                     rootPartId: ""))
            }
        }
        return matches
    }

    static func match(fromEventGroup eventGroup: EventsGroup) -> Match? {
        if let event = eventGroup.events[safe: 0] {

            let match = Match(id: event.id,
                              competitionId: event.competitionId,
                              competitionName: event.competitionName,
                              homeParticipant: Participant(id: "", name: event.homeTeamName),
                              awayParticipant: Participant(id: "", name: event.awayTeamName),
                              date: event.startDate,
                              sportType: event.sportTypeName,
                              numberTotalOfMarkets: 1,
                              markets: Self.markets(fromServiceProviderMarkets: event.markets),
                              rootPartId: "")
            return match
        }
        
        return nil
    }
    
    // Market
    static func markets(fromServiceProviderMarkets markets: [ServiceProvider.Market]) -> [Market] {
        return markets.map(Self.market(fromServiceProviderMarket:))
    }
    
    static func market(fromServiceProviderMarket market: ServiceProvider.Market) -> Market {
        return Market(id: market.id,
                      typeId: market.name,
                      name: market.name,
                      nameDigit1: nil,
                      nameDigit2: nil,
                      nameDigit3: nil,
                      eventPartId: nil,
                      bettingTypeId: market.eventMarketTypeId,
                      outcomes: Self.outcomes(fromServiceProviderOutcomes: market.outcomes),
                      marketTypeId: market.marketTypeId)
    }
    
    // Outcome
    static func outcomes(fromServiceProviderOutcomes outcomes: [ServiceProvider.Outcome]) -> [Outcome] {
        return outcomes.map(Self.outcome(fromServiceProviderOutcome:))
    }
    
    static func outcome(fromServiceProviderOutcome outcome: ServiceProvider.Outcome) -> Outcome {
        
        let bettingOffer = BettingOffer(id: outcome.id,
                                        value: outcome.odd,
                                        statusId: "",
                                        isLive: true,
                                        isAvailable: true)
        
        let outcome = Outcome(id: outcome.id,
                              codeName: outcome.name,
                              typeName: outcome.name,
                              translatedName: outcome.name,
                              bettingOffer: bettingOffer)
        return outcome
    }

    static func competitions(fromEventsGroups eventsGroups: [EventsGroup]) -> [Competition] {
        var competitions = [Competition]()

        return competitions
    }
    
}
