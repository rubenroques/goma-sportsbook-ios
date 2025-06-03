//
//  EveryMatrixModelMapper+Events.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 22/04/2025.
//

import Foundation
import SharedModels

extension EveryMatrixModelMapper {

    static func eventsGroup(fromInternalMatches internalMatches: [EveryMatrix.Match]) -> EventsGroup {
        let events = internalMatches.map(Self.event(fromInternalMatch:))
        return EventsGroup(events: events, marketGroupId: nil)
    }

    static func event(fromInternalMatch internalMatch: EveryMatrix.Match) -> Event {
        // Convert EveryMatrix.Sport to external SportType
        var mappedSport: SportType
        if let sport = internalMatch.sport {
            mappedSport = Self.sportType(fromInternalSport: sport)
        }
        else {
            mappedSport = SportType(name: "FBL")
        }

        // Convert EveryMatrix.Location to external Country
        var country: Country?
        if let venue = internalMatch.venue {
            country = Country.country(withName: venue.name)
        }

        // Convert EveryMatrix.Market array to external Market array
        let markets = internalMatch.markets.map(Self.market(fromInternalMarket:))

        // Convert match status
        let eventStatus = Self.eventStatus(fromInternalMatchStatus: internalMatch.status)

        return Event(
            id: internalMatch.id,
            homeTeamName: internalMatch.homeParticipant?.name ?? "",
            awayTeamName: internalMatch.awayParticipant?.name ?? "",
            homeTeamScore: nil, // EveryMatrix doesn't provide scores in match data
            awayTeamScore: nil,
            homeTeamLogoUrl: nil,
            awayTeamLogoUrl: nil,
            competitionId: internalMatch.category?.id ?? "",
            competitionName: internalMatch.category?.name ?? "",
            sport: mappedSport,
            sportIdCode: internalMatch.sport?.id,
            startDate: internalMatch.startTime,
            markets: markets,
            venueCountry: country,
            numberMarkets: internalMatch.numberOfMarkets,
            name: internalMatch.name,
            trackableReference: nil,
            status: eventStatus,
            matchTime: nil,
            activePlayerServing: nil,
            boostedMarket: nil,
            promoImageURL: nil,
            scores: [:]
        )
    }

    static func sportType(fromInternalSport internalSport: EveryMatrix.Sport) -> SportType {
        return SportType(
            name: internalSport.name,
            numericId: internalSport.id,
            alphaId: internalSport.id,
            iconId: internalSport.id,
            showEventCategory: internalSport.showEventCategory ?? false,
            numberEvents: internalSport.numberOfEvents ?? 0,
            numberOutrightEvents: 0, // Not available in EveryMatrix data
            numberOutrightMarkets: 0, // Not available in EveryMatrix data
            numberLiveEvents: internalSport.numberOfLiveEvents ?? 0
        )
    }

    static func market(fromInternalMarket internalMarket: EveryMatrix.Market) -> Market {
        // Convert EveryMatrix.Outcome array to external Outcome array
        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))

        // Map betting type information
        let marketTypeId = internalMarket.bettingType?.id ?? ""
        let marketTypeName = internalMarket.bettingType?.name ?? ""

        return Market(
            id: internalMarket.id,
            name: internalMarket.name,
            outcomes: outcomes,
            marketTypeId: marketTypeId,
            marketTypeName: marketTypeName,
            marketFilterId: nil, // Not available in EveryMatrix
            eventMarketTypeId: nil, // Not available in EveryMatrix
            eventName: nil, // Not available at market level
            isMainOutright: false, // Not available in EveryMatrix
            eventMarketCount: nil, // Not available in EveryMatrix
            isTradable: internalMarket.isAvailable ?? true,
            startDate: nil, // Not available at market level
            homeParticipant: nil, // Not available at market level
            awayParticipant: nil, // Not available at market level
            eventId: nil, // Not available at market level
            marketDigitLine: (internalMarket.paramFloat1 != nil) ? "\(internalMarket.paramFloat1!)" : nil,
            outcomesOrder: .none, // Not specified in EveryMatrix
            competitionId: nil, // Not available at market level
            competitionName: nil, // Not available at market level
            sport: nil, // Not available at market level
            sportIdCode: nil, // Not available at market level
            venueCountry: nil, // Not available at market level
            customBetAvailable: false, // Not available in EveryMatrix
            isMainMarket: internalMarket.isMainLine ?? false
        )
    }

    static func outcome(fromInternalOutcome internalOutcome: EveryMatrix.Outcome) -> Outcome {
        // Get the best available betting offer (highest odds or most recent)
        let bestOffer = internalOutcome.bettingOffers.first { $0.isAvailable }
        let odds = bestOffer?.odds ?? 0.0
        let isTradable = bestOffer?.isAvailable ?? false

        return Outcome(
            id: internalOutcome.id,
            name: internalOutcome.name,
            odd: OddFormat.decimal(odd: odds),
            marketId: nil, // Not available at outcome level
            orderValue: nil, // Not available in EveryMatrix
            externalReference: nil, // Not available in EveryMatrix
            isTradable: isTradable,
            isTerminated: !isTradable,
            customBetAvailableMarket: false // Not available in EveryMatrix
        )
    }

    static func eventStatus(fromInternalMatchStatus internalStatus: EveryMatrix.Match.MatchStatus) -> EventStatus? {
        // Map EveryMatrix match status to external EventStatus
        // This is a basic mapping - you may need to refine based on actual status values
        switch internalStatus.name.lowercased() {
        case "pending", "not started":
            return .notStarted
        case "live", "in progress", "started":
            return .inProgress(internalStatus.name)
        case "finished", "ended", "completed":
            return .ended(internalStatus.name)
        default:
            return .inProgress(internalStatus.name)
        }
    }
}

// MARK: - Convenience Extensions
extension EveryMatrixModelMapper {

    /// Convert a single match to an EventsGroup
    static func eventsGroup(fromInternalMatch internalMatch: EveryMatrix.Match) -> EventsGroup {
        return eventsGroup(fromInternalMatches: [internalMatch])
    }

    /// Filter and convert matches by sport
    static func eventsGroup(fromInternalMatches internalMatches: [EveryMatrix.Match], sportId: String) -> EventsGroup {
        let filteredMatches = internalMatches.filter { match in
            match.sport?.id == sportId
        }
        return eventsGroup(fromInternalMatches: filteredMatches)
    }

    /// Convert matches with grouping by competition/category
    static func eventsGroups(fromInternalMatches internalMatches: [EveryMatrix.Match], groupByCategory: Bool = false) -> [EventsGroup] {
        if groupByCategory {
            // Group matches by category
            let groupedMatches = Dictionary(grouping: internalMatches) { match in
                match.category?.id ?? "unknown"
            }

            return groupedMatches.map { (categoryId, matches) in
                let events = matches.map(Self.event(fromInternalMatch:))
                return EventsGroup(events: events, marketGroupId: categoryId, title: matches.first?.category?.name)
            }
        } else {
            // Return all matches in a single group
            return [eventsGroup(fromInternalMatches: internalMatches)]
        }
    }
}
