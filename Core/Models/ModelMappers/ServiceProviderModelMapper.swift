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
        var matches = [Match?]()
        for eventsGroup in eventsGroups {
            for event in eventsGroup.events {
                matches.append(Self.match(fromEvent: event))
            }
        }
        return matches.compactMap({ $0 })
    }

    static func match(fromEventGroup eventGroup: EventsGroup) -> Match? {
        if let event = eventGroup.events[safe: 0] {
            return Self.match(fromEvent: event)
        }
        return nil
    }

    static func matches(fromEvents events: [ServicesProvider.Event]) -> [Match] {
        return events.map(Self.match(fromEvent:)).compactMap({ $0 })
    }

    static func match(fromEvent event: ServicesProvider.Event) -> Match? {

        guard event.type == .match else { return nil } // ignore competitions
        
        var venue: Location?
        if let venueCountry = event.venueCountry {
            venue = Location(id: venueCountry.iso2Code, name: venueCountry.name, isoCode: venueCountry.iso2Code)
        }

        let sport = Self.sport(fromServiceProviderSportType: event.sport)

        let mappedScores = Self.scoresDictionary(fromInternalScoresDictionary: event.scores)
        
        let match = Match(id: event.id,
                          competitionId: event.competitionId,
                          competitionName: event.competitionName,
                          homeParticipant: Participant(id: "", name: event.homeTeamName),
                          awayParticipant: Participant(id: "", name: event.awayTeamName),
                          homeParticipantScore: event.homeTeamScore,
                          awayParticipantScore: event.awayTeamScore,
                          date: event.startDate,
                          sport: sport,
                          sportIdCode: event.sportIdCode,
                          venue: venue,
                          numberTotalOfMarkets: event.numberMarkets ?? 0,
                          markets: Self.markets(fromServiceProviderMarkets: event.markets),
                          rootPartId: "",
                          status: Self.matchStatus(fromInternalEvent: event.status),
                          matchTime: event.matchTime,
                          promoImageURL: event.promoImageURL,
                          oldMainMarketId: event.oldMainMarketId,
                          competitionOutright: Self.competition(fromEvent: event),
                          detailedScores: mappedScores)
        return match
    }

    static func matchStatus(fromInternalEvent internalEventStatus: ServicesProvider.EventStatus?) -> Match.Status {
        guard let internalEventStatus else { return Match.Status.notStarted }

        switch internalEventStatus {
        case .unknown:
            return Match.Status.unknown
        case .notStarted:
            return Match.Status.notStarted
        case .inProgress(let detail):
            return Match.Status.inProgress(detail)
        case .ended:
            return Match.Status.ended
        }
    }
    
    static func matchLiveData(fromServiceProviderEvent event: ServicesProvider.Event) -> MatchLiveData {
        let mappeddStatus = Self.matchStatus(fromInternalEvent: event.status)
        
        let mappedScores = Self.scoresDictionary(fromInternalScoresDictionary: event.scores)
        
        return MatchLiveData(id: event.id,
                             homeScore: event.homeTeamScore,
                             awayScore: event.awayTeamScore,
                             matchTime: event.matchTime,
                             status: mappeddStatus,
                             detailedScores: mappedScores)
    }
    
    static func matchLiveData(fromServiceProviderEventLiveData eventLiveData: ServicesProvider.EventLiveData) -> MatchLiveData {
        let mappeddStatus = Self.matchStatus(fromInternalEvent: eventLiveData.status)
        
        let mappedScores = Self.scoresDictionary(fromInternalScoresDictionary: eventLiveData.detailedScores ?? [:])
        
        return MatchLiveData(id: eventLiveData.id,
                             homeScore: eventLiveData.homeScore,
                             awayScore: eventLiveData.awayScore,
                             matchTime: eventLiveData.matchTime,
                             status: mappeddStatus,
                             detailedScores: mappedScores)
    }

    // Market
    static func markets(fromServiceProviderMarkets markets: [ServicesProvider.Market]) -> [Market] {
        return markets.map(Self.market(fromServiceProviderMarket:))
    }
    
    static func market(fromServiceProviderMarket market: ServicesProvider.Market) -> Market {
        
        var mappedOutcomes = Self.outcomes(fromServiceProviderOutcomes: market.outcomes, marketName: market.name)
        
        var outcomesOrder: Market.OutcomesOrder
        switch market.outcomesOrder {
        case .name:
            outcomesOrder = .name
            mappedOutcomes = mappedOutcomes.sorted(by: \.translatedName)
        case .odds:
            outcomesOrder = .odds
            mappedOutcomes = mappedOutcomes.sorted(by: { leftOutcome, rightOutcome in
              
                let leftDecimal = leftOutcome.bettingOffer.decimalOdd
                let rightDecimal = rightOutcome.bettingOffer.decimalOdd
                
                if leftDecimal.isNaN {
                    return false
                } 
                else if rightDecimal.isNaN {
                    return true
                } 
                else {
                    return leftDecimal < rightDecimal
                }
            })
        case .setup:
            outcomesOrder = .setup
        case .none:
            outcomesOrder = .none
        }
        
//        #if DEBUG
//        var newMappedOutcomes = [Outcome]()
//        for (index, outcome) in mappedOutcomes.enumerated() {
//            var newOutcome = outcome
//            newOutcome.translatedName = "\(index)-" + outcome.translatedName
//            newMappedOutcomes.append(newOutcome)
//        }
//        mappedOutcomes = newMappedOutcomes
//        #endif
//        
        return Market(id: market.id,
                      typeId: market.name,
                      name: market.name,
                      nameDigit1: Double(market.marketDigitLine ?? ""),
                      nameDigit2: nil,
                      nameDigit3: nil,
                      eventPartId: nil,
                      bettingTypeId: market.eventMarketTypeId,
                      outcomes: mappedOutcomes,
                      marketTypeId: market.marketTypeId,
                      eventName: market.eventName,
                      isMainOutright: market.isMainOutright,
                      eventMarketCount: market.eventMarketCount,
                      isAvailable: market.isTradable,
                      startDate: market.startDate,
                      homeParticipant: market.homeParticipant,
                      awayParticipant: market.awayParticipant,
                      eventId: market.eventId,
                      outcomesOrder: outcomesOrder)
    }

    static func optionalMarkets(fromServiceProviderMarkets markets: [ServicesProvider.Market]?) -> [Market]? {
        if let markets = markets {
            return markets.map(Self.market(fromServiceProviderMarket:))
        }
        return nil
    }
    
    // Outcome
    static func outcomes(fromServiceProviderOutcomes outcomes: [ServicesProvider.Outcome], marketName: String) -> [Outcome] {
        return outcomes.map { outcome in
            return Self.outcome(fromServiceProviderOutcome: outcome, marketName: marketName)
        }
    }

    static func outcomes(fromServiceProviderOutcomes outcomes: [ServicesProvider.Outcome]) -> [Outcome] {
        return outcomes.map { outcome in
            return Self.outcome(fromServiceProviderOutcome: outcome, marketName: nil)
        }
    }

    static func outcome(fromServiceProviderOutcome outcome: ServicesProvider.Outcome) -> Outcome {
        return Self.outcome(fromServiceProviderOutcome: outcome, marketName: nil)
    }

    static func outcome(fromServiceProviderOutcome outcome: ServicesProvider.Outcome, marketName: String?) -> Outcome {
        let oddFormat: OddFormat = Self.oddFormat(fromServiceProviderOddFormat: outcome.odd)
        let bettingOffer = BettingOffer(id: outcome.id,
                                        odd: oddFormat,
                                        statusId: "",
                                        isLive: true,
                                        isAvailable: outcome.isTradable)

        let mappedOutcome = Outcome(id: outcome.id,
                              codeName: outcome.name,
                              typeName: outcome.name,
                              translatedName: outcome.name,
                                    marketName: marketName,
                              marketId: outcome.marketId, 
                              bettingOffer: bettingOffer,
                              orderValue: outcome.orderValue,
                              externalReference: outcome.externalReference)
        return mappedOutcome
    }

    static func oddFormat(fromServiceProviderOddFormat oddFormat: ServicesProvider.OddFormat) -> OddFormat {
        switch oddFormat {
        case .decimal(let odd):
            return .decimal(odd: odd)
        case .fraction(let numerator, let denominator):
            return .fraction(numerator: numerator, denominator: denominator)
        }
    }

    static func serviceProviderOddFormat(fromOddFormat oddFormat: OddFormat) -> ServicesProvider.OddFormat {
        switch oddFormat {
        case .decimal(let odd):
            return .decimal(odd: odd)
        case .fraction(let numerator, let denominator):
            return .fraction(numerator: numerator, denominator: denominator)
        }
    }
    
    static func competition(fromEvent event: ServicesProvider.Event) -> Competition {
        let sport = Self.sport(fromServiceProviderSportType: event.sport)
        
        let location = Location(id: event.venueCountry?.capital ?? "", name: event.venueCountry?.name ?? "", isoCode: event.venueCountry?.iso2Code ?? "")
        let competition = Competition(id: event.id,
                                      name: event.name ?? event.competitionName,
                                      venue: location,
                                      sport: sport,
                                      numberOutrightMarkets: event.markets.count,
                                      outrightMarkets: ServiceProviderModelMapper.markets(fromServiceProviderMarkets: event.markets))
        
        return competition
    }

    static func competitions(fromEventsGroups eventsGroups: [EventsGroup]) -> [Competition] {
        var competitions = [Competition]()

        if let firstEvent = eventsGroups.first {
            firstEvent.events.forEach { event in
                let sport = Self.sport(fromServiceProviderSportType: event.sport)
                let location = Location(id: event.venueCountry?.capital ?? "", name: event.venueCountry?.name ?? "", isoCode: event.venueCountry?.iso2Code ?? "")
                let competition = Competition(id: event.id,
                                              name: event.name ?? event.competitionName,
                                              venue: location,
                                              sport: sport,
                                              numberOutrightMarkets: event.markets.count,
                                              outrightMarkets: ServiceProviderModelMapper.markets(fromServiceProviderMarkets: event.markets))
                competitions.append(competition)
            }
        }

        return competitions
    }

    static func competitionGroups(fromSportRegions sportRegions: [SportRegion]) -> [CompetitionGroup] {

        let competitionGroups = sportRegions.map({ sportRegion in
            let competitionGroup = CompetitionGroup(id: sportRegion.id,
                                                    name: sportRegion.name ?? "",
                                                    aggregationType: .region,
                                                    competitions: [])
            return competitionGroup
        })

        return competitionGroups
    }

    static func competitionGroups(fromSportRegions sportRegions: [SportRegion], withRegionCompetitions regionCompetitions: [String: [SportCompetition]]) -> [CompetitionGroup] {

        let competitionGroups = sportRegions.map({ sportRegion in

            if let regionCompetitions = regionCompetitions[sportRegion.id] {
                var competitionGroup = CompetitionGroup(id: sportRegion.id,
                                                        name: sportRegion.name ?? "",
                                                        aggregationType: .region,
                                                        competitions: self.competitions(fromSportCompetitions: regionCompetitions))

                if let country = sportRegion.country {
                    competitionGroup.country = Self.country(fromServiceProviderCountry: country)
                }
                
                return competitionGroup
            }

            let competitionGroup = CompetitionGroup(id: sportRegion.id, name: sportRegion.name ?? "", aggregationType: .region, competitions: [])
            return competitionGroup
        })

        return competitionGroups
    }

    static func competitions(fromSportCompetitions sportCompetitions: [SportCompetition]) -> [Competition] {

        let competitions = sportCompetitions.map({ sportCompetition in
            let competition = Competition(id: sportCompetition.id,
                                          name: sportCompetition.name,
                                          sport: nil,
                                          numberOutrightMarkets: 0,
                                          outrightMarkets: [])
            return competition
        })

        return competitions
    }

    static func promotionalStory(fromPromotionalStory promotionalStory: ServicesProvider.PromotionalStory) -> PromotionalStory {

        return PromotionalStory(id: promotionalStory.id, title: promotionalStory.title, imageUrl: promotionalStory.imageUrl, linkUrl: promotionalStory.linkUrl, bodyText: promotionalStory.bodyText )
    }
}
