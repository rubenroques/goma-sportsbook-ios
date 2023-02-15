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

                var venue: Location?
                if let venueCountry = event.venueCountry {
                    venue = Location(id: venueCountry.iso2Code, name: venueCountry.name, isoCode: venueCountry.iso2Code)
                }

                matches.append(Match(id: event.id,
                                     competitionId: event.competitionId,
                                     competitionName: event.competitionName,
                                     homeParticipant: Participant(id: "", name: event.homeTeamName),
                                     awayParticipant: Participant(id: "", name: event.awayTeamName),
                                     date: event.startDate,
                                     sportType: event.sportTypeName,
                                     venue: venue,
                                     numberTotalOfMarkets: event.numberMarkets ?? 0,
                                     markets: Self.markets(fromServiceProviderMarkets: event.markets),
                                     rootPartId: ""))
            }
        }
        return matches
    }

//    static func matches(fromEvents events: [Event]) -> [Match] {
//        var matches = [Match]()
//
//        for event in events {
//            matches.append(Match(id: event.id,
//                                 competitionId: event.competitionId,
//                                 competitionName: event.competitionName,
//                                 homeParticipant: Participant(id: "", name: event.homeTeamName),
//                                 awayParticipant: Participant(id: "", name: event.awayTeamName),
//                                 date: event.startDate,
//                                 sportType: event.sportTypeName,
//                                 numberTotalOfMarkets: 1,
//                                 markets: Self.markets(fromServiceProviderMarkets: event.markets),
//                                 rootPartId: "")
//            )
//        }
//
//        return matches
//    }

    static func match(fromEventGroup eventGroup: EventsGroup) -> Match? {
        if let event = eventGroup.events[safe: 0] {

            var venue: Location?
            if let venueCountry = event.venueCountry {
                venue = Location(id: venueCountry.iso2Code, name: venueCountry.name, isoCode: venueCountry.iso2Code)
            }

            let match = Match(id: event.id,
                              competitionId: event.competitionId,
                              competitionName: event.competitionName,
                              homeParticipant: Participant(id: "", name: event.homeTeamName),
                              awayParticipant: Participant(id: "", name: event.awayTeamName),
                              date: event.startDate,
                              sportType: event.sportTypeName,
                              venue: venue,
                              numberTotalOfMarkets: 1,
                              markets: Self.markets(fromServiceProviderMarkets: event.markets),
                              rootPartId: "")
            return match
        }
        
        return nil
    }

    static func match(fromEvent event: ServicesProvider.Event) -> Match {

        var venue: Location?

        if let venueCountry = event.venueCountry {
            venue = Location(id: venueCountry.iso2Code, name: venueCountry.name, isoCode: venueCountry.iso2Code)
        }

        let match = Match(id: event.id,
                          competitionId: event.competitionId,
                          competitionName: event.competitionName,
                          homeParticipant: Participant(id: "", name: event.homeTeamName),
                          awayParticipant: Participant(id: "", name: event.awayTeamName),
                          date: event.startDate,
                          sportType: event.sportTypeName,
                          venue: venue,
                          numberTotalOfMarkets: 1,
                          markets: Self.markets(fromServiceProviderMarkets: event.markets),
                          rootPartId: "")
        return match

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
                      isMainOutright: market.isMainOutright,
                      eventMarketCount: market.eventMarketCount)
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
        let oddFormat: OddFormat = Self.oddFormat(fromServiceProviderOddFormat: outcome.odd)
        let bettingOffer = BettingOffer(id: outcome.id,
                                        odd:  oddFormat,
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

    static func oddFormat(fromServiceProviderOddFormat oddFormat: ServicesProvider.OddFormat) -> OddFormat {
        switch oddFormat {
        case .european(let odd):
            return .decimal(odd: odd)
        case .fraction(let numerator, let denominator):
            return .fraction(numerator: numerator, denominator: denominator)
        }
    }

    static func serviceProviderOddFormat(fromOddFormat oddFormat: OddFormat) -> ServicesProvider.OddFormat {
        switch oddFormat {
        case .decimal(let odd):
            return .european(odd: odd)
        case .fraction(let numerator, let denominator):
            return .fraction(numerator: numerator, denominator: denominator)
        }
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
