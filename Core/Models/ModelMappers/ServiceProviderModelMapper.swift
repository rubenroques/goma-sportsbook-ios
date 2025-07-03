//
//  ServiceProviderModelMapper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation
import ServicesProvider
import SharedModels

enum ServiceProviderModelMapper {
    
}
    
extension ServiceProviderModelMapper {
    
    // MARK: - Main Markets
    
    /// Extracts and maps main markets from EventsGroups
    /// Returns nil if no main markets are available
    static func mainMarkets(fromEventsGroups eventsGroups: [ServicesProvider.EventsGroup]) -> [MainMarket]? {
        // Get main markets from the first EventsGroup that has them
        // All groups should have the same main markets for a given sport
        guard let firstGroupWithMainMarkets = eventsGroups.first(where: { $0.mainMarkets != nil }),
              let serviceProviderMainMarkets = firstGroupWithMainMarkets.mainMarkets,
              !serviceProviderMainMarkets.isEmpty else {
            return nil
        }
        
        return serviceProviderMainMarkets.map { mainMarket(fromServiceProviderMainMarket: $0) }
    }
    
    /// Maps a ServicesProvider.MainMarket to the app's MainMarket model
    static func mainMarket(fromServiceProviderMainMarket spMainMarket: ServicesProvider.MainMarket) -> MainMarket {
        return MainMarket(
            id: spMainMarket.id,
            bettingTypeId: spMainMarket.bettingTypeId,
            bettingTypeName: spMainMarket.bettingTypeName,
            eventPartId: spMainMarket.eventPartId,
            eventPartName: spMainMarket.eventPartName,
            sportId: spMainMarket.sportId,
            numberOfOutcomes: spMainMarket.numberOfOutcomes,
            isLiveMarket: spMainMarket.liveMarket,
            isOutright: spMainMarket.outright
        )
    }
    
    // MARK: - Matches
    
    static func matches(fromEventsGroups eventsGroups: [ServicesProvider.EventsGroup]) -> [Match] {
        var matches = [Match?]()
        for eventsGroup in eventsGroups {
            for event in eventsGroup.events {
                matches.append(Self.match(fromEvent: event))
            }
        }
        return matches.compactMap({ $0 })
    }
    
    static func match(fromEventGroup eventGroup: ServicesProvider.EventsGroup) -> Match? {
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
        
        var mappedActivePlayerServe: Match.ActivePlayerServe?
        switch event.activePlayerServing {
        case .home:
            mappedActivePlayerServe = .home
        case .away:
            mappedActivePlayerServe = .away
        case .none:
            mappedActivePlayerServe = nil
        }
        
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
                          trackableReference: event.trackableReference,
                          matchTime: event.matchTime,
                          promoImageURL: event.promoImageURL,
                          oldMainMarketId: event.oldMainMarketId,
                          competitionOutright: Self.competition(fromEvent: event),
                          activePlayerServe: mappedActivePlayerServe,
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
        
        var mappedActivePlayerServe: Match.ActivePlayerServe?
        switch event.activePlayerServing {
        case .home:
            mappedActivePlayerServe = .home
        case .away:
            mappedActivePlayerServe = .away
        case .none:
            mappedActivePlayerServe = nil
        }
        
        return MatchLiveData(id: event.id,
                             homeScore: event.homeTeamScore,
                             awayScore: event.awayTeamScore,
                             matchTime: event.matchTime,
                             status: mappeddStatus,
                             detailedScores: mappedScores,
                             activePlayerServing: mappedActivePlayerServe)
    }
    
