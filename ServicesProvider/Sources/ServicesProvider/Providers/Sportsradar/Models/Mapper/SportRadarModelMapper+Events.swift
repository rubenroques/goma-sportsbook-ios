//
//  SportRadarError.swift
//
//
//  Created by Ruben Roques on 10/10/2022.
//

import Foundation

extension SportRadarModelMapper {

    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {
        let events = internalEvents.map({ event -> Event in
            let country: Country? = Country.country(withName: event.tournamentCountryName ?? "")

            if let eventMarkets = event.markets {
                let markets = eventMarkets.map(Self.market(fromInternalMarket:))
                return Event(id: event.id,
                             homeTeamName: event.homeName ?? "",
                             awayTeamName: event.awayName ?? "",
                             sportTypeName: event.sportTypeName ?? "",
                             competitionId: event.competitionId ?? "",
                             competitionName: event.competitionName ?? "",
                             startDate: event.startDate ?? Date(),
                             markets: markets, venueCountry: country)
            }
            else {
                return Event(id: event.id,
                             homeTeamName: event.homeName ?? "",
                             awayTeamName: event.awayName ?? "",
                             sportTypeName: event.sportTypeName ?? "",
                             competitionId: event.competitionId ?? "",
                             competitionName: event.competitionName ?? "",
                             startDate: event.startDate ?? Date(),
                             markets: [])
            }
        })

        let filterEvents = events.filter({
            !$0.markets.isEmpty
        })

        return EventsGroup(events: filterEvents)
    }

    static func market(fromInternalMarket internalMarket: SportRadarModels.Market) -> Market {
        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))
        return Market(id: internalMarket.id, name: internalMarket.name, outcomes: outcomes, marketTypeId: internalMarket.marketTypeId, eventMarketTypeId: internalMarket.eventMarketTypeId, eventName: internalMarket.eventName)
    }

    static func outcome(fromInternalOutcome internalOutcome: SportRadarModels.Outcome) -> Outcome {
        return Outcome(id: internalOutcome.id, name: internalOutcome.name, odd: internalOutcome.odd, marketId: internalOutcome.marketId, orderValue: internalOutcome.orderValue, externalReference: internalOutcome.externalReference)
    }
    
}
