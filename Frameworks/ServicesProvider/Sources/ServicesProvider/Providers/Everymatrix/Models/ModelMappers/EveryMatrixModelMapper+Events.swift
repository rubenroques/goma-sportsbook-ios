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
    
    static func mainMarket(fromInternalMainMarket internalMainMarket: EveryMatrix.MainMarketDTO) -> MainMarket {
        return MainMarket(
            id: internalMainMarket.id,
            bettingTypeId: internalMainMarket.bettingTypeId,
            eventPartId: internalMainMarket.eventPartId,
            sportId: internalMainMarket.sportId,
            bettingTypeName: internalMainMarket.bettingTypeName,
            eventPartName: internalMainMarket.eventPartName,
            numberOfOutcomes: internalMainMarket.numberOfOutcomes,
            liveMarket: internalMainMarket.liveMarket,
            outright: internalMainMarket.outright
        )
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

        let homeTeamName = internalMatch.homeParticipant?.name ?? ""
        let awayTeamName = internalMatch.awayParticipant?.name ?? ""

        return Event(
            id: internalMatch.id,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            homeTeamScore: nil, // EveryMatrix doesn't provide scores in match data
            awayTeamScore: nil,
            homeTeamLogoUrl: nil,
            awayTeamLogoUrl: nil,
            competitionId: internalMatch.competitionId ?? "",
            competitionName: internalMatch.competitionName ?? "",
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
            numberLiveEvents: internalSport.numberOfLiveEvents ?? 0,
            hasMatches: internalSport.hasMatches ?? false,
            hasOutrights: internalSport.hasOutrights ?? false
        )
    }

    static func market(fromInternalMarket internalMarket: EveryMatrix.Market) -> Market {
        // Convert EveryMatrix.Outcome array to external Outcome array
        var outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))
        
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
        let completeName = internalOutcome.name != internalOutcome.typeName ? "\(internalOutcome.name) (\(internalOutcome.typeName ?? ""))" : internalOutcome.name
        
        return Outcome(
            id: internalOutcome.id,
            name: internalOutcome.name,
            shortName: internalOutcome.shortName,
            typeName: internalOutcome.typeName,
            odd: OddFormat.decimal(odd: odds),
            marketId: nil, // Not available at outcome level
            bettingOfferId: bestOffer?.id,
            orderValue: internalOutcome.headerNameKey, // position in home/draw/away
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
    
    /// Convert a single match to an EventsGroup with main markets
    static func eventsGroup(fromInternalMatch internalMatch: EveryMatrix.Match, mainMarkets: [MainMarket]? = nil) -> EventsGroup {
        return eventsGroup(fromInternalMatches: [internalMatch], mainMarkets: mainMarkets)
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
    
    /// Convert EventsGroup with provided main markets
    static func eventsGroup(fromInternalMatches internalMatches: [EveryMatrix.Match], mainMarkets: [MainMarket]? = nil) -> EventsGroup {
        let events = internalMatches.map(Self.event(fromInternalMatch:))
        return EventsGroup(events: events, marketGroupId: nil, mainMarkets: mainMarkets)
    }
}

extension EveryMatrixModelMapper {
    
    static func sortValue(forOutcomeHeaderKey key: String, paramFloat1: Double? = nil) -> Int? {
        
        switch key.lowercased() {
        case "yes": return 10
        case "no": return 20
            
        case "oui": return 10
        case "non": return 20
            
        case "home": return 10
        case "draw": return 20
        case "none": return 21
        case "": return 22
        case "away": return 30
            
        case "domicile": return 10
        case "nul": return 20
        case "aucun": return 21
        case "extérieur": return 30
            
        case "home_draw": return 10
        case "home_away": return 20
        case "away_draw": return 30
            
        case "over": return 10
        case "under": return 20
            
        case "plus": return 10
        case "moins": return 20
            
        case "odd": return 10
        case "even": return 20
            
        case "impair": return 10
        case "pair": return 20
            
        case "exact": return 10
        case "range": return 20
        case "more_than": return 30
            
        case "in_90_minutes": return 10
        case "in_extra_time": return 20
        case "on_penalties": return 30
            
        case "home-true": return 10
        case "home-false": return 15
        case "-true": return 20
        case "-false": return 25
        case "away-true": return 30
        case "away-false": return 35
            
        case "home_draw-true": return 10
        case "home_draw-false": return 15
        case "home_away-true": return 20
        case "home_away-false": return 25
        case "away_draw-true": return 30
        case "away_draw-false": return 35
            
        case "over-true": return 10
        case "over-false": return 15
        case "under-true": return 20
        case "under-false": return 25
            
        case "odd-true": return 10
        case "odd-false": return 15
        case "even-true": return 20
        case "even-false": return 25
            
        case "yes-true": return 10
        case "yes-false": return 15
        case "no-true": return 20
        case "no-false": return 25
            
        case "true": return 10
        case "false": return 20
            
        case "vrai": return 10
        case "faux": return 20
            
        case "h": return 10
        case "d": return 20
        case "a": return 30
            
        case "1": return 10
        case "x": return 20
        case "2": return 30
            
        default:
            // If we have a paramFloat1 value, use it for sorting (e.g., "race_to_x" patterns)
            if let paramValue = paramFloat1 {
                // Use paramFloat1 as sort value with base 1000 to ensure it sorts after standard patterns
                return 1000 + Int(paramValue * 10) // e.g., 1.0 -> 1010, 2.0 -> 1020, 3.0 -> 1030
            }
            
            print("SortKey: NOT FOUND (\(key))")
            return nil
        }
    }
}
