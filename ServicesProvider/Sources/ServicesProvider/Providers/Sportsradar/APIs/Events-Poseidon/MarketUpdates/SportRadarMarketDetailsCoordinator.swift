//
//  File.swift
//  
//
//  Created by Ruben Roques on 07/03/2023.
//

import Foundation
import Combine
import OrderedCollections

class SportRadarMarketDetailsCoordinator {

    var sessionToken: String
    let contentIdentifier: ContentIdentifier

    weak var subscription: Subscription?
    var isActive: Bool {
        return self.subscription != nil
    }

    var marketPublisher: AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {
        return marketCurrentValueSubject.eraseToAnyPublisher()
    }

    private var marketCurrentValueSubject: CurrentValueSubject<SubscribableContent<Market>, ServiceProviderError>
    private var market: Market? {
        switch self.marketCurrentValueSubject.value {
        case .disconnected: return nil
        case .connected: return nil
        case .contentUpdate(let content): return content
        }
    }

    private var outcomesDictionary: OrderedDictionary<String, CurrentValueSubject<Outcome, Never>>

    init(sessionToken: String, contentIdentifier: ContentIdentifier) {
        self.sessionToken = sessionToken
        self.contentIdentifier = contentIdentifier
        self.subscription = nil

        self.outcomesDictionary = [:]
        
        self.marketCurrentValueSubject = .init(.disconnected)
    }

    func requestMarketUpdates() -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {

        self.marketCurrentValueSubject = CurrentValueSubject<SubscribableContent<Market>, ServiceProviderError>.init(.disconnected)
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.contentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                (error == nil),
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("SportRadarEventsPaginator: requestInitialPage - error on subscribe to topic \(error) \(response)")
                self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            let subscription = Subscription(contentIdentifier: self.contentIdentifier,
                                            sessionToken: self.sessionToken,
                                            unsubscriber: self)
            self.subscription = subscription
            self.marketCurrentValueSubject.send(.connected(subscription: subscription))
        }
        sessionDataTask.resume()
        return self.marketCurrentValueSubject.eraseToAnyPublisher()
    }


    func updateMarket(_ market: Market) {
        self.marketCurrentValueSubject.send(.contentUpdate(content: market))

        self.outcomesDictionary = [:]
        for outcome in market.outcomes {
            self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
        }
    }

    func reset() {
        self.marketCurrentValueSubject.send(.disconnected)

        self.outcomesDictionary = [:]
    }

    func reconnect(withNewSessionToken newSessionToken: String) {

        // Update the socket session token
        self.sessionToken = newSessionToken
        print("SportRadarMarketDetailsCoordinator: reconnect withNewSessionToken \(newSessionToken)")

        guard let subscription = self.subscription else { return }

        // Reset the storage, avoid duplicates, we will recieve every info again
        self.reset()

        //
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.contentIdentifier)

        guard let request = endpoint.request() else { return }
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("SportRadarMarketDetailsCoordinator: reconnect dataTask contentIdentifier \(self.contentIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarMarketDetailsCoordinator: reconnect dataTask contentIdentifier \(self.contentIdentifier) data \(dataString)")
            }
        }
        sessionDataTask.resume()
    }

}


extension SportRadarMarketDetailsCoordinator {

    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {
        switch content {
        case .updateMarketTradability(_, let marketId, let isTradable):
            self.updateMarketTradability(withId: marketId, isTradable: isTradable)
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)
        case .addMarket(_ , let market):
            for outcome in market.outcomes {
                if let fractionOdd = outcome.odd.fractionOdd {
                    self.updateOutcomeOdd(withId: outcome.id, newOddNumerator: String(fractionOdd.numerator), newOddDenominator: String(fractionOdd.denominator))
                }
            }
            self.updateMarketTradability(withId: market.id, isTradable: true)
        case .removeMarket(_, let marketId):
            self.updateMarketTradability(withId: marketId, isTradable: false)
        default:
            () // Ignore other cases
        }
    }

    func updateMarketTradability(withId id: String, isTradable: Bool) {
        guard let newMarket = self.market else { return }
        newMarket.isTradable = isTradable
        self.marketCurrentValueSubject.send(.contentUpdate(content: newMarket))
    }

    func updateOutcomeOdd(withId id: String, newOddNumerator: String?, newOddDenominator: String?) {
        guard let newMarket = self.market else { return }
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

        // Update the market with the new outcome list
        let updatedOutcomes = Array(self.outcomesDictionary.values.map(\.value))
        newMarket.outcomes = updatedOutcomes
        self.marketCurrentValueSubject.send(.contentUpdate(content: newMarket))
    }

}

extension SportRadarMarketDetailsCoordinator {


}

extension SportRadarMarketDetailsCoordinator: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("SportRadarMarketDetailsCoordinator unsubscribe failed")
                return
            }
            print("SportRadarMarketDetailsCoordinator unsubscribe ok")
        }
        sessionDataTask.resume()
    }

}
