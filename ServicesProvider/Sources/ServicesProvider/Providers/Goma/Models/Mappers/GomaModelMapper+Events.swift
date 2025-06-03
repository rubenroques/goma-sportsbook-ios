//
//  File.swift
//
//
//  Created by Ruben Roques on 21/12/2023.
//

import Foundation
import SharedModels

extension GomaModelMapper {

    static func eventsGroup(fromInternalEvents internalEvents: [GomaModels.Event]) -> EventsGroup {
        let events = internalEvents.map(Self.event(fromInternalEvent:))
        return EventsGroup(events: events, marketGroupId: nil, title: nil)
    }

    static func events(fromInternalEvents internalEvents: [GomaModels.Event]) -> Events {
        return internalEvents.map(Self.event(fromInternalEvent:))
    }

    static func event(fromInternalEvent internalEvent: GomaModels.Event) -> Event {

        var country: Country?
        if let regionIsoCode = internalEvent.region.isoCode {
            country = Country.country(withISOCode: regionIsoCode)
        }
        else {
            country = Country.country(withName: internalEvent.region.name)
        }

        //
        var eventName: String?
        if !internalEvent.homeName.isEmpty, !internalEvent.awayName.isEmpty {
            eventName = "\(internalEvent.homeName) x \(internalEvent.awayName)"
        }
        else {
            eventName = internalEvent.competition.name
        }

        let hasLiveOdds = internalEvent.isLive

        //
//        let mappedMarkets = internalEvent.markets.map(Self.market(fromInternalMarket:))

        let mappedMarkets = internalEvent.markets.map({
            Self.market(fromInternalMarket: $0, withLiveOdds: hasLiveOdds)
        })

        mappedMarkets.forEach { market in
            market.homeParticipant = internalEvent.homeName
            market.awayParticipant = internalEvent.awayName
            market.eventId = internalEvent.identifier
            market.eventName = eventName
        }

        let sportType = Self.sportType(fromSport: internalEvent.sport)

        let event = Event(id: internalEvent.identifier,
                          homeTeamName: internalEvent.homeName,
                          awayTeamName: internalEvent.awayName,
                          homeTeamScore: internalEvent.homeScore,
                          awayTeamScore: internalEvent.awayScore,
                          homeTeamLogoUrl: internalEvent.homeLogoUrl,
                          awayTeamLogoUrl: internalEvent.awayLogoUrl,
                          competitionId: internalEvent.competition.identifier,
                          competitionName: internalEvent.competition.name,
                          sport: sportType,
                          sportIdCode: sportType.numericId,
                          startDate: internalEvent.startDate,
                          markets: mappedMarkets,
                          venueCountry: country,
                          numberMarkets: mappedMarkets.count,
                          name: eventName,
                          trackableReference: nil,
                          status: Self.eventStatus(fromInternalEvent: internalEvent.status),
                          matchTime: internalEvent.matchTime,
                          activePlayerServing: nil,
                          boostedMarket: nil,
                          promoImageURL: internalEvent.imageUrl ?? internalEvent.metaDetails?.imageUrl,
                          scores: internalEvent.scores)

        return event
    }

    static func eventStatus(fromInternalEvent internalEventStatus: GomaModels.EventStatus) -> EventStatus? {
        switch internalEventStatus {
        case .unknown:
            return nil
        case .notStarted:
            return EventStatus.notStarted
        case .inProgress(let detail):
            return EventStatus.inProgress(detail)
        case .ended(let detail):
            return EventStatus.ended(detail ?? "")
        }
    }

    static func market(fromInternalMarket internalMarket: GomaModels.Market, withLiveOdds: Bool = false) -> Market {
        var mappedStats: Stats?
        if let stats = internalMarket.stats {
            mappedStats = Self.stats(fromInternalStats: stats)
        }

//        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))

        let outcomes = internalMarket.outcomes.map({
            Self.outcome(fromInternalOutcome: $0, withLiveOdds: withLiveOdds)
        })

        return Market(id: internalMarket.identifier,
                      name: internalMarket.name,
                      outcomes: outcomes,
                      marketTypeId: internalMarket.groupId,
                      marketTypeName: internalMarket.groupId,
                      marketFilterId: internalMarket.groupId,
                      eventMarketTypeId: internalMarket.groupId,
                      eventName: nil,
                      isMainOutright: false,
                      eventMarketCount: nil,
                      isTradable: true,
                      startDate: nil,
                      homeParticipant: nil,
                      awayParticipant: nil,
                      eventId: nil,
                      marketDigitLine: nil,
                      outcomesOrder: .none,
                      competitionId: nil,
                      competitionName: nil,
                      sport: nil,
                      sportIdCode: nil,
                      venueCountry: nil,
                      customBetAvailable: nil,
                      isMainMarket: false,
                      stats: mappedStats)
    }

    static func outcome(fromInternalOutcome internalOutcome: GomaModels.Outcome, withLiveOdds: Bool = false) -> Outcome {

        var odd = internalOutcome.odd

        if withLiveOdds {
            odd = internalOutcome.oddLive ?? odd
        }

        return Outcome(id: internalOutcome.identifier,
                       name: internalOutcome.name,
                       odd: odd,
                       marketId: internalOutcome.identifier,
                       bettingOfferId: internalOutcome.identifier,
                       orderValue: internalOutcome.code,
                       externalReference: nil,
                       isTradable: true,
                       isTerminated: false,
                       customBetAvailableMarket: nil)
    }

}

extension GomaModelMapper {
    // Extra events generator
    
    // Carousel
    static func events(fromInternalCarouselEvents internalCarouselEvents: GomaModels.CarouselEvents) -> Events {
        let events = internalCarouselEvents.map(Self.event(fromInternalCarouselEvent:))
        return events
    }
    
