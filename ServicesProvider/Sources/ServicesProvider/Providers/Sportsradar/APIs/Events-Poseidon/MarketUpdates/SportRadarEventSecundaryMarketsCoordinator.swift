//
//  SportRadarEventMarketsCoordinator.swift
//
//
//  Created by Ruben Roques on 15/04/2024.
//

import Foundation
import Combine
import OrderedCollections

class SportRadarEventMarketsCoordinator {

    var storage: SportRadarEventStorage
    var sessionToken: String

    let eventMainMarketIdentifier: ContentIdentifier

    let eventSecundaryMarketsIdentifier: ContentIdentifier

    // TODO: check why live highlights in home are losing the reference to this subscription.
    // TODO: IMPORTANT: This vars needs to be weak for the auto unsubscribe to work
    weak var subscription: Subscription?

    var isActive: Bool {
        if self.waitingSubscription {
            // We haven't tried to subscribe or the
            // subscribe request it's ongoing right now
            return true
        }

        return self.subscription != nil
    }

    var eventWithSecundaryMarketsPublisher: AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return self.eventWithSecundaryMarketsSubject
            .eraseToAnyPublisher()
    }

    private var eventWithSecundaryMarketsSubject: CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError> = .init(.disconnected)

    private var waitingSubscription = true
    private let decoder = JSONDecoder()
    private let session = URLSession.init(configuration: .default)

    private var cancellables = Set<AnyCancellable>()

    private let subscriptionAccessQueue = DispatchQueue(label: "com.goma.subscriptionAccessQueue")

    init(matchId: String, sessionToken: String, storage: SportRadarEventStorage) {

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
                                 self.eventWithSecundaryMarketsSubject.replaceError(with: .disconnected))
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

    }

    deinit {
        print("SportRadarEventMarketsCoordinator.deinit")
    }

    func start() {
        self.subscribeEventMainMarkets()
    }

    private func subscribeEventMainMarkets() {
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
            .flatMap { data -> AnyPublisher<Void, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8), responseString.lowercased().contains("version") {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.subscription = nil
                }
                self?.subscribeEventSecundaryMarkets()
            }, receiveValue: { [weak self] in
                if let self = self {

                    self.subscriptionAccessQueue.sync {
                        let subscription = Subscription(contentIdentifier: self.eventMainMarketIdentifier,
                                                        sessionToken: self.sessionToken,
                                                        unsubscriber: self)

                        if let currentSubscription = self.subscription {
                            currentSubscription.associateSubscription(subscription)
                        }
                        else {
                            self.subscription = subscription
                        }

                        self.eventWithSecundaryMarketsSubject.send(.connected(subscription: subscription))
                    }
                }
            })
            .store(in: &self.cancellables)
    }

    private func subscribeEventSecundaryMarkets() {
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
            .flatMap { data -> AnyPublisher<Void, ServiceProviderError> in
                if let responseString = String(data: data, encoding: .utf8), responseString.lowercased().contains("version") {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                } else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.subscription = nil
                }
                self?.waitingSubscription = false
            }, receiveValue: { [weak self] in
                if let self = self {

                    self.subscriptionAccessQueue.sync {
                        let subscription = Subscription(contentIdentifier: self.eventSecundaryMarketsIdentifier,
                                                        sessionToken: self.sessionToken,
                                                        unsubscriber: self)

                        if let currentSubscription = self.subscription {
                            currentSubscription.associateSubscription(subscription)
                        }
                    }
                }
            })
            .store(in: &self.cancellables)
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
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

extension SportRadarEventMarketsCoordinator {

    func updatedMainMarket(forContentIdentifier identifier: ContentIdentifier, onEvent event: Event) {
        if self.eventMainMarketIdentifier != identifier {
            return
        }
        self.storage.storeEvent(event, withMainMarket: true)
    }

    func updatedSecundaryMarkets(forContentIdentifier identifier: ContentIdentifier, onEvent event: Event) {
        if self.eventSecundaryMarketsIdentifier != identifier {
            return
        }
        self.storage.storeSecundaryMarkets(event.markets)
    }

    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {
        if content.contentIdentifier?.contentType == .eventSecundaryMarkets {
            return
        }

        guard
            let updatedContentIdentifier = content.contentIdentifier
        else {
            return
        }

        guard
            self.eventSecundaryMarketsIdentifier == updatedContentIdentifier || self.eventMainMarketIdentifier == updatedContentIdentifier
        else {
            return
        }

        switch content {
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)

        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            self.storage.updateOutcomeTradability(withId: selectionId, isTradable: isTradable)

        case .updateMarketTradability(_, let marketId, let isTradable):
            self.storage.updateMarketTradability(withId: marketId, isTradable: isTradable)

        case .addMarket(let contentIdentifier, let market):
            let mappedMarket = SportRadarModelMapper.market(fromInternalMarket: market)
            if contentIdentifier.contentType == .eventMainMarket {
                self.storage.addMainMarket(mappedMarket)
            }
            else {
                self.storage.addMarket(mappedMarket)
            }

        case .enableMarket(_, let marketId):
            self.storage.updateMarketTradability(withId: marketId, isTradable: true)

        case .removeMarket(let contentIdentifier, let marketId):
            if contentIdentifier.contentType == .eventMainMarket {
                self.storage.removeMainMarket(withId: marketId)
            }
            else {
                self.storage.removeMarket(withId: marketId)
            }

        default:
            () // ignore other cases
        }
    }
}

extension SportRadarEventMarketsCoordinator {

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

extension SportRadarEventMarketsCoordinator: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = self.session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider.Subscription.Debug SportRadarEventMarketsCoordinator unsubscribe failed")
                return
            }
            print("ServiceProvider.Subscription.Debug SportRadarEventMarketsCoordinator unsubscribe ok")
        }
        sessionDataTask.resume()
    }

}
