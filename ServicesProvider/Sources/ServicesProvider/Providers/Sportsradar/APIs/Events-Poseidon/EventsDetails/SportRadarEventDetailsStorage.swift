//
//  File.swift
//  
//
//  Created by Ruben Roques on 01/03/2023.
//

import Foundation
import OrderedCollections
import Combine

class SportRadarEventDetailsStorage {

    private var eventSubject: CurrentValueSubject<Event?, Never>
    private var marketsDictionary: OrderedDictionary<String, CurrentValueSubject<Market, Never>>
    private var outcomesDictionary: OrderedDictionary<String, CurrentValueSubject<Outcome, Never>>

    init() {
        self.eventSubject = .init(nil)
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]
    }

    func reset() {
        self.eventSubject.send(nil)
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]
    }

    func storeEvent(_ event: Event) {
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]

        for market in event.markets {
            for outcome in market.outcomes {
                outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
            }
            marketsDictionary[market.id] = CurrentValueSubject(market)
        }
        self.eventSubject.send(event)
    }

    func storedEvent() -> Event? {
        return self.eventSubject.value
    }

}

extension SportRadarEventDetailsStorage {

    func removedEvent(withId id: String) {
        guard let event = self.eventSubject.value else { return }

        for market in event.markets {
            self.updateMarketTradability(withId: market.id, isTradable: false)
        }
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

    func updateMarketTradability(withId id: String, isTradable: Bool) {
        guard let marketSubject = self.marketsDictionary[id] else { return }
        let market = marketSubject.value
        market.isTradable = isTradable
        marketSubject.send(market)
    }

    func updateEventStatus(newStatus: String) {
        guard let event = self.eventSubject.value else { return }
        event.status = Event.Status(value: newStatus)
        eventSubject.send(event)
    }

    func updateEventTime(newTime: String) {
        guard let event = self.eventSubject.value else { return }
        event.matchTime = newTime
        eventSubject.send(event)
    }

    func updateEventScore(newHomeScore: Int?, newAwayScore: Int?) {
        guard let event = self.eventSubject.value else { return }
        event.homeTeamScore = newHomeScore
        event.awayTeamScore = newAwayScore
        eventSubject.send(event)
    }

}

extension SportRadarEventDetailsStorage {

    func subscribeToEventUpdates(withId id: String) -> AnyPublisher<Event?, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }

    func subscribeToEventMarketUpdates(withId id: String) -> AnyPublisher<Market, Never>? {
        return self.marketsDictionary[id]?.eraseToAnyPublisher()
    }

    func subscribeToEventOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome, Never>? {
        return self.outcomesDictionary[id]?.eraseToAnyPublisher()
    }

    func containsEvent(withid id: String) -> Bool {
        return self.eventSubject.value?.id == id
    }

    func containsMarket(withid id: String) -> Bool {
        return self.marketsDictionary[id] != nil
    }

    func containsOutcome(withid id: String) -> Bool {
        return self.outcomesDictionary[id] != nil
    }

}

