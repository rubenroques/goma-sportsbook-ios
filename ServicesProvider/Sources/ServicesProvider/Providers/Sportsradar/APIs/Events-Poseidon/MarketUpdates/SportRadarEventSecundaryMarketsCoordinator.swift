//
//  SportRadarEventSecundaryMarketsCoordinator.swift
//
//
//  Created by Ruben Roques on 15/04/2024.
//

import Foundation
import Combine
import OrderedCollections

class SportRadarEventSecundaryMarketsCoordinator {

    var storage: SportRadarEventStorage
    var sessionToken: String

    let eventMainMarketIdentifier: ContentIdentifier

    let eventSecundaryMarketsIdentifier: ContentIdentifier

    // TODO: check why live highlights in home are losing the reference to this subscription.
    // TODO: IMPORTANT: This vars needs to be weak for the auto unsubscribe to work
    var subscription: Subscription?
    var liveSubscription: Subscription?

    var isActive: Bool {
        var isActive = self.subscription != nil
        if self.waitingSubscription {
            // We haven't tried to subscribe or the
            // subscribe request it's ongoing right now
            isActive = true
        }

        print("[Debug] \(self.debugMatchId) SREventSecundaryMarketsC.isActive \(isActive)")

        return isActive
    }

    var eventWithSecundaryMarketsPublisher: AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        if case let .connected(subscription) = eventWithSecundaryMarketsSubject.value {
            return self.eventWithSecundaryMarketsSubject
                .prepend(.connected(subscription: subscription))
                .eraseToAnyPublisher()
        }
        else if case .contentUpdate(_) = eventWithSecundaryMarketsSubject.value {
            if let subscription = self.subscription {
                return self.eventWithSecundaryMarketsSubject
                    .prepend(.connected(subscription: subscription))
                    .eraseToAnyPublisher()
            }
            else {
                return self.eventWithSecundaryMarketsSubject.eraseToAnyPublisher()
            }
        }
        else {
            return self.eventWithSecundaryMarketsSubject
                .eraseToAnyPublisher()
        }
    }

    private var eventWithSecundaryMarketsSubject: CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError> = .init(.disconnected)

    private var waitingSubscription = true
    private let decoder = JSONDecoder()
    private let session = URLSession.init(configuration: .default)

    private var cancellables = Set<AnyCancellable>()

    var debugMatchId: String

    init(matchId: String, sessionToken: String, storage: SportRadarEventStorage) {
        print("[Debug] \(matchId) SREvSecMarketsC.init")

        self.debugMatchId = matchId

        self.sessionToken = sessionToken
        self.storage = storage

        let eventMainMarketType = ContentType.eventMainMarket
        let eventMainMarketRoute = ContentRoute.eventMainMarket(eventId: matchId)
        let eventMainMarketIdentifier = ContentIdentifier(contentType: eventMainMarketType,
                                                                contentRoute: eventMainMarketRoute)

        self.eventMainMarketIdentifier = eventMainMarketIdentifier

        let eventSecundaryMarketsType = ContentType.eventSecundaryMarkets
        let eventSecundaryMarketsRoute = ContentRoute.eventSecundaryMarkets(eventId: matchId)
        let eventSecundaryMarketsIdentifier = ContentIdentifier(contentType: eventSecundaryMarketsType,
                                                                contentRoute: eventSecundaryMarketsRoute)

        self.eventSecundaryMarketsIdentifier = eventSecundaryMarketsIdentifier

        self.subscription = nil
        self.waitingSubscription = true

        Publishers.CombineLatest(self.storage.eventPublisher,
                                 self.eventWithSecundaryMarketsPublisher.replaceError(with: .disconnected))
        .filter({ storedEvent, eventWithSecundaryMarketsSubject in
            switch eventWithSecundaryMarketsSubject {
            case .connected, .contentUpdate:
                return true && (storedEvent != nil)
            case .disconnected:
                return false
            }
        })
        .compactMap({ updatedStoredEvent, _  in
            if let updatedStoredEvent {
                return updatedStoredEvent
            }
            else {
                return nil
            }
        })
        .sink { completion in
        } receiveValue: { [weak self] updatedStoredEvent in
            self?.eventWithSecundaryMarketsSubject.send(.contentUpdate(content: updatedStoredEvent))
        }
        .store(in: &self.cancellables)

        self.subscribeEventMainMarkets()
    }

    deinit {
        print("[Debug] \(debugMatchId) SREvSecMarketsC.deinit")
    }

    private func subscribeEventMainMarkets() {
        print("[Debug] \(debugMatchId) SREvSecMarketsC.subscribeEventMainMarkets - Starting subscription")
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.eventMainMarketIdentifier)

        guard
            let request = endpoint.request()
        else {
            return
        }

        return self.session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    throw ServiceProviderError.onSubscribe
                }
                return data
            }
            .mapError { _ in ServiceProviderError.onSubscribe }
            .flatMap { [weak self] data -> AnyPublisher<Void, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8), responseString.lowercased().contains("version") {
                    print("[Debug] \(self?.debugMatchId ?? "") SREvSecMarketsC.subscribeEventMainMarkets - subscribe")
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                } else {
                    print("[Debug] \(self?.debugMatchId ?? "") ERROR: SREvSecMarketsC.subscribeEventMainMarkets - .onSubscribe")
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print("[Debug] \(self?.debugMatchId ?? "") SREvSecMarketsC.subscribeEventMainMarkets - Failed with error: \(failure)")
                    self?.subscription = nil
                }
            }, receiveValue: { [weak self] in
                print("[Debug] \(self?.debugMatchId ?? "") SREvSecMarketsC.subscribeEventMainMarkets - Subscription successful")
                if let self = self {
                    let subscription = Subscription(contentIdentifier: self.eventMainMarketIdentifier,
                                                    sessionToken: self.sessionToken,
                                                    unsubscriber: self)
                    self.subscription = subscription
                    self.eventWithSecundaryMarketsSubject.send(.connected(subscription: subscription))
                    self.subscribeEventSecundaryMarkets()
                }
            })
            .store(in: &self.cancellables)
    }

    private func subscribeEventSecundaryMarkets() {
        print("[Debug] \(debugMatchId) SREvSecMarketsC.subscribeEventSecundaryMarkets - Starting subscription")
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.eventSecundaryMarketsIdentifier)

        guard
            let request = endpoint.request()
        else {
            return
        }

        return self.session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    throw ServiceProviderError.onSubscribe
                }
                return data
            }
            .mapError { _ in ServiceProviderError.onSubscribe }
            .flatMap { [weak self] data -> AnyPublisher<Void, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8), responseString.lowercased().contains("version") {
                    print("[Debug] \(self?.debugMatchId ?? "") SREvSecMarketsC.subscribeEventSecundaryMarkets - subscribed")
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                } else {
                    print("[Debug] \(self?.debugMatchId ?? "") ERROR: SREvSecMarketsC.subscribeEventSecundaryMarkets - .onSubscribe")
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print("[Debug] \(self?.debugMatchId ?? "") ERROR: SREvSecMarketsC.subscribeEventSecundaryMarkets - \(failure)")
                    self?.subscription = nil
                }
            }, receiveValue: { [weak self] in
                if let self = self {
                    let subscription = Subscription(contentIdentifier: self.eventSecundaryMarketsIdentifier,
                                                    sessionToken: self.sessionToken,
                                                    unsubscriber: self)

                    if let currentSubscription = self.subscription {
                        currentSubscription.associateSubscription(subscription)
                    }

                    print("[Debug] \(self.debugMatchId) SREvSecMarketsC.subscribeEventSecundaryMarkets associatedSubscription \(subscription)")
                    print("[Debug] \(self.debugMatchId) SREvSecMarketsC.subscribeEventSecundaryMarkets - not waiting anymore")

                    self.waitingSubscription = false
                }
            })
            .store(in: &self.cancellables)
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        print("[Debug] \(debugMatchId) SREvSecMarketsC.reconnect - Starting with new session token")
        self.sessionToken = newSessionToken
        self.storage.reset()

        //
        //
        let secundaryMarketsEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                contentIdentifier: self.eventSecundaryMarketsIdentifier)

        guard let secundarMarketsRequest = secundaryMarketsEndpoint.request() else {
            return
        }
        let secundaryMarketsSessionDataTask = self.session.dataTask(with: secundarMarketsRequest) { data, response, error in
            if let error {
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
            }
        }
        secundaryMarketsSessionDataTask.resume()
    }
}