    static func event(fromInternalCarouselEvent internalCarouselEvent: GomaModels.CarouselEvent) -> Event {
        var imageEvent = internalCarouselEvent.event
        imageEvent.imageUrl = internalCarouselEvent.imageUrl
        return Self.event(fromInternalEvent: imageEvent)
    }
    
    
    // Hero
    static func events(fromInternalHeroCardEvents internalHeroCardEvents: GomaModels.HeroCardEvents) -> Events {
        let events = internalHeroCardEvents.map(Self.event(fromInternalHeroCardEvent:))
        return events
    }
    
    static func event(fromInternalHeroCardEvent heroCardEvent: GomaModels.HeroCardEvent) -> Event {
        let mappedEvent = Self.event(fromInternalEvent: heroCardEvent.event)
        mappedEvent.promoImageURL = heroCardEvent.imageUrl
        return mappedEvent
    }
    
    // Boosted
    static func events(fromInternalBoostedOddsEvents internalBoostedOddsEvents: GomaModels.BoostedOddsEvents) -> Events {
        let events = internalBoostedOddsEvents.map(Self.event(fromInternalBoostedOddsEvent:))
        return events
    }
 
    static func event(fromInternalBoostedOddsEvent boostedEvent: GomaModels.BoostedOddsEvent) -> Event {
        let mappedEvent = Self.event(fromInternalEvent: boostedEvent.event)
        let mappedBoostedMarket = Self.market(fromInternalMarket: boostedEvent.boostedOddMarket)
        mappedEvent.promoImageURL = boostedEvent.imageUrl
        mappedEvent.boostedMarket = mappedBoostedMarket
        mappedEvent.oldMainMarketId = boostedEvent.event.markets.first?.identifier
        return mappedEvent
    }
    
    
}

extension GomaModelMapper {

    static func topCompetitions(fromCompetitions competitions: [GomaModels.Competition]) -> [TopCompetition] {
        return competitions.map(Self.topCompetition(fromCompetition:)).compactMap({ $0 })
    }

    static func topCompetition(fromCompetition competition: GomaModels.Competition) -> TopCompetition? {

        guard
            let sport = competition.sport
        else {
            return nil
        }

        let convertedSport = Self.sportType(fromSport: sport)

        var convertedCountry: Country?
        if let regionIsoCode = competition.region?.isoCode {
            convertedCountry = Country.country(withISOCode: regionIsoCode)
        }
        else {
            convertedCountry = Country.country(withName: competition.region?.name ?? "")
        }

        return TopCompetition(id: competition.identifier,
                              name: competition.name,
                              country: convertedCountry,
                              sportType: convertedSport)

    }

    static func topCompetitionsPointers(fromCompetitions competitions: [GomaModels.Competition]) -> [TopCompetitionPointer] {
        return competitions.map(Self.topCompetitionPointer(fromCompetition:)).compactMap({ $0 })
    }

    static func topCompetitionPointer(fromCompetition competition: GomaModels.Competition) -> TopCompetitionPointer? {
        guard
            let sport = competition.sport
        else {
            return nil
        }

        return TopCompetitionPointer(id: sport.name, name: competition.name, competitionId: competition.identifier)
    }

    static func eventMetadataPointer(fromInternalEventMetadataPointer eventMetadataPointer: GomaModels.EventMetadataPointer) -> EventMetadataPointer {

        return EventMetadataPointer(id: eventMetadataPointer.id,
                                    eventId: eventMetadataPointer.eventId,
                                    eventMarketId: eventMetadataPointer.eventMarketId,
                                    callToActionURL: eventMetadataPointer.callToActionURL,
                                    imageURL: eventMetadataPointer.imageURL)
    }

}


extension GomaModelMapper {

    static func sportRegions(fromRegions regions: [GomaModels.Region]) -> [SportRegion] {
        return regions.map(Self.sportRegion(fromRegion:))
    }

    static func sportRegion(fromRegion region: GomaModels.Region) -> SportRegion {

        var convertedCountry: Country? = Country.country(withName: region.name)
        if let regionIsoCode = region.isoCode {
            convertedCountry = Country.country(withISOCode: regionIsoCode)
        }
        else {
            convertedCountry = Country.country(withName: region.name)
        }

        return SportRegion(id: region.identifier,
                           name: region.name,
                           numberEvents: "\(region.preLiveEventsCount ?? 0)",
                           numberOutrightEvents: "0",
                           country: convertedCountry)
    }

    static func sportCompetitions(fromCompetitions competitions: [GomaModels.Competition]) -> [SportCompetition] {
        return competitions.map(Self.sportCompetition(fromCompetition:))
    }

    static func sportCompetition(fromCompetition competition: GomaModels.Competition) -> SportCompetition {
        return SportCompetition(id: competition.identifier,
                                name: competition.name,
                                numberEvents: "\(competition.preLiveEventsCount ?? 0)",
                                numberOutrightEvents: "0")
    }

}

// Stats
extension GomaModelMapper {
    
    static func stats(fromInternalStats internalStats: GomaModels.Stats) -> Stats {
        return Stats(homeParticipant: Self.participantStats(fromInternalParticipantStats: internalStats.homeParticipant),
                     awayParticipant: Self.participantStats(fromInternalParticipantStats: internalStats.awayParticipant))
    }
    
    static func participantStats(fromInternalParticipantStats internalParticipantStats: GomaModels.ParticipantStats)
    -> ParticipantStats {
        return ParticipantStats(total: internalParticipantStats.total,
                                wins: internalParticipantStats.wins,
                                draws: internalParticipantStats.draws,
                                losses: internalParticipantStats.losses,
                                over: internalParticipantStats.over,
                                under: internalParticipantStats.under)
    }
  
}
