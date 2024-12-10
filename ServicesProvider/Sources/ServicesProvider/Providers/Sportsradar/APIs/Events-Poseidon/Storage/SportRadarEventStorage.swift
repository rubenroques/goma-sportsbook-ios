//
//  File.swift
//  
//
//  Created by Ruben Roques on 01/03/2023.
//

import Foundation
import OrderedCollections
import Combine

class SportRadarEventStorage {

    var eventPublisher: AnyPublisher<Event?, Never> {
        self.eventSubject
            .eraseToAnyPublisher()
    }

    private var removedMainMarketId: String? = nil

    private var eventSubject: CurrentValueSubject<Event?, Never>
    private var marketsDictionary: OrderedDictionary<String, CurrentValueSubject<Market, Never>>
    private var outcomesDictionary: OrderedDictionary<String, CurrentValueSubject<Outcome, Never>>

    private var cancellables = Set<AnyCancellable>()

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

    func storeEvent(_ event: Event, withMainMarket: Bool = false) {
        self.marketsDictionary = [:]
        self.outcomesDictionary = [:]

        if withMainMarket {
            event.markets.first?.isMainMarket = withMainMarket
        }

        for market in event.markets {
            for outcome in market.outcomes {
                self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
            }
            self.marketsDictionary[market.id] = CurrentValueSubject(market)
        }

        self.eventSubject.send(event)
    }

    func storeSecundaryMarkets(_ secundaryMarkets: [Market]) {
        guard let event = self.eventSubject.value else { return }

        for market in secundaryMarkets {

            // Check if there's an existing market with this ID and if it's marked as main
            if let existingMarket = self.marketsDictionary[market.id]?.value,
               existingMarket.isMainMarket {
                continue // Skip this secondary market
            }

            //
            for outcome in market.outcomes {
                self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
            }
            self.marketsDictionary[market.id] = CurrentValueSubject(market)
        }

        event.markets = self.marketsDictionary.values.map(\.value)
        self.eventSubject.send(event)
    }

    func storedEvent() -> Event? {
        return self.eventSubject.value
    }

}

extension SportRadarEventStorage {

    // Odds updates
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
    
    //
    // Main Market updates
    func addMainMarket(_ market: Market) {
        guard let removedMainMarketId = self.removedMainMarketId else { return }

        market.isMainMarket = true

        // remove old main market
        self.marketsDictionary.removeValue(forKey: removedMainMarketId)

        self.removedMainMarketId = nil
        self.addMarket(market)
    }

    func removeMainMarket(withId id: String) {
        guard
            self.marketsDictionary[id] != nil
        else {
            return
        }

        self.updateMarketTradability(withId: id, isTradable: false)

        self.removedMainMarketId = id
    }

    //
    // Market updates
    func addMarket(_ market: Market) {
        
        if self.marketsDictionary[market.id] != nil { // We already
            self.updateMarketTradability(withId: market.id, isTradable: market.isTradable)
            return
        }
        else {
            for outcome in market.outcomes {
                self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
            }
            
            self.marketsDictionary[market.id] = CurrentValueSubject(market)
            let updatedMarkets: [Market] = self.marketsDictionary.values.map(\.value)
            
            guard let event = self.eventSubject.value else { return }
            event.markets = updatedMarkets
            eventSubject.send(event)
        }
        
    }


    func removeMarket(withId id: String) {
        self.marketsDictionary.removeValue(forKey: id)
        
        let updatedMarkets: [Market] = self.marketsDictionary.values.map(\.value)
        
        guard let event = self.eventSubject.value else { return }
        event.markets = updatedMarkets
        eventSubject.send(event)
    }

    func updateMarketTradability(withId id: String, isTradable: Bool) {
        guard
            let marketSubject = self.marketsDictionary[id]
        else {
            return
        }
        
        let market = marketSubject.value
        market.isTradable = isTradable
        marketSubject.send(market)
    }

    // Live data updates
    func updateEventStatus(newStatus: String) {
        guard let event = self.eventSubject.value else { return }
        event.status = EventStatus(value: newStatus)
        eventSubject.send(event)
    }

    func updateEventTime(newTime: String) {
        guard let event = self.eventSubject.value else { return }
        event.matchTime = newTime
        eventSubject.send(event)
    }

    func updateEventScore(newHomeScore: Int?, newAwayScore: Int?) {
        guard let event = self.eventSubject.value else { return }
        if let newHomeScoreValue = newHomeScore {
            event.homeTeamScore = newHomeScoreValue
        }
        if let newAwayScoreValue = newAwayScore {
            event.awayTeamScore = newAwayScoreValue
        }
        eventSubject.send(event)
    }
    
    func updateEventDetailedScore(_ detailedScore: Score) {
        guard let event = self.eventSubject.value else { return }
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
    
    func updateEventFullDetailedScore(_ detailedScore: [String: Score]) {
        for value in detailedScore.values {
            self.updateEventDetailedScore(value)
        }
    }
    
    func updateActivePlayer(_ activePlayerServing: ActivePlayerServe?) {
        guard let event = self.eventSubject.value else { return }
        event.activePlayerServing = activePlayerServing
        self.eventSubject.send(event)
    }

}

extension SportRadarEventStorage {

    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, Never> {
        return self.eventSubject.eraseToAnyPublisher()
    }

    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market, Never>? {
        return self.marketsDictionary[id]?.eraseToAnyPublisher()
    }

    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome, Never>? {
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