    static func matchLiveData(fromServiceProviderEventLiveData eventLiveData: ServicesProvider.EventLiveData) -> MatchLiveData {
        let mappeddStatus = Self.matchStatus(fromInternalEvent: eventLiveData.status)
        
        let mappedScores = Self.scoresDictionary(fromInternalScoresDictionary: eventLiveData.detailedScores ?? [:])
        
        var mappedActivePlayerServe: Match.ActivePlayerServe?
        switch eventLiveData.activePlayerServing {
        case .home:
            mappedActivePlayerServe = .home
        case .away:
            mappedActivePlayerServe = .away
        case .none:
            mappedActivePlayerServe = nil
        }

        return MatchLiveData(id: eventLiveData.id,
                             homeScore: eventLiveData.homeScore,
                             awayScore: eventLiveData.awayScore,
                             matchTime: eventLiveData.matchTime,
                             status: mappeddStatus,
                             detailedScores: mappedScores,
                             activePlayerServing: mappedActivePlayerServe)
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
        
        let sport: Sport?
        if let marketSport = market.sport {
            sport = Self.sport(fromServiceProviderSportType: marketSport)
        }
        else {
            sport = nil
        }
        
        let venueCountry: Country?
        if let marketVenueCountry = market.venueCountry {
            venueCountry = Self.country(fromServiceProviderCountry: marketVenueCountry)
        }
        else {
            venueCountry = nil
        }
        
        return Market(id: market.id,
                      typeId: market.name,
                      name: market.name,
                      isMainMarket: market.isMainMarket,
                      nameDigit1: Double(market.marketDigitLine ?? ""),
                      nameDigit2: nil,
                      nameDigit3: nil,
                      eventPartId: nil,
                      bettingTypeId: market.eventMarketTypeId,
                      outcomes: mappedOutcomes,
                      marketTypeId: market.marketTypeId,
                      marketTypeName: market.marketTypeName,
                      eventName: market.eventName,
                      isMainOutright: market.isMainOutright,
                      eventMarketCount: market.eventMarketCount,
                      isAvailable: market.isTradable,
                      startDate: market.startDate,
                      homeParticipant: market.homeParticipant,
                      awayParticipant: market.awayParticipant,
                      eventId: market.eventId,
                      outcomesOrder: outcomesOrder,
                      customBetAvailable: market.customBetAvailable,
                      competitionName: market.competitionName,
                      sport: sport,
                      sportIdCode: market.sportIdCode,
                      venueCountry: venueCountry)
    }
    
    static func optionalMarkets(fromServiceProviderMarkets markets: [ServicesProvider.Market]?) -> [Market]? {
        if let markets = markets {
            return markets.map(Self.market(fromServiceProviderMarket:))
        }
        return nil
    }
    
    static func market(fromServiceProviderBetSelection betSelection: BetSelection) -> Market {
        
        let oddFormat = Self.oddFormat(fromServiceProviderOddFormat: betSelection.odd)
        let bettingOffer = BettingOffer(id: betSelection.outcomeId ?? "", odd: oddFormat, statusId: "", isLive: false, isAvailable: true)
        
        let outcome = Outcome(id: betSelection.outcomeId ?? "",
                              codeName: betSelection.outcomeName,
                              typeName: betSelection.outcomeName,
                              translatedName: betSelection.outcomeName,
                              bettingOffer: bettingOffer)
        
        return Market(id: betSelection.marketId ?? "",
                      typeId: "",
                      name: betSelection.marketName,
                      nameDigit1: nil,
                      nameDigit2: nil,
                      nameDigit3: nil,
                      eventPartId: nil,
                      bettingTypeId: nil,
                      outcomes: [outcome],
                      homeParticipant: betSelection.homeTeamName,
                      awayParticipant: betSelection.awayTeamName,
                      eventId: betSelection.eventId, outcomesOrder: .none)
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
                                    externalReference: outcome.externalReference,
                                    customBetAvailableMarket: outcome.customBetAvailableMarket,
                                    isTerminated: outcome.isTerminated)
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
            
            var country: Country?
            if let serviceProviderCountry = sportRegion.country {
                country = Self.country(fromServiceProviderCountry: serviceProviderCountry)
            }
            
            if let regionCompetitions = regionCompetitions[sportRegion.id] {
                let competitionGroup = CompetitionGroup(id: sportRegion.id,
                                                        name: sportRegion.name ?? "",
                                                        aggregationType: .region,
                                                        competitions: self.competitions(fromSportCompetitions: regionCompetitions),
                                                        country: country)
                return competitionGroup
            }
            else {
                let competitionGroup = CompetitionGroup(id: sportRegion.id,
                                                        name: sportRegion.name ?? "",
                                                        aggregationType: .region,
                                                        competitions: [],
                                                        country: country)
                return competitionGroup
            }
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
    
