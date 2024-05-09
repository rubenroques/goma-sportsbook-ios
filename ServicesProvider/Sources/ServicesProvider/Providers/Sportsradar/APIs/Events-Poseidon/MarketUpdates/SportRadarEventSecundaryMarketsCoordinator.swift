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

    let eventSecundaryMarketsIdentifier: ContentIdentifier
    
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

    init(matchId: String, sessionToken: String, storage: SportRadarEventStorage) {
        self.sessionToken = sessionToken
        self.storage = storage

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
        
    }
    
    func start() {
        // Boot the coordinator
        self.subscribeEventSecundaryMarkets()
    }
    
    func subscribeEventSecundaryMarkets() {
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
                    print("subscribeEventSecundaryMarkets completed")
                case .failure(let failure):
                    self?.subscription = nil
                    print("subscribeEventSecundaryMarkets completed with error: \(failure)")
                }
                self?.waitingSubscription = false
            }, receiveValue: { [weak self] in
                print("subscribeEventSecundaryMarkets done")
                
                if let self = self {
                    let subscription = Subscription(contentIdentifier: self.eventSecundaryMarketsIdentifier,
                                                    sessionToken: self.sessionToken,
                                                    unsubscriber: self)
                    self.eventWithSecundaryMarketsSubject.send(.connected(subscription: subscription))
                    self.subscription = subscription
                }
                
            })
            .store(in: &self.cancellables)
    }
   
    func updateEventSecundaryMarkets(_ updatedEvent: Event, forContentIdentifier contentIdentifier: ContentIdentifier) {
        if contentIdentifier == self.eventSecundaryMarketsIdentifier {
            self.storage.storeEvent(updatedEvent)
            self.eventWithSecundaryMarketsSubject.send(.contentUpdate(content: updatedEvent))
        }
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        self.sessionToken = newSessionToken
        self.storage.reset()

        //
        //
        let secundaryMarketsEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                contentIdentifier: self.eventSecundaryMarketsIdentifier)

        guard let secundarMarketsRequest = secundaryMarketsEndpoint.request() else { return }
        let secundaryMarketsSessionDataTask = self.session.dataTask(with: secundarMarketsRequest) { data, response, error in
            if let error {
                print("SportRadarEventSecundaryMarketsCoordinator: reconnect dataTask contentIdentifier \(self.eventSecundaryMarketsIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventSecundaryMarketsCoordinator: reconnect dataTask contentIdentifier \(self.eventSecundaryMarketsIdentifier) data \(dataString)")
            }
        }
        secundaryMarketsSessionDataTask.resume()

    }

}


extension SportRadarEventSecundaryMarketsCoordinator {

    func updatedSecundaryMarkets(forContentIdentifier identifier: ContentIdentifier, onEvent event: Event) {
                
        if self.eventSecundaryMarketsIdentifier != identifier {
            return
        }
                
        self.storage.storeEvent(event)
    }
    
    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {

        guard
            let updatedContentIdentifier = content.contentIdentifier
        else {
            return
        }

        if self.eventSecundaryMarketsIdentifier != updatedContentIdentifier {
            return
        }

        switch content {

        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)
        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            self.storage.updateOutcomeTradability(withId: selectionId, isTradable: isTradable)

        case .updateMarketTradability(_, let marketId, let isTradable):
            self.storage.updateMarketTradability(withId: marketId, isTradable: isTradable)

        //
        case .addMarket(_ , let market):
            let mappedMarket = SportRadarModelMapper.market(fromInternalMarket: market)
            self.storage.addMarket(mappedMarket)

        case .enableMarket(_, let marketId):
            self.storage.updateMarketTradability(withId: marketId, isTradable: true)
            
        case .removeMarket(_, let marketId):
            self.storage.removeMarket(withId: marketId)

        default:
            () // Ignore other cases
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
        return self.storage.containsEvent(withid: id)
    }
    
    func containsMarket(withid id: String) -> Bool {
        return self.storage.containsMarket(withid: id)
    }

    func containsOutcome(withid id: String) -> Bool {
        return self.storage.containsOutcome(withid: id)
    }

}

extension SportRadarEventSecundaryMarketsCoordinator: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = self.session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider.Subscription.Debug unsubscribe failed")
                return
            }
            print("ServiceProvider.Subscription.Debug unsubscribe ok")
        }
        sessionDataTask.resume()
    }

}
