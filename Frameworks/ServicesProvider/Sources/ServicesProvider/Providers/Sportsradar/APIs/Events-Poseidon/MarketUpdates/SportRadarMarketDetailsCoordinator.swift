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
        case .disconnected:
            return nil
        case .connected:
            return nil
        case .contentUpdate(let content):
            return content
        }
    }

    private var outcomesDictionary: OrderedDictionary<String, CurrentValueSubject<Outcome, Never>>

    private let marketId: String
    private let eventId: String

    private let decoder = JSONDecoder()
    private let session = URLSession.init(configuration: .default)

    private var marketCancellable: AnyCancellable?

    init(marketId: String, eventId: String, sessionToken: String, contentIdentifier: ContentIdentifier) {

        print("SportRadarMarketDetailsCoordinator new \(contentIdentifier)")
        
        self.marketId = marketId
        self.eventId = eventId

        self.sessionToken = sessionToken
        self.contentIdentifier = contentIdentifier
        self.subscription = nil

        self.outcomesDictionary = [:]
        
        self.marketCurrentValueSubject = .init(.disconnected)

        self.connectListenner()
    }

    private func connectListenner() {
        
        self.marketCancellable?.cancel()
        self.marketCancellable = nil
        
        // Boot the coordinator
        self.marketCancellable = self.checkMarketUpdatesAvailable()
            .flatMap { [weak self] market -> AnyPublisher<Void, ServiceProviderError>  in
                guard let self = self else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
                
                // Create the subscription
                let subscription = Subscription(contentIdentifier: self.contentIdentifier, sessionToken: self.sessionToken, unsubscriber: self)
                self.marketCurrentValueSubject.send(.connected(subscription: subscription))
                self.subscription = subscription
                
                // update with the market from the get request
                self.updateMarket(market)
                
                return self.requestMarketUpdates()
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.subscription = nil
                    self?.marketCurrentValueSubject.send(completion: .failure(error))
                }
                
            }, receiveValue: { _ in
                
            })

    }
    
    private func checkMarketUpdatesAvailable() -> AnyPublisher<Market, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.get(contentIdentifier: self.contentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return self.session.dataTaskPublisher(for: request)
            .retry(1)
            .map({ return $0.data  })
            .mapError({ _ in return ServiceProviderError.invalidRequestFormat })
            .flatMap { (data: Data) -> AnyPublisher<Data, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8), responseString.uppercased().contains("CONTENT_NOT_FOUND") {
                    return Fail(outputType: Data.self, failure: ServiceProviderError.resourceUnavailableOrDeleted).eraseToAnyPublisher()
                }
                else {
                    return Just(data).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
            }
            .decode(type: SportRadarModels.SportRadarResponse<SportRadarModels.Market>.self, decoder: JSONDecoder() )
            .map({ SportRadarModelMapper.market(fromInternalMarket: $0.data) })
            .mapError({ error in
                if let serviceProviderError = error as? ServiceProviderError {
                    return serviceProviderError
                }
                else {
                    return ServiceProviderError.invalidResponse
                }
            })
            .eraseToAnyPublisher()

    }

    func requestMarketUpdates() -> AnyPublisher<Void, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.contentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return self.session.dataTaskPublisher(for: request)
            .retry(1)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw ServiceProviderError.onSubscribe
                }
                return data
            }
            .mapError { _ in ServiceProviderError.onSubscribe }
            .flatMap { data -> AnyPublisher<Void, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8), responseString.lowercased().contains("version") {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }


    func updateMarket(_ market: Market) {
        // print("☁️SP debugbetslip updated SportRadarMarketDetailsCoordinator \(self.contentIdentifier) \(market.id)")

        self.marketCurrentValueSubject.send(.contentUpdate(content: market))

        self.outcomesDictionary = [:]
        for outcome in market.outcomes {
            self.outcomesDictionary[outcome.id] = CurrentValueSubject(outcome)
        }
    }

    func reset() {
        self.marketCurrentValueSubject.send(.disconnected)

        self.outcomesDictionary = [:]
        self.subscription = nil
        
        self.connectListenner()
    }

    func reconnect(withNewSessionToken newSessionToken: String) {

        // Update the socket session token
        self.sessionToken = newSessionToken
        print("SportRadarMarketDetailsCoordinator: reconnect withNewSessionToken \(newSessionToken)")

        guard self.subscription != nil else { return }

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

//        guard
//            let updatedContentIdentifier = content.contentIdentifier
//        else {
//            print("SportRadarMarketDetailsCoordinator ignoring contentIdentifierLess \(content)")
//            return
//        }
//
//        if self.contentIdentifier != updatedContentIdentifier {
//            // ignoring this update, not subscribed by this class
//            // print("☁️SP \"type\":\"market\" SportRadarMarketDetailsCoordinator ignoring \(updatedContentIdentifier) != \(self.contentIdentifier)")
//            return
//        }
//        else {
//            print("☁️SP \"type\":\"market\" SportRadarMarketDetailsCoordinator handling \(updatedContentIdentifier) ==  self \(self.contentIdentifier)")
//        }

        // print("☁️SP debugdetails  \"type\":\"market\" SportRadarMarketDetailsCoordinator handleContentUpdate \(content)")

        let trackedMarketId = self.marketId
        
        switch content {
        case .updateMarketTradability(_, let marketId, let isTradable):
            if trackedMarketId == marketId {
                // print("☁️SP debugbetslip updateMarketTradability \(marketId) \(isTradable)")
                self.updateMarketTradability(withId: marketId, isTradable: isTradable)
            }
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)

        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            self.updateMarketTradability(withId: selectionId, isTradable: isTradable)

        case .addMarket(_ , let market):
            if trackedMarketId == market.id {
                for outcome in market.outcomes {
                    if let fractionOdd = outcome.odd.fractionOdd {
                        self.updateOutcomeOdd(withId: outcome.id, newOddNumerator: String(fractionOdd.numerator), newOddDenominator: String(fractionOdd.denominator))
                    }
                }
                // print("☁️SP MarketDetailer debugbetslip \(market.id) add market ")
                self.updateMarketTradability(withId: market.id, isTradable: market.isTradable)
            }
        case .enableMarket(_, let marketId):
            if trackedMarketId == marketId {
                // print("☁️SP MarketDetailer debugbetslip \(marketId) enabled market")
                self.updateMarketTradability(withId: marketId, isTradable: true)
            }
        case .removeMarket(_, let marketId):
            if trackedMarketId == marketId {
                // print("☁️SP MarketDetailer debugbetslip \(marketId) removed market")
                self.updateMarketTradability(withId: marketId, isTradable: false)
            }
        case .removeEvent(_, let updatedEventId):
            if self.eventId == updatedEventId {
                self.updateMarketTradability(withId: trackedMarketId, isTradable: false)
            }
        case .addEvent(_, let updatedEvent):
            if self.eventId == updatedEvent.id {
                self.updateMarketTradability(withId: trackedMarketId, isTradable: true)
            }
        default:
            () // Ignore other cases
        }
    }

    func updateMarketTradability(withId id: String, isTradable: Bool) {
        guard let updatedMarket = self.market else { return }
        let currentTradable = updatedMarket.isTradable
        if isTradable != currentTradable {
            updatedMarket.isTradable = isTradable
            self.marketCurrentValueSubject.send(.contentUpdate(content: updatedMarket))
        }
    }

    func updateOutcomeOdd(withId id: String, newOddNumerator: String?, newOddDenominator: String?) {
        guard 
            let newMarket = self.market
        else {
            return
        }
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

        self.marketCurrentValueSubject.send(.contentUpdate(content: newMarket))
    }

    func updateOutcomeTradability(withId id: String, isTradable: Bool) {
        guard let outcomeSubject = self.outcomesDictionary[id] else { return }
        let outcome = outcomeSubject.value
        outcome.isTradable = isTradable
        outcomeSubject.send(outcome)
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

