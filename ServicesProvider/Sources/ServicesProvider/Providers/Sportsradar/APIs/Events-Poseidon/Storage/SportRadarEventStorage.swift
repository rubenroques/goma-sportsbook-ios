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
            .throttle(for: .milliseconds(800), scheduler: DispatchQueue.main, latest: true)
            .eraseToAnyPublisher()
    }
    
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

        var debugOutput = "OddDebug: Event - \(event.id)\n"
        for market in event.markets {
            debugOutput = debugOutput + "   OddDebug: Market - \(market.id)\n"
            for outcome in market.outcomes {
                debugOutput = debugOutput + "      OddDebug: Outcome - \(outcome.id)\n"
                self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
            }
            self.marketsDictionary[market.id] = CurrentValueSubject(market)
        }
        
        if event.id == "3921509.1" {
            print(debugOutput)
        }
        
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
    

    // Market updates
    func addMarket(_ market: Market) {
        
        print("\(Date().timeIntervalSinceReferenceDate) storage-eventWithBalancedMarkets \(self.eventSubject.value?.id ?? "") - adding market: \(self.eventSubject.value?.homeTeamName ?? "") vs \(self.eventSubject.value?.awayTeamName ?? "") - \(market.name) [\(market.outcomes.map(\.name).joined(separator: ";"))]")
        
        if self.marketsDictionary[market.id] != nil { // We already
            updateMarketTradability(withId: market.id, isTradable: market.isTradable)
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
        
        if let marketSubject = self.marketsDictionary[id] {
            let market = marketSubject.value
            print("\(Date().timeIntervalSinceReferenceDate) storage-eventWithBalancedMarkets \(self.eventSubject.value?.id ?? "") - removeMarket market: \(self.eventSubject.value?.homeTeamName ?? "") vs \(self.eventSubject.value?.awayTeamName ?? "") - \(market.name) [\(market.outcomes.map(\.name).joined(separator: ";"))]")
        }
        
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
        guard let event = self.eventSubject.value else { return }
        
        event.scores = detailedScore
        
        eventSubject.send(event)
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

