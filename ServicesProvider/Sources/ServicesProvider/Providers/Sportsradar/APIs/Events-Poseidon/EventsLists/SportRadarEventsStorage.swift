//
//  SportRadarEventsStorage.swift
//  
//
//  Created by Ruben Roques on 23/11/2022.
//

import Foundation
import OrderedCollections
import Combine

class SportRadarEventsStorage {

    var eventsPublisher: AnyPublisher<[Event]?, Never> {
        return self.eventsSubject.eraseToAnyPublisher()
    }

    private var eventsSubject: CurrentValueSubject<[Event]?, Never> = .init(nil)

    private var eventsDictionary: OrderedDictionary<String, CurrentValueSubject<Event, Never>>
    private var marketsDictionary: OrderedDictionary<String, CurrentValueSubject<Market, Never>>
    private var outcomesDictionary: OrderedDictionary<String, CurrentValueSubject<Outcome, Never>>

    init() {
        self.eventsSubject.send(nil)

        self.eventsDictionary = [:]
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]
    }

    func reset() {
        self.eventsSubject.send(nil)

        self.eventsDictionary = [:]
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]
    }

    func storeEvents(_ events: [Event]) {

        for event in events {
            for market in event.markets {
                for outcome in market.outcomes {
                    outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
                }
                marketsDictionary[market.id] = CurrentValueSubject(market)
            }
            eventsDictionary[event.id] = CurrentValueSubject(event)
        }

        // Avoid duplication, we just just a values of the dictionary
        let subjectValues = self.eventsDictionary.values
        let orderedEvents = Array(subjectValues).map(\.value)
        self.eventsSubject.send(orderedEvents)
    }

}

extension SportRadarEventsStorage {

    func addEvent(withEvent updatedEvent: Event) {

        if let storedEvent = self.eventsDictionary[updatedEvent.id]?.value {
            for market in storedEvent.markets {
                self.updateMarketTradability(withId: market.id, isTradable: market.isTradable)
            }
        }
        else {
            self.storeEvents([updatedEvent])
        }

    }

    func removedEvent(withId id: String) {
        guard let eventSubject = self.eventsDictionary[id] else { return }
        let event = eventSubject.value

        for market in event.markets {
            self.updateMarketTradability(withId: market.id, isTradable: false)
        }

        let newEventsList = (self.eventsSubject.value ?? []).filter({ event in
            return event.id != id
        })

        self.eventsSubject.send(newEventsList)
    }

    func updateOutcomeOdd(withId id: String, newOddNumerator: String?, newOddDenominator: String?) {
        guard let outcomeSubject = self.outcomesDictionary[id] else { return }
        let outcome = outcomeSubject.value

        var oldNumerator: Int = 1
        var oldDenominator: Int = 1

        if case let .fraction(numerator, denominator) = outcome.odd {
            oldNumerator = numerator
            oldDenominator = denominator
        }

        let newOddNumeratorValue = Int(newOddNumerator ?? "x") ?? oldNumerator
        let newOddDenominatorValue = Int(newOddDenominator ?? "x") ?? oldDenominator

        if newOddNumeratorValue == oldNumerator && newOddDenominatorValue == oldDenominator {
            return
        }

        outcome.odd = OddFormat.fraction(numerator: newOddNumeratorValue, denominator: newOddDenominatorValue)
        outcomeSubject.send(outcome)
    }

    func updateOutcomeTradability(withId id: String, isTradable: Bool) {
        guard let outcomeSubject = self.outcomesDictionary[id] else { return }
        let outcome = outcomeSubject.value
        outcome.isTradable = isTradable
        outcomeSubject.send(outcome)
    }
    
    func updateMarketTradability(withId id: String, isTradable: Bool) {
        guard
            let marketSubject = self.marketsDictionary[id]
        else {
            // print("PaginatorStorage updateMarketTradability \(id) not found to isTradable:\(isTradable)")
            return
        }
        let market = marketSubject.value

        // print("PaginatorStorage updateMarketTradability \(id) isTradable:\(isTradable)")
        market.isTradable = isTradable
        marketSubject.send(market)
    }

    func updateEventStatus(withId id: String, newStatus: String) {
        guard let eventSubject = self.eventsDictionary[id] else { return }
        let event = eventSubject.value

        event.status = EventStatus(value: newStatus)

        eventSubject.send(event)
    }

    func updateEventTime(withId id: String, newTime: String) {
        guard let eventSubject = self.eventsDictionary[id] else { return }
        let event = eventSubject.value

        event.matchTime = newTime

        eventSubject.send(event)
    }

    func updateEventScore(withId id: String, newHomeScore: Int?, newAwayScore: Int?) {
        guard let eventSubject = self.eventsDictionary[id] else { return }
        let event = eventSubject.value

        event.homeTeamScore = newHomeScore
        event.awayTeamScore = newAwayScore

        eventSubject.send(event)
    }
    
    func updateEventDetailedScore(withId id: String, detailedScore: Score) {
        guard let eventSubject = self.eventsDictionary[id] else { return }
        let event = eventSubject.value
        event.scores[detailedScore.key] = detailedScore
        
        if case .matchFull(let newHomeScore, let newAwayScore) = detailedScore {
            if let newHomeScoreValue = newHomeScore {
                event.homeTeamScore = newHomeScoreValue
            }
            if let newAwayScoreValue = newAwayScore {
                event.awayTeamScore = newAwayScoreValue
            }
        }
        
        eventSubject.send(event)
    }
    
    func updateActivePlayer(withId id: String, activePlayerServing: ActivePlayerServe?) {
        guard let eventSubject = self.eventsDictionary[id] else { return }
        let event = eventSubject.value
        
        event.activePlayerServing = activePlayerServing
        eventSubject.send(event)
    }
    
}

extension SportRadarEventsStorage {

    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event, Never>? {
        return self.eventsDictionary[id]?.eraseToAnyPublisher()
    }

    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market, Never>? {
        return self.marketsDictionary[id]?.eraseToAnyPublisher()
    }

    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome, Never>? {
        return self.outcomesDictionary[id]?.eraseToAnyPublisher()
    }

    func containsEvent(withid id: String) -> Bool {
        return self.eventsDictionary[id] != nil
    }

    func containsMarket(withid id: String) -> Bool {
        return self.marketsDictionary[id] != nil
    }

    func containsOutcome(withid id: String) -> Bool {
        return self.outcomesDictionary[id] != nil
    }

}

