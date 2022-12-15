//
//  ServiceProviderModelMapper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import ServicesProvider

enum ServiceProviderModelMapper {
    
}
    
extension ServiceProviderModelMapper {
    
    // Matches
    static func matches(fromEventsGroups eventsGroups: [EventsGroup]) -> [Match] {
        var matches = [Match]()
        for eventsGroup in eventsGroups {
            for event in eventsGroup.events {
//                if event.homeTeamName != "" || event.awayTeamName != "" {
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
//                }
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

    static func event(fromEventGroup eventGroup: EventsGroup) -> ServicesProvider.Event? {
        if let event = eventGroup.events[safe: 0] {

            return event
        }

        return nil
    }
    
    // Market
    static func markets(fromServiceProviderMarkets markets: [ServicesProvider.Market]) -> [Market] {
        return markets.map(Self.market(fromServiceProviderMarket:))
    }
    
    static func market(fromServiceProviderMarket market: ServicesProvider.Market) -> Market {
        return Market(id: market.id,
                      typeId: market.name,
                      name: market.name,
                      nameDigit1: nil,
                      nameDigit2: nil,
                      nameDigit3: nil,
                      eventPartId: nil,
                      bettingTypeId: market.eventMarketTypeId,
                      outcomes: Self.outcomes(fromServiceProviderOutcomes: market.outcomes),
                      marketTypeId: market.marketTypeId,
                      eventName: market.eventName,
                      isMainOutright: market.isMainOutright)
    }

    static func optionalMarkets(fromServiceProviderMarkets markets: [ServicesProvider.Market]?) -> [Market]? {
        if let markets = markets {
            return markets.map(Self.market(fromServiceProviderMarket:))
        }
        return nil
    }
    
    // Outcome
    static func outcomes(fromServiceProviderOutcomes outcomes: [ServicesProvider.Outcome]) -> [Outcome] {
        return outcomes.map(Self.outcome(fromServiceProviderOutcome:))
    }
    
    static func outcome(fromServiceProviderOutcome outcome: ServicesProvider.Outcome) -> Outcome {
        
        let bettingOffer = BettingOffer(id: outcome.id,
                                        value: outcome.odd,
                                        statusId: "",
                                        isLive: true,
                                        isAvailable: true)
        
        let outcome = Outcome(id: outcome.id,
                              codeName: outcome.name,
                              typeName: outcome.name,
                              translatedName: outcome.name,
                              marketId: outcome.marketId,
                              bettingOffer: bettingOffer,
                              orderValue: outcome.orderValue,
                              externalReference: outcome.externalReference)
        return outcome
    }

    static func competitions(fromEventsGroups eventsGroups: [EventsGroup]) -> [Competition] {
        var competitions = [Competition]()

        if let event = eventsGroups.first {

            let mappedCompetitions = event.events.map({ event in
                let competition = Competition(id: event.id, name: event.competitionName, numberOutrightMarkets: event.markets.count,
                                              outrightMarkets: ServiceProviderModelMapper.markets(fromServiceProviderMarkets: event.markets))
                return competition
            })

            return mappedCompetitions
        }

        return competitions
    }

    static func competitionGroups(fromSportRegions sportRegions: [SportRegion]) -> [CompetitionGroup] {

        let competitionGroups = sportRegions.map({ sportRegion in
            let competitionGroup = CompetitionGroup(id: sportRegion.id, name: sportRegion.name ?? "", aggregationType: .region, competitions: [])
            return competitionGroup
        })

        return competitionGroups
    }

    static func competitionGroups(fromSportRegions sportRegions: [SportRegion], withRegionCompetitions regionCompetitions: [String: [SportCompetition]]) -> [CompetitionGroup] {

        let competitionGroups = sportRegions.map({ sportRegion in

            if let regionCompetitions = regionCompetitions[sportRegion.id] {
                let competitionGroup = CompetitionGroup(id: sportRegion.id, name: sportRegion.name ?? "", aggregationType: .region, competitions: self.competitions(fromSportCompetitions: regionCompetitions))
                return competitionGroup
            }

            let competitionGroup = CompetitionGroup(id: sportRegion.id, name: sportRegion.name ?? "", aggregationType: .region, competitions: [])
            return competitionGroup
        })

        return competitionGroups
    }

    static func competitions(fromSportCompetitions sportCompetitions: [SportCompetition]) -> [Competition] {

        let competitions = sportCompetitions.map({ sportCompetition in
            let competition = Competition(id: sportCompetition.id, name: sportCompetition.name, numberOutrightMarkets: 0,
                                          outrightMarkets: [])
            return competition
        })

        return competitions
    }
    
}
