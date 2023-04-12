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

    private var waiting = true
    private var timer: Timer?

    init(sessionToken: String, contentIdentifier: ContentIdentifier) {

        print("☁️SP debugbetslip new SportRadarMarketDetailsCoordinator \(contentIdentifier)")

        self.sessionToken = sessionToken
        self.contentIdentifier = contentIdentifier
        self.subscription = nil

        self.outcomesDictionary = [:]
        
        self.marketCurrentValueSubject = .init(.disconnected)
    }

    func requestMarketUpdates() -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {

        self.marketCurrentValueSubject.send(.disconnected)

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.contentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        print("☁️SP debugbetslip will request MarketUpdates \(request.timeoutInterval) SportRadarMarketDetailsCoordinator \(self.contentIdentifier)")

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                if error.code == NSURLErrorTimedOut {
                    // Request timed out.
                    print("☁️SP debugbetslip Request timed-out SportRadarMarketDetailsCoordinator  \(self.contentIdentifier)")

                    self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.resourceNotFound))
                } else {
                    // Request encountered another error: \(error.localizedDescription)
                    self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe))
                }
            } else if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    // Handle the data
                    let subscription = Subscription(contentIdentifier: self.contentIdentifier, sessionToken: self.sessionToken, unsubscriber: self)
                    self.subscription = subscription
                    self.marketCurrentValueSubject.send(.connected(subscription: subscription)) // Request succeeded with data: \(data)

                    self.startWaiting()
                    print("☁️SP debugbetslip Request 200 ok SportRadarMarketDetailsCoordinator \(self.contentIdentifier) \(String.init(data: data, encoding: .utf8) ?? "--")")
                } else {
                    self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe)) // Request failed with status code: \(response.statusCode)
                }
            } else {
                self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe)) // Request failed with an unknown error.
            }
        }

//
//            print("☁️SP debugbetslip ", data, response, error, self.contentIdentifier)
//            guard
//                (error == nil),
//                let httpResponse = response as? HTTPURLResponse,
//                (200...299).contains(httpResponse.statusCode)
//            else {
//                print("☁️SP debugbetslip new SportRadarMarketDetailsCoordinator - error on subscribe to topic \(error) \(response)")
//                self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe))
//                return
//            }
//            let subscription = Subscription(contentIdentifier: self.contentIdentifier,
//                                            sessionToken: self.sessionToken,
//                                            unsubscriber: self)
//            self.subscription = subscription
//            self.marketCurrentValueSubject.send(.connected(subscription: subscription))
//
//            print("☁️SP debugbetslip sent connected SportRadarMarketDetailsCoordinator \(self.contentIdentifier)")
//        }

        print("☁️SP debugbetslip did request MarketUpdates SportRadarMarketDetailsCoordinator \(self.contentIdentifier)")

        sessionDataTask.resume()
        return self.marketCurrentValueSubject.eraseToAnyPublisher()
    }


    func updateMarket(_ market: Market) {
        print("☁️SP debugbetslip updated SportRadarMarketDetailsCoordinator \(self.contentIdentifier) \(market.id)")

        self.marketCurrentValueSubject.send(.contentUpdate(content: market))

        self.outcomesDictionary = [:]
        for outcome in market.outcomes {
            self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
        }
    }

    private func startWaiting() {
        self.waiting = true
        self.timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.waiting {
                self.handleWaitingTimeout()
            }
        }

        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)

    }

    private func stopWaiting() {
        waiting = false
        timer?.invalidate()
        timer = nil
    }

    private func handleWaitingTimeout() {
        self.stopWaiting()
        print("☁️SP debugbetslip 4 seconds elapsed, and the waiting value has not changed.")

        self.marketCurrentValueSubject.send(completion: .failure(ServiceProviderError.noResponseFromSocketOnContent))
        self.subscription = nil
    }

    func reset() {
        self.stopWaiting()
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

            if let id = self.market?.id {
                print("☁️SP debugbetslip \(id) \(selectionId) updated odd")
            }
            else {
                print("☁️SP debugbetslip no market found for SportRadarMarketDetailsCoordinator !?!?!")
            }

            self.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)
        case .addMarket(_ , let market):
            for outcome in market.outcomes {
                if let fractionOdd = outcome.odd.fractionOdd {
                    self.updateOutcomeOdd(withId: outcome.id, newOddNumerator: String(fractionOdd.numerator), newOddDenominator: String(fractionOdd.denominator))
                }
            }
            print("☁️SP MarketDetailer debugbetslip \(market.id) add market ")
            self.updateMarketTradability(withId: market.id, isTradable: true)

        case .enableMarket(_, let marketId):
            print("☁️SP MarketDetailer debugbetslip \(marketId) emable market")

            self.updateMarketTradability(withId: marketId, isTradable: true)
        case .removeMarket(_, let marketId):
            print("☁️SP MarketDetailer debugbetslip \(marketId) removed market")

            self.updateMarketTradability(withId: marketId, isTradable: false)

        default:
            () // Ignore other cases
        }
    }

    func updateMarketTradability(withId id: String, isTradable: Bool) {
        guard let updatedMarket = self.market else { return }
        let currentTradable = updatedMarket.isTradable
        if isTradable != currentTradable {
            updatedMarket.isTradable = isTradable
            print("debugbetslip \(id) ServiceProvider updated market Tradability \(isTradable)")
            self.marketCurrentValueSubject.send(.contentUpdate(content: updatedMarket))
        }
        else {
            print("No updated found updateMarketTradability on market \(id)")
        }
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

        if newOddNumeratorValue == oldNumerator && newOddDenominatorValue == oldDenominator {
            return
        }

        outcome.odd = OddFormat.fraction(numerator: newOddNumeratorValue, denominator: newOddDenominatorValue)
        outcomeSubject.send(outcome)

        // Update the market with the new outcome list
        let updatedOutcomes = Array(self.outcomesDictionary.values.map(\.value))
        newMarket.outcomes = updatedOutcomes

        print("debugbetslip-\(outcome.id) ServiceProvider updated odd  \(outcome.odd.decimalOdd)")
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
