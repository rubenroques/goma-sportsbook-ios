//
//  SportRadarEventsPaginator.swift
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

    weak var subscription: Subscription?
    var isActive: Bool {
        return self.subscription != nil
    }
    
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
    }

    //
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
                print("SportRadarEventsPaginator: requestInitialPage - error on subscribe to topic")
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
                print("SportRadarEventsPaginator: requestNextPage - error on subscribe to topic")
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

    func updateEventsList(events: [Event]) {
        // If the number of recieved events is >= than eventsPerPage it means we can try request more
        self.hasNextPage = events.count >= self.eventsPerPage

        self.storage.storeEvents(events)

        let storedEvents = self.storage.storedEvents()
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

    func reconnect(withNewSessionToken newSessionToken: String) {

        // Update the socket session token
        self.sessionToken = newSessionToken
        print("SportRadarEventsPaginator: reconnect withNewSessionToken \(newSessionToken)")

        guard let subscription = self.subscription else { return }

        // Reset the storage, we will recieve every info again
        self.storage.reset()

        // Include the self subscription in the array
        var allSubscriptions = [subscription]
        allSubscriptions.append(contentsOf: subscription.associatedSubscriptions)

        // Send the REST subscribe request again
        for subscription in allSubscriptions {

            let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                             contentIdentifier: subscription.contentIdentifier)

            guard let request = endpoint.request() else { continue }
            let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    print("SportRadarEventsPaginator: reconnect dataTask contentIdentifier \(subscription.contentIdentifier) error \(error)")
                }
                if let data, let dataString = String(data: data, encoding: .utf8) {
                    print("SportRadarEventsPaginator: reconnect dataTask contentIdentifier \(subscription.contentIdentifier) data \(dataString)")
                }
            }
            sessionDataTask.resume()

        }

    }

}

extension SportRadarEventsPaginator {

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

        case .addMarket(_ , let market):
            for outcome in market.outcomes {
                if let fractionOdd = outcome.odd.fractionOdd {
                    self.storage.updateOutcomeOdd(withId: outcome.id, newOddNumerator: String(fractionOdd.numerator), newOddDenominator: String(fractionOdd.denominator))
                }
            }
            self.storage.updateMarketTradability(withId: market.id, isTradable: market.isTradable)

        case .enableMarket(_, let marketId):
            self.storage.updateMarketTradability(withId: marketId, isTradable: true)
        case .removeMarket(_, let marketId):
            self.storage.updateMarketTradability(withId: marketId, isTradable: false)
        case .removeEvent(_, let eventId):
            self.storage.removedEvent(withId: eventId)

        default:
            () // Ignore other cases
        }
    }

}

extension SportRadarEventsPaginator {

    func subscribeToEventUpdates(withId id: String) -> AnyPublisher<Event, Never>? {
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
