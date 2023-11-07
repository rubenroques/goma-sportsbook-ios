//
//  SportRadarEventsPaginator.swift
//  
//
//  Created by Ruben Roques on 02/12/2022.
//

import Foundation
import Combine

class SportRadarEventsPaginator {

    let contentIdentifier: ContentIdentifier
    
    var eventsGroupPublisher: AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        if case let .connected(subscription) = eventsSubject.value {
            return self.eventsSubject
                .prepend(.connected(subscription: subscription))
                .print("SportRadarEventsPaginator eventsGroupPublisher prepend connected")
                .eraseToAnyPublisher()
        }
        else if case .contentUpdate(_) = eventsSubject.value {
            if let subscription = self.subscription {
                return self.eventsSubject
                    .prepend(.connected(subscription: subscription))
                    .print("SportRadarEventsPaginator eventsGroupPublisher prepend connected and contentUpdate")
                    .eraseToAnyPublisher()
            }
            else {
                return self.eventsSubject.eraseToAnyPublisher()
            }
        }
        else {
            return self.eventsSubject
                .print("SportRadarEventsPaginator eventsGroupPublisher disconnected")
                .eraseToAnyPublisher()
        }
    }
    
    var isActive: Bool {
        return self.subscription != nil
    }
    
    weak var subscription: Subscription?
    
    private var storage: SportRadarEventsStorage

    private var startPageIndex: Int = 0
    private var currentPage: Int

    private var hasNextPage: Bool = false {
        didSet {
            print("SportRadarEventsPaginator set hasNextPage: \(self.hasNextPage)")
        }
    }

    private var sessionToken: String

    private var eventsPerPage: Int

    private var eventsSubject: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>

    private var cancellables = Set<AnyCancellable>()

    init(contentIdentifier: ContentIdentifier, sessionToken: String, storage: SportRadarEventsStorage) {

        self.sessionToken = sessionToken
        self.storage = storage
        self.contentIdentifier = contentIdentifier

        self.eventsPerPage = self.contentIdentifier.contentRoute.eventCount ?? Int.max
        self.startPageIndex = 0
        self.currentPage = 0

        self.eventsSubject = .init(.disconnected)

        Publishers.CombineLatest(self.storage.eventsPublisher,
                                 self.eventsGroupPublisher.replaceError(with: .disconnected))
            .filter({ storedEvents, eventsGroupPublisher in
                switch eventsGroupPublisher {
                case .connected, .contentUpdate:
                    return true && (storedEvents != nil)
                case .disconnected:
                    return false
                }
            })
            .compactMap({ (newEvents: [Event]?, _)  in
                if let newEvents {
                    return EventsGroup(events: newEvents, marketGroupId: nil)
                }
                else {
                    return nil
                }
            })
            .sink { [weak self] (newEventsGroup: EventsGroup) in
                self?.eventsSubject.send(.contentUpdate(content: [newEventsGroup]))
            }
            .store(in: &self.cancellables)
        
        self.requestInitialPage()
            .retry(2)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.eventsSubject.send(.disconnected)
                    self?.eventsSubject.send(completion: .failure(error))
                }
            }, receiveValue: { [weak self] subscribableContent in
                self?.eventsSubject.send(subscribableContent)
                
                if case .connected(let subscription) = subscribableContent {
                    self?.subscription = subscription
                }
            })
            .store(in: &self.cancellables)
    }

    deinit {
        print("SportRadarEventsPaginator deinit \(self.contentIdentifier)")
    }
    
    //
    private func requestInitialPage() -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken, contentIdentifier: self.contentIdentifier)
        
        guard let request = endpoint.request() else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return Future<Subscription, ServiceProviderError> { promise in
            let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    error == nil,
                    let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode)
                else {
                    print("SportRadarEventsPaginator: requestInitialPage - error on subscribe to topic \(String(describing: dump(error))) \(String(describing: dump(response)))")
                    promise(.failure(ServiceProviderError.onSubscribe))
                    return
                }
                
                let subscription = Subscription(contentIdentifier: self.contentIdentifier,
                                                sessionToken: self.sessionToken,
                                                unsubscriber: self)
                promise(.success(subscription))
            }
            sessionDataTask.resume()
        }
        .map { subscription in
            return .connected(subscription: subscription)
        }
        .eraseToAnyPublisher()
    }

    // Return as boolean indicating if there is more pages
    func requestNextPage() -> AnyPublisher<Bool, ServiceProviderError> {

        print("SportRadarEventsPaginator requestNextPage")

        if !hasNextPage {
            print("SportRadarEventsPaginator requestNextPage hasNextPage: false")
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
        // If the number of received events is >= than eventsPerPage it means we can try request more
        self.hasNextPage = events.count >= self.eventsPerPage

        self.storage.storeEvents(events)
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

        guard
            let updatedContentIdentifier = content.contentIdentifier
        else {
            // print("☁️SP debugdetails SportRadarEventsPaginator ignoring contentIdentifierLess \(content)")
            return
        }

        if self.contentIdentifier.contentType == updatedContentIdentifier.contentType
            && self.contentIdentifier.contentRoute.pageableRoute == updatedContentIdentifier.contentRoute.pageableRoute {
            // It's a valid update for this paginator
        }
        else {
            // ignoring this update, not subscribed by this class
            // print("☁️SP debugdetails SportRadarEventsPaginator ignoring \(updatedContentIdentifier)")
            return
        }

        // print("☁️SP debugdetails SportRadarEventsPaginator handleContentUpdate \(content)")

        switch content {

        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)
        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            self.storage.updateOutcomeTradability(withId: selectionId, isTradable: isTradable)

        case .updateMarketTradability(_, let marketId, let isTradable):
            self.storage.updateMarketTradability(withId: marketId, isTradable: isTradable)

        //
        case .updateEventLiveDataExtended(_, let eventId, let eventLiveDataExtended):
            if let newTime = eventLiveDataExtended.matchTime {
                self.storage.updateEventTime(withId: eventId, newTime: newTime)
            }
            if let newStatus = eventLiveDataExtended.status {
                self.storage.updateEventStatus(withId: eventId, newStatus: newStatus.stringValue)
            }
            self.storage.updateEventScore(withId: eventId, newHomeScore: eventLiveDataExtended.homeScore, newAwayScore: eventLiveDataExtended.awayScore)

        case .updateEventState(_, let eventId, let newStatus):
            self.storage.updateEventStatus(withId: eventId, newStatus: newStatus)
        case .updateEventTime(_, let eventId, let newTime):
            self.storage.updateEventTime(withId: eventId, newTime: newTime)
        case .updateEventScore(_, let eventId, let homeScore, let awayScore):
            self.storage.updateEventScore(withId: eventId, newHomeScore: homeScore, newAwayScore: awayScore)

        //
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
        case .addEvent(_, let updatedEvent):
            let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: updatedEvent)
            self.storage.addEvent(withEvent: mappedEvent)
            
        default:
            () // Ignore other cases
        }
    }

}

extension SportRadarEventsPaginator {

    func subscribeToEventLiveDataUpdates(withId id: String) -> AnyPublisher<Event, Never>? {
        return self.storage.subscribeToEventLiveDataUpdates(withId: id)
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
