//
//  File.swift
//  
//
//  Created by Ruben Roques on 02/12/2022.
//

import Foundation
import Combine

class SportRadarEventsPaginator {

    var storage: SportRadarEventsStorage

    var startPageIndex: Int = 0
    var currentPage: Int

    var hasNextPage: Bool = false

    var subscription: Subscription?
    let contentIdentifier: ContentIdentifier

    var sessionToken: String

    private var eventsPerPage: Int

    private var eventsSubject: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    init(contentIdentifier: ContentIdentifier, sessionToken: String, storage: SportRadarEventsStorage) {

        self.sessionToken = sessionToken
        self.storage = storage
        self.contentIdentifier = contentIdentifier

        self.eventsPerPage = self.contentIdentifier.contentRoute.eventCount ?? Int.max
        self.startPageIndex = 0
        self.currentPage = 0

        self.eventsSubject = .init(.disconnected)
        // self.activeSubscriptions = .init(keyOptions: .strongMemory , valueOptions: .weakMemory)
    }

    // Return as boolean indicating if there is more pages
    func requestNextPage() -> AnyPublisher<Bool, ServiceProviderError> {

        if !hasNextPage {
            return Just(false).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }

        self.currentPage = self.currentPage + 1
        let nextPageIndex = self.currentPage
        
        let nextPageRoute: ContentRoute
        switch self.contentIdentifier.contentRoute {
        case .preLiveEvents(let sportAlphaId, let startDate, let endDate, _, let eventCount, let sortType):
            nextPageRoute = .preLiveEvents(sportAlphaId: sportAlphaId,
                                           startDate: startDate,
                                           endDate: endDate,
                                           pageIndex: nextPageIndex,
                                           eventCount: eventCount,
                                           sortType: sortType)
        case .liveEvents(let sportAlphaId, _):
            nextPageRoute = .liveEvents(sportAlphaId: sportAlphaId,
                                        pageIndex: nextPageIndex)
        default:
            return Just(false).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }

        let nextPageContentIdentifier = ContentIdentifier(contentType: self.contentIdentifier.contentType,
                                                          contentRoute: nextPageRoute)

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: nextPageContentIdentifier)
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
                print("SportRadarEventsProvider: eventListBySportTypeDate - error on subscribe to topic")
                return
            }
            let subscription = Subscription(contentIdentifier: nextPageContentIdentifier,
                                            sessionToken: self.sessionToken,
                                               unsubscriber: self)
            self.subscription?.associateSubscription(subscription)
        }
        sessionDataTask.resume()

        return Just(true).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
    }

    func requestInitialPage() -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        let publisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

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
                print("SportRadarEventsProvider: eventListBySportTypeDate - error on subscribe to topic")
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

        self.eventsSubject = publisher

        return self.eventsSubject.eraseToAnyPublisher()
    }

    func updateEventsList(events: [Event]) {

        // If the number of recieved events is >= than eventsPerPage it means we can try request more
        self.hasNextPage = events.count >= self.eventsPerPage

        self.storage.events.append(contentsOf: events)

        let storedEvents = self.storage.events
        let storedEventsGroup = EventsGroup(events: storedEvents)
        self.eventsSubject.send(.contentUpdate(content: [storedEventsGroup]))
    }

    func eventsPublisher() ->AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        if case let .connected(subscription) = eventsSubject.value {
            return self.eventsSubject
                .prepend(.connected(subscription: subscription))
                .eraseToAnyPublisher()
        }
        else if case .contentUpdate(_) = eventsSubject.value {
            if let subscription = self.subscription {
                return self.eventsSubject
                    .prepend(.connected(subscription: subscription))
                    .eraseToAnyPublisher()
            }
            else {
                return self.eventsSubject.eraseToAnyPublisher()
            }
        }
        else {
            return self.eventsSubject.eraseToAnyPublisher()
        }
    }
}

extension SportRadarEventsPaginator: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("SportRadarEventsPaginator unsubscribe failed")
                return
            }
            print("SportRadarEventsPaginator unsubscribe ok")
        }
        sessionDataTask.resume()
    }

}
