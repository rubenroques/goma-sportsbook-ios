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

    private var events: [Event]

    private var eventsDictionary: OrderedDictionary<String, CurrentValueSubject<Event, Never>>
    private var marketsDictionary: OrderedDictionary<String, CurrentValueSubject<Market, Never>>
    private var outcomesDictionary: OrderedDictionary<String, CurrentValueSubject<Outcome, Never>>

    init() {
        self.events = []

        self.eventsDictionary = [:]
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]
    }

    func reset() {
        self.events = []

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

        self.events.append(contentsOf: events)
    }

    func storedEvents() -> [Event] {
        return self.events
    }

}

extension SportRadarEventsStorage {

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

        outcome.odd = OddFormat.fraction(numerator: newOddNumeratorValue, denominator: newOddDenominatorValue)

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

        event.status = Event.Status(value: newStatus)

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
}

extension SportRadarEventsStorage {

    func subscribeToEventUpdates(withId id: String) -> AnyPublisher<Event, Never>? {
        return self.eventsDictionary[id]?.eraseToAnyPublisher()
    }

    func subscribeToEventMarketUpdates(withId id: String) -> AnyPublisher<Market, Never>? {
        return self.marketsDictionary[id]?.eraseToAnyPublisher()
    }

    func subscribeToEventOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome, Never>? {
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