extension SportRadarEventSecundaryMarketsCoordinator {

    func updatedMainMarket(forContentIdentifier identifier: ContentIdentifier, onEvent event: Event) {
        print("[Debug] \(debugMatchId) SREvSecMarketsC updatedMainMarket: \(identifier)")
        if self.eventMainMarketIdentifier != identifier {
            return
        }
        self.storage.storeEvent(event, withMainMarket: true)
    }

    func updatedSecundaryMarkets(forContentIdentifier identifier: ContentIdentifier, onEvent event: Event) {
        print("[Debug] \(debugMatchId) SREvSecMarketsC updatedSecundaryMarkets: \(identifier)")
        if self.eventSecundaryMarketsIdentifier != identifier {
            return
        }
        self.storage.storeSecundaryMarkets(event.markets)
    }

    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {

        guard
            let updatedContentIdentifier = content.contentIdentifier,
            self.eventSecundaryMarketsIdentifier == updatedContentIdentifier || self.eventMainMarketIdentifier == updatedContentIdentifier
        else {
            return
        }

        print("[Debug] \(debugMatchId) SREvSecMarketsC.handleContentUpdate - Content type: \(content.contentIdentifier?.contentType.rawValue ?? "unknown")")

        switch content {
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            let odd = OddFormat.fraction(
                numerator: Int(newOddNumerator ?? "1") ?? 1,
                denominator: Int(newOddDenominator ?? "1") ?? 1).decimalOdd
            print("[Debug] \(debugMatchId) Market Update - Outcome \(selectionId) odds changed to \(odd)")
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)

        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            print("[Debug] \(debugMatchId) Market Update - Outcome \(selectionId) tradability changed to \(isTradable)")
            self.storage.updateOutcomeTradability(withId: selectionId, isTradable: isTradable)

        case .updateMarketTradability(_, let marketId, let isTradable):
            print("[Debug] \(debugMatchId) Market Update - Market \(marketId) tradability changed to \(isTradable)")
            self.storage.updateMarketTradability(withId: marketId, isTradable: isTradable)

        case .addMarket(let contentIdentifier, let market):
            let mappedMarket = SportRadarModelMapper.market(fromInternalMarket: market)
            print("[Debug] \(debugMatchId) Market Operation - Adding market \(market.id) - Type: \(contentIdentifier.contentType.rawValue)")
            if contentIdentifier.contentType == .eventMainMarket {
                print("[Debug] \(debugMatchId) Market Operation - Adding as main market")
                self.storage.addMainMarket(mappedMarket)
            }
            else {
                print("[Debug] \(debugMatchId) Market Operation - Adding as secondary market")
                self.storage.addMarket(mappedMarket)
            }

        case .enableMarket(_, let marketId):
            print("[Debug] \(debugMatchId) Market Operation - Enabling market \(marketId)")
            self.storage.updateMarketTradability(withId: marketId, isTradable: true)

        case .removeMarket(let contentIdentifier, let marketId):
            print("[Debug] \(debugMatchId) Market Operation - Removing market \(marketId) - Type: \(contentIdentifier.contentType.rawValue)")
            if contentIdentifier.contentType == .eventMainMarket {
                print("[Debug] \(debugMatchId) Market Operation - Removing main market")
                self.storage.removeMainMarket(withId: marketId)
            }
            else {
                print("[Debug] \(debugMatchId) Market Operation - Removing secondary market")
                self.storage.removeMarket(withId: marketId)
            }

        default:
            () // ignore other cases
        }
    }
}

extension SportRadarEventSecundaryMarketsCoordinator {

    func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, Never> {
        return self.storage.subscribeToEventOnListsLiveDataUpdates(withId: id)
    }

    func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market, Never>? {
        return self.storage.subscribeToEventOnListsMarketUpdates(withId: id)
    }

    func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome, Never>? {
        return self.storage.subscribeToEventOnListsOutcomeUpdates(withId: id)
    }

    func containsEvent(withid id: String) -> Bool {
        let contains = self.storage.containsEvent(withid: id)
        return contains
    }

    func containsMarket(withid id: String) -> Bool {
        let contains = self.storage.containsMarket(withid: id)
        return contains
    }

    func containsOutcome(withid id: String) -> Bool {
        let contains = self.storage.containsOutcome(withid: id)
        return contains
    }
}

extension SportRadarEventSecundaryMarketsCoordinator: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        print("[Debug] \(debugMatchId) SREvSecMarketsC.unsubscribe - Starting unsubscription")
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = self.session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("[Debug] \(self.debugMatchId) SREvSecMarketsC.unsubscribe - Failed")
                return
            }
            print("[Debug] \(self.debugMatchId) SREvSecMarketsC.unsubscribe - Successful")
        }
        sessionDataTask.resume()
    }

}