    // Tournament
    static func competition(fromTournament tournament: ServicesProvider.Tournament) -> Competition {
        let sport = Sport(id: tournament.id,
                          name: tournament.sportName ?? "",
                          alphaId: tournament.sportId,
                          numericId: tournament.shortSportName,
                          showEventCategory: false,
                          liveEventsCount: tournament.numberOfLiveEvents ?? 0,
                          outrightEventsCount: 0,
                          eventsCount: tournament.numberOfEvents ?? 0
        )
        
        let location = Location(
            id: tournament.venueId ?? "",
            name: tournament.venueName ?? "",
            isoCode: tournament.shortVenueName ?? ""
        )
        
        return Competition(
            id: tournament.id,
            name: tournament.name ?? "",
            venue: location,
            sport: sport,
            numberOutrightMarkets: tournament.numberOfOutrightMarkets ?? 0,
            outrightMarkets: [],
            numberEvents: tournament.numberOfEvents + tournament.numberOfLiveEvents
        )
    }

    static func competitions(fromTournaments tournaments: [ServicesProvider.Tournament]) -> [Competition] {
        return tournaments.map(Self.competition(fromTournament:))
    }

    static func tournament(fromTournament tournament: ServicesProvider.Tournament) -> Tournament {
        // This creates a copy of the tournament with the same data
        return Tournament(
            type: tournament.type,
            id: tournament.id,
            idAsString: tournament.idAsString,
            typeId: tournament.typeId,
            name: tournament.name,
            shortName: tournament.shortName,
            numberOfEvents: tournament.numberOfEvents,
            numberOfMarkets: tournament.numberOfMarkets,
            numberOfBettingOffers: tournament.numberOfBettingOffers,
            numberOfLiveEvents: tournament.numberOfLiveEvents,
            numberOfLiveMarkets: tournament.numberOfLiveMarkets,
            numberOfLiveBettingOffers: tournament.numberOfLiveBettingOffers,
            numberOfOutrightMarkets: tournament.numberOfOutrightMarkets,
            numberOfUpcomingMatches: tournament.numberOfUpcomingMatches,
            sportId: tournament.sportId,
            sportName: tournament.sportName,
            shortSportName: tournament.shortSportName,
            venueId: tournament.venueId,
            venueName: tournament.venueName,
            shortVenueName: tournament.shortVenueName,
            categoryId: tournament.categoryId,
            templateId: tournament.templateId,
            templateName: tournament.templateName,
            rootPartId: tournament.rootPartId,
            rootPartName: tournament.rootPartName,
            shortRootPartName: tournament.shortRootPartName
        )
    }

    static func tournaments(fromTournaments tournaments: [ServicesProvider.Tournament]) -> [Tournament] {
        return tournaments.map(Self.tournament(fromTournament:))
    }
    
    static func suggestedBetslips(fromPromotedBetslips promotedBetslips: [PromotedBetslip]) -> [SuggestedBetslip] {
        return promotedBetslips.map(Self.suggestedBetslip(fromPromotedBetslip:))
    }
    
    static func suggestedBetslip(fromPromotedBetslip promotedBetslip: PromotedBetslip) -> SuggestedBetslip {
        var suggestedSelections = promotedBetslip.selections.map(suggestedBetslipSelection)
        return SuggestedBetslip(selections: suggestedSelections)
    }
    
    static func suggestedBetslipSelection(fromPromotedBetslipSelection promotedSelection: PromotedBetslipSelection) -> SuggestedBetslipSelection {
        
        var participants: [Participant] = []
        for participantIndex in promotedSelection.participants.indices {
            if let participantName = promotedSelection.participants[safe: participantIndex],
               let participantId = promotedSelection.participantIds[safe: participantIndex] {
                participants.append(Participant(id: participantId, name: participantName))
            }
        }
        
        var mappedSport: Sport?
        if let sport = promotedSelection.sport {
            mappedSport = Self.sport(fromServiceProviderSportType: sport)
        }
        
        var venue: Location?
        if let venueCountry = promotedSelection.country {
            venue = Location(id: venueCountry.iso2Code, name: venueCountry.name, isoCode: venueCountry.iso2Code)
        }
        
        let suggestedBetslipSelection = SuggestedBetslipSelection(id: promotedSelection.id,
                                         location: venue,
                                         competitionName: promotedSelection.competitionName,
                                         participants: participants,
                                         sport: mappedSport,
                                         odd: promotedSelection.odd,
                                         eventId: promotedSelection.eventId,
                                         marketId: promotedSelection.marketId,
                                         outcomeId: promotedSelection.outcomeId,
                                         eventName: promotedSelection.eventName,
                                         marketName: promotedSelection.marketName,
                                         outcomeName: promotedSelection.outcomeName ?? "")
        
        return suggestedBetslipSelection
    }

}
