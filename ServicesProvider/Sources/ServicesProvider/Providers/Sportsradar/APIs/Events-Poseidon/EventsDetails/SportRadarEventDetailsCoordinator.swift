//
//  File.swift
//  
//
//  Created by Ruben Roques on 01/03/2023.
//

import Foundation
import Combine

class SportRadarEventDetailsCoordinator {

    var storage: SportRadarEventDetailsStorage
    var sessionToken: String
    let contentIdentifier: ContentIdentifier

    weak var subscription: Subscription?
    var isActive: Bool {
        return self.subscription != nil
    }

    var eventDetailsPublisher: AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return eventDetailsCurrentValueSubject.eraseToAnyPublisher()
    }

    private var eventDetailsCurrentValueSubject: CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError>

    init(contentIdentifier: ContentIdentifier, sessionToken: String, storage: SportRadarEventDetailsStorage) {
        self.sessionToken = sessionToken
        self.storage = storage
        self.contentIdentifier = contentIdentifier

        self.eventDetailsCurrentValueSubject = .init(.disconnected)
    }

    func requestInitialEventDetails() -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        let publisher = CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError>.init(.disconnected)
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
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            let subscription = Subscription(contentIdentifier: self.contentIdentifier,
                                            sessionToken: self.sessionToken,
                                               unsubscriber: self)
            publisher.send(.connected(subscription: subscription))
            self.subscription = subscription
        }
        sessionDataTask.resume()

        self.eventDetailsCurrentValueSubject = publisher

        return self.eventDetailsCurrentValueSubject.eraseToAnyPublisher()
    }

    func updateEventDetails(_ updatedEvent: Event) {
        self.storage.storeEvent(updatedEvent)

        self.eventDetailsCurrentValueSubject.send(.contentUpdate(content: updatedEvent))
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        self.sessionToken = newSessionToken
        self.storage.reset()

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.contentIdentifier)

        guard let request = endpoint.request() else { return }
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.contentIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.contentIdentifier) data \(dataString)")
            }
        }
        sessionDataTask.resume()
    }

}


extension SportRadarEventDetailsCoordinator {

    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {
        switch content {
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)

        case .updateMarketTradability(_, let marketId, let isTradable):
            self.storage.updateMarketTradability(withId: marketId, isTradable: isTradable)

        case .updateEventState(_, let eventId, let newStatus):
            self.storage.updateEventStatus(withId: eventId, newStatus: newStatus)
        case .updateEventTime(_, let eventId, let newTime):
            self.storage.updateEventTime(withId: eventId, newTime: newTime)
        case .updateEventScore(_, let eventId, let homeScore, let awayScore):
            self.storage.updateEventScore(withId: eventId, newHomeScore: homeScore, newAwayScore: awayScore)

        default:
            () // Ignore other cases
        }
    }

}

extension SportRadarEventDetailsCoordinator {

    func subscribeToEventUpdates(withId id: String) -> AnyPublisher<Event?, Never> {
        return self.storage.subscribeToEventUpdates(withId: id)
    }

    func subscribeToEventMarketUpdates(withId id: String) -> AnyPublisher<Market, Never>? {
        return self.storage.subscribeToEventMarketUpdates(withId: id)
    }

    func subscribeToEventOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome, Never>? {
        return self.storage.subscribeToEventOutcomeUpdates(withId: id)
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


extension SportRadarEventDetailsCoordinator: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
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
