//
//  SportRadarEventsProvider.swift
//
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine
import OrderedCollections
import Extensions
import SharedModels

class SportRadarEventsProvider: EventsProvider {

    private var socketConnector: SportRadarSocketConnector
    private var restConnector: SportRadarRestConnector

    var sessionCoordinator: SportRadarSessionCoordinator

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connectionStateSubject.eraseToAnyPublisher()
    }
    private var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.disconnected)

    private var cancellables = Set<AnyCancellable>()

    required init(sessionCoordinator: SportRadarSessionCoordinator,
                  socketConnector: SportRadarSocketConnector = SportRadarSocketConnector(),
                  restConnector: SportRadarRestConnector = SportRadarRestConnector()) {
        self.sessionCoordinator = sessionCoordinator

        self.socketConnector = socketConnector
        self.restConnector = restConnector

        self.socketConnector.connectionStatePublisher.sink { completion in
            print("socketConnector connectionStatePublisher completed")
        } receiveValue: { [weak self] connectorState in
            self?.connectionStateSubject.send(connectorState)
        }
        .store(in: &self.cancellables)

        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if let launchTokenValue = launchToken  {
                    print("LAUCH TOKEN: \(launchTokenValue)")
                    self?.restConnector.saveSessionKey(launchTokenValue)
                }
                else {
                    self?.restConnector.clearSessionKey()
                }
            }
            .store(in: &self.cancellables)

        self.socketConnector.tokenPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .withPrevious()
            .sink(receiveValue: { [weak self] (oldToken, newToken) in

                self?.sessionCoordinator.saveToken(newToken.hash, withKey: .socketSessionToken)

                if let oldToken, oldToken != newToken {
                    print("ServiceProvider SportRadarSocketConnector: [\(oldToken)] -> [\(newToken)] Has reconnected")
                    self?.subscribePreviousTopics(withNewSocketToken: newToken.hash)
                }
                else {
                    print("ServiceProvider SportRadarSocketConnector: [\(newToken)] initial connection")
                }
            })
            .store(in: &self.cancellables)

        self.socketConnector.messageSubscriber = self
        self.socketConnector.connect()

    }

    private weak var liveSportsSubscription: Subscription?
    private weak var allSportTypesSubscription: Subscription?

    private var liveSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var allSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var allSportsListTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var eventsPaginators: [String: SportRadarEventsPaginator] = [:]
    private var eventDetailsCoordinators: [String: SportRadarEventDetailsCoordinator] = [:]
    private var marketUpdatesCoordinators: [String: SportRadarMarketDetailsCoordinator] = [:]

    private var competitionEventsPublisher: [ContentIdentifier: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>] = [:]
    private var outrightDetailsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var eventSummaryPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var eventLiveDataPublisher: CurrentValueSubject<SubscribableContent<[Event]>, ServiceProviderError>?

    //
    // Keep a reference for all the subscriptions. This allows the ServiceProvider to subscribe to the same content in two different app places
    private var activeSubscriptions: NSMapTable<ContentIdentifier, Subscription> = .init(keyOptions: .strongMemory , valueOptions: .weakMemory)

    private let defaultEventCount = 10

    func reconnectIfNeeded() {
        self.socketConnector.refreshConnection()
    }

    func subscribePreviousTopics(withNewSocketToken newSocketToken: String) {
        self.eventsPaginators = self.eventsPaginators.filter { $0.value.isActive }
        for paginator in self.eventsPaginators.values where paginator.isActive {
            paginator.reconnect(withNewSessionToken: newSocketToken)
        }

        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            eventDetailsCoordinator.reconnect(withNewSessionToken: newSocketToken)
        }

        self.marketUpdatesCoordinators = self.marketUpdatesCoordinators.filter { $0.value.isActive }
        for marketUpdatesCoordinator in self.marketUpdatesCoordinators.values {
            marketUpdatesCoordinator.reconnect(withNewSessionToken: newSocketToken)
        }
    }

    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date? = nil, endDate: Date? = nil, eventCount: Int? = nil, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        // Get the session
        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        guard
            let sportId = sportType.alphaId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        let eventCountValue = eventCount ?? self.defaultEventCount

        // contentType -> eventListBySportTypeDate
        let contentType = ContentType.preLiveEvents
        // contentId -> FBL/202210210000/202210212359/0/20/T
        let contentRoute = ContentRoute.preLiveEvents(sportAlphaId: sportId,
                                                      startDate: initialDate,
                                                      endDate: endDate,
                                                      pageIndex: 0,
                                                      eventCount: eventCountValue,
                                                      sortType: sortType)

        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let paginator = self.eventsPaginators[contentIdentifier.pageableId], paginator.isActive {
            return paginator.eventsPublisher()
        }
        else {
            let paginator = SportRadarEventsPaginator(contentIdentifier: contentIdentifier,
                                                      sessionToken: sessionToken.hash,
                                                      storage: SportRadarEventsStorage())
            self.eventsPaginators[contentIdentifier.pageableId] = paginator

            return paginator.requestInitialPage()
        }
    }

    func requestPreLiveMatchesNextPage(forSportType sportType: SportType, initialDate: Date? = nil, endDate: Date? = nil, sortType: EventListSort) -> AnyPublisher<Bool, ServiceProviderError> {
        // Get the session
        guard
            socketConnector.token != nil
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        guard
            let sportId = sportType.alphaId
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }
        // contentType -> eventListBySportTypeDate
        let contentType = ContentType.preLiveEvents

        // contentId -> FBL/202210210000/202210212359/0/20/T
        let contentRoute = ContentRoute.preLiveEvents(sportAlphaId: sportId,
                                                      startDate: initialDate,
                                                      endDate: endDate,
                                                      pageIndex: 0,
                                                      eventCount: self.defaultEventCount,
                                                      sortType: sortType)

        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let paginator = self.eventsPaginators[contentIdentifier.pageableId], paginator.isActive {
            return paginator.requestNextPage().eraseToAnyPublisher()
        }
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.subscriptionNotFound).eraseToAnyPublisher()
        }
    }

    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        // Get the session
        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        guard
            let sportId = sportType.alphaId
        else {
            return Fail(error: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        // contentType -> liveDataSummaryAdvancedListBySportType
        let contentType = ContentType.liveEvents
        // contentId -> FBL/0 -> /0 means page 0 of pagination
        let contentRoute = ContentRoute.liveEvents(sportAlphaId: sportId, pageIndex: 0)

        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let paginator = self.eventsPaginators[contentIdentifier.pageableId], paginator.isActive {
            return paginator.eventsPublisher()
        }
        else {
            let paginator = SportRadarEventsPaginator(contentIdentifier: contentIdentifier,
                                                      sessionToken: sessionToken.hash,
                                                      storage: SportRadarEventsStorage())
            self.eventsPaginators[contentIdentifier.pageableId] = paginator
            return paginator.requestInitialPage()
        }

    }

    func requestLiveMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        // Get the session
        guard
            socketConnector.token != nil
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        guard
            let sportId = sportType.alphaId
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.incompletedSportData).eraseToAnyPublisher()
        }

        // contentType -> liveDataSummaryAdvancedListBySportType
        let contentType = ContentType.liveEvents
        // contentId -> FBL/0 -> /0 means page 0 of pagination
        let contentRoute = ContentRoute.liveEvents(sportAlphaId: sportId, pageIndex: 0)
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let paginator = self.eventsPaginators[contentIdentifier.pageableId] {
            return paginator.requestNextPage().eraseToAnyPublisher()
        }
        else {
            return Fail(outputType: Bool.self, failure: ServiceProviderError.subscriptionNotFound).eraseToAnyPublisher()
        }
    }

    //
    // MARK: - Competition and Match Details
    //
    func subscribeCompetitionMatches(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        // Get the session
        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        // Create the contentIdentifier
        let contentType = ContentType.eventGroup
        let contentRoute = ContentRoute.eventGroup(marketGroupId: marketGroupId)
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let publisher = self.competitionEventsPublisher[contentIdentifier],
           let subscription = self.activeSubscriptions.object(forKey: contentIdentifier) {
            // We already have a publisher for this events and a subscription object for the caller to store
            return publisher
                .prepend(.connected(subscription: subscription))
                .eraseToAnyPublisher()
        }
        else {
            // We have neither a publisher nor a subscription object
            let publisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

            let subscription = Subscription(contentIdentifier: contentIdentifier, sessionToken: sessionToken.hash, unsubscriber: self)

            let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentRoute: contentRoute)
            let request = self.createSubscribeRequest(withHTTPBody: bodyData)

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
                publisher.send(.connected(subscription: subscription))
            }
            sessionDataTask.resume()

            self.activeSubscriptions.setObject(subscription, forKey: contentIdentifier)
            self.competitionEventsPublisher[contentIdentifier] = publisher

            return publisher.eraseToAnyPublisher()
        }
    }

    func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {

        guard
            let sessionToken = self.socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = ContentType.liveSports
        let contentRoute = ContentRoute.liveSports
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        let liveSportsSubscription = self.liveSportsSubscription ?? Subscription(contentIdentifier: contentIdentifier, sessionToken: sessionToken.hash, unsubscriber: self)
        self.liveSportsSubscription = liveSportsSubscription

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: sessionToken.hash, contentIdentifier: contentIdentifier)

        if let liveSportTypesPublisher = self.liveSportTypesPublisher {
            if case let .connected(liveSportsSubscription) = liveSportTypesPublisher.value {
                return liveSportTypesPublisher
                    .prepend(.connected(subscription: liveSportsSubscription))
                    .eraseToAnyPublisher()
            }
            else if case .contentUpdate(_) = liveSportTypesPublisher.value {
                return liveSportTypesPublisher
                    .prepend(.connected(subscription: liveSportsSubscription))
                    .eraseToAnyPublisher()
            }
            else {
                return liveSportTypesPublisher.eraseToAnyPublisher()
            }
        }
        else {
            self.liveSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
        }

        guard
            let publisher = self.liveSportTypesPublisher,
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider subscribeLiveSportTypes \(error) \(response)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            publisher.send(.connected(subscription: liveSportsSubscription))
        }

        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

    func subscribeAllSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {

        guard
            let sessionToken = self.socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = ContentType.allSports
        let contentRoute = ContentRoute.allSports
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        let allSportsSubscription = self.allSportTypesSubscription ?? Subscription(contentIdentifier: contentIdentifier, sessionToken: sessionToken.hash, unsubscriber: self)
        self.allSportTypesSubscription = allSportsSubscription

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: sessionToken.hash, contentIdentifier: contentIdentifier)

        if let allSportsListTypesPublisher = self.allSportsListTypesPublisher {
            if case let .connected(allSportsSubscription) = allSportsListTypesPublisher.value {
                return allSportsListTypesPublisher
                    .prepend(.connected(subscription: allSportsSubscription))
                    .eraseToAnyPublisher()
            }
            else if case .contentUpdate(_) = allSportsListTypesPublisher.value {
                return allSportsListTypesPublisher
                    .prepend(.connected(subscription: allSportsSubscription))
                    .eraseToAnyPublisher()
            }
            else {
                return allSportsListTypesPublisher.eraseToAnyPublisher()
            }
        }
        else {
            self.allSportsListTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
        }

        guard
            let publisher = self.allSportsListTypesPublisher,
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider subscribeAllSportTypes \(error) \(response)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            publisher.send(.connected(subscription: allSportsSubscription))
        }

        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

    func subscribePreLiveSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        if self.allSportTypesPublisher == nil {
            self.allSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
        }

        guard
            let sessionToken = socketConnector.token,
            let publisher = self.allSportTypesPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = ContentType.preLiveSports
        let contentRoute = ContentRoute.preLiveSports(startDate: initialDate, endDate: endDate)
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        let preLiveSportsSubscription = Subscription(contentIdentifier: contentIdentifier, sessionToken: sessionToken.hash, unsubscriber: self)

        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: sessionToken.hash, contentIdentifier: contentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in

            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider subscribePreLiveSportTypes \(error) \(response)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            // TODO: send subscription
            publisher.send(.connected(subscription: preLiveSportsSubscription))
        }

        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

    func subscribeEventDetails(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {

        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        if let eventDetailsCoordinator = self.getValidEventDetailsCoordinator(forKey: eventId) {
            return eventDetailsCoordinator.eventDetailsPublisher
        }
        else {
            let eventDetailsCoordinator = SportRadarEventDetailsCoordinator(matchId: eventId,
                                                                            sessionToken: sessionToken.hash,
                                                                            storage: SportRadarEventDetailsStorage())
            self.addEventDetailsCoordinator(eventDetailsCoordinator, withKey: eventId)
            return eventDetailsCoordinator.eventDetailsPublisher
        }
    }

    func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        //self.outrightDetailsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
            let sessionToken = socketConnector.token
                //let publisher = self.outrightDetailsPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = ContentType.eventGroup
        let contentRoute = ContentRoute.eventGroup(marketGroupId: marketGroupId)
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let publisher = self.competitionEventsPublisher[contentIdentifier], let subscription = self.activeSubscriptions.object(forKey: contentIdentifier) {
            // We already have a publisher for this events and a subscription object for the caller to store
            return publisher
                .prepend(.connected(subscription: subscription))
                .eraseToAnyPublisher()
        }
        else {
            // We have neither a publisher nor a subscription object
            let publisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

            let subscription = Subscription(contentIdentifier: contentIdentifier, sessionToken: sessionToken.hash, unsubscriber: self)

            let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentRoute: contentRoute)
            let request = self.createSubscribeRequest(withHTTPBody: bodyData)

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
                publisher.send(.connected(subscription: subscription))
            }
            sessionDataTask.resume()

            self.activeSubscriptions.setObject(subscription, forKey: contentIdentifier)
            self.competitionEventsPublisher[contentIdentifier] = publisher

            return publisher.eraseToAnyPublisher()
        }

    }

    func subscribeEventSummary(eventId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        self.eventSummaryPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
            let sessionToken = socketConnector.token,
            let publisher = self.eventSummaryPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = ContentType.eventSummary
        let contentRoute = ContentRoute.eventSummary(eventId: eventId)
        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        let subscription = Subscription(contentIdentifier: contentIdentifier, sessionToken: sessionToken.hash, unsubscriber: self)

        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentRoute: contentRoute)
        let request = self.createSubscribeRequest(withHTTPBody: bodyData)

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider subscribeEventSummary \(error) \(response)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            // TODO: send subscription
            publisher.send(.connected(subscription: subscription))
        }
        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

    //
    // MARK: - Subcribable Updates
    //
    public func subscribeToEventLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError> {

        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        // events lists
        for paginator in self.eventsPaginators.values {
            if paginator.containsEvent(withid: id), let publisher = paginator.subscribeToEventLiveDataUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // event details
        if let eventDetailsCoordinator = self.getValidEventDetailsCoordinator(forKey: id),
           eventDetailsCoordinator.containsEvent(withid: id) {

            let publisher = eventDetailsCoordinator.subscribeToEventLiveDataUpdates(withId: id)
            return publisher.setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }
        else {
            let eventDetailsCoordinator = SportRadarEventDetailsCoordinator(matchId: id,
                                                                             sessionToken: sessionToken.hash,
                                                                             storage: SportRadarEventDetailsStorage())

            self.addEventDetailsCoordinator(eventDetailsCoordinator, withKey: id)

            let publisher = eventDetailsCoordinator.subscribeToEventLiveDataUpdates(withId: id)
            return publisher.setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        }

    }

    public func subscribeToEventMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {

        // event details
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            if eventDetailsCoordinator.containsMarket(withid: id),
               let publisher = eventDetailsCoordinator.subscribeToEventMarketUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // events lists
        for paginator in self.eventsPaginators.values {
            if paginator.containsMarket(withid: id), let publisher = paginator.subscribeToEventMarketUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        return Just(nil).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
    }

    public func subscribeToEventOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {

        // event details
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            if eventDetailsCoordinator.containsOutcome(withid: id),
               let publisher = eventDetailsCoordinator.subscribeToEventOutcomeUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // events lists
        for paginator in self.eventsPaginators.values {
            if paginator.containsOutcome(withid: id), let publisher = paginator.subscribeToEventOutcomeUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        return Just(nil).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
    }


    public func subscribeToMarketDetails(withId marketId: String, onEventId eventId: String) -> AnyPublisher<SubscribableContent<Market>, ServiceProviderError> {

        // Get the session
        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        // contentType -> liveDataSummaryAdvancedListBySportType
        let contentType = ContentType.market
        // contentId -> FBL/0 -> /0 means page 0 of pagination
        let contentRoute = ContentRoute.market(marketId: marketId)

        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let coordinators = self.marketUpdatesCoordinators[marketId], coordinators.isActive {
            return coordinators.marketPublisher
        }
        else {
            let coordinator = SportRadarMarketDetailsCoordinator.init(marketId: marketId,
                                                                      eventId: eventId,
                                                                      sessionToken: sessionToken.hash,
                                                                      contentIdentifier: contentIdentifier)
            self.marketUpdatesCoordinators[marketId] = coordinator
            return coordinator.marketPublisher
        }

    }

}

//
// MARK: - Socket event delegate
//
extension SportRadarEventsProvider: SportRadarConnectorSubscriber {

    func liveEventsUpdated(forContentIdentifier identifier: ContentIdentifier, withEvents events: [EventsGroup]) {
        if let eventPaginator = self.eventsPaginators[identifier.pageableId] {
            let flattenedEvents = events.flatMap({ $0.events })
            eventPaginator.updateEventsList(events: flattenedEvents)
        }
    }

    func preLiveEventsUpdated(forContentIdentifier identifier: ContentIdentifier, withEvents events: [EventsGroup]) {
        if let eventPaginator = self.eventsPaginators[identifier.pageableId] {
            let flattenedEvents = events.flatMap({ $0.events })
            eventPaginator.updateEventsList(events: flattenedEvents)
        }
    }

    func liveSportsUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        if let liveSportTypesPublisher = self.liveSportTypesPublisher {

            let externalSports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))

            // Navigation Sports
            let sportsEndpoint = SportRadarRestAPIClient.sportsBoNavigationList
            let sportsRequestPublisher: AnyPublisher<SportRadarModels.RestResponse<SportRadarModels.SportsList>, ServiceProviderError> = self.restConnector.request(sportsEndpoint)
            sportsRequestPublisher
                .sink { _ in

                } receiveValue: { numericSports in
                    var compleatedExternalSportTypes = [SportType]()
                    let newNumericSports = (numericSports.data?.sportNodes ?? []).map(SportRadarModelMapper.sportType(fromSportNode:))
                    for externalSport in externalSports {
                        var numericSportId: String?
                        for numericSport in newNumericSports { // Try to find a numeric Id from the boNavigationList of sports
                            if externalSport.name.lowercased() == numericSport.name.lowercased() {
                                numericSportId = numericSport.numericId
                            }
                        }
                        let compleatedExternalSportType = SportType(name: externalSport.name,
                                  numericId: numericSportId,
                                  alphaId: externalSport.alphaId,
                                  iconId: externalSport.iconId,
                                  showEventCategory: externalSport.showEventCategory,
                                  numberEvents: externalSport.numberEvents,
                                  numberOutrightEvents: externalSport.numberOutrightEvents,
                                  numberOutrightMarkets: externalSport.numberOutrightMarkets,
                                                                    numberLiveEvents: externalSport.numberLiveEvents)

                        compleatedExternalSportTypes.append(compleatedExternalSportType)
                    }
                    liveSportTypesPublisher.send(.contentUpdate(content: compleatedExternalSportTypes))
                }
                .store(in: &self.cancellables)

        }
    }

    func preLiveSportsUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        if let allSportTypesPublisher = self.allSportTypesPublisher {
            let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
            allSportTypesPublisher.send(.contentUpdate(content: sports))
        }
    }

    func allSportsUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {

        if let allSportsListTypesPublisher = self.allSportsListTypesPublisher {
            let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
            allSportsListTypesPublisher.send(.contentUpdate(content: sports))
        }
    }

    func updateSportLiveCount(nodeId: String, liveCount: Int) {
        if let allSportsListTypesPublisher = self.allSportsListTypesPublisher {
            let content = allSportsListTypesPublisher.value
            switch content {
            case .contentUpdate(let content):
                var sportTypes = content

                if let sportIndex = sportTypes.firstIndex(where: {$0.numericId == nodeId}) {
                    sportTypes[sportIndex].numberLiveEvents = liveCount

                    allSportsListTypesPublisher.send(.contentUpdate(content: sportTypes))
                }
            default:
                ()
            }
        }
    }

    func updateSportEventCount(nodeId: String, eventCount: Int) {
        if let allSportsListTypesPublisher = self.allSportsListTypesPublisher {
            let content = allSportsListTypesPublisher.value
            switch content {
            case .contentUpdate(let content):
                var sportTypes = content

                if let sportIndex = sportTypes.firstIndex(where: {$0.numericId == nodeId}) {
                    sportTypes[sportIndex].numberEvents = eventCount

                    allSportsListTypesPublisher.send(.contentUpdate(content: sportTypes))
                }
            default:
                ()
            }
        }
    }

    func eventDetailsUpdated(forContentIdentifier identifier: ContentIdentifier, event: Event) {
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            eventDetailsCoordinator.updateEventDetails(event, forContentIdentifier: identifier)
        }
    }

    // Competition events
    func eventGroups(forContentIdentifier identifier: ContentIdentifier, withEvents events: [EventsGroup]) {
        if let publisher = self.competitionEventsPublisher[identifier] {
            publisher.send(.contentUpdate(content: events))
        }
    }

    func outrightEventGroups(events: [EventsGroup]) {
        if let publisher = self.outrightDetailsPublisher {
            publisher.send(.contentUpdate(content: events))
        }
    }

    func marketDetails(forContentIdentifier identifier: ContentIdentifier, market: Market) {
        if let marketUpdatesCoordinator = marketUpdatesCoordinators[market.id] {
            marketUpdatesCoordinator.updateMarket(market)
        }
    }

    func eventDetailsLiveData(contentIdentifier: ContentIdentifier, eventLiveDataExtended: SportRadarModels.EventLiveDataExtended) {
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            eventDetailsCoordinator.updatedLiveData(eventLiveDataExtended: eventLiveDataExtended, forContentIdentifier: contentIdentifier)
        }
    }

    func didReceiveGenericUpdate(content: SportRadarModels.ContentContainer) {
        if let contentIdentifier = content.contentIdentifier,
           let contentIdentifierPaginator = self.eventsPaginators[contentIdentifier.pageableId] {
            contentIdentifierPaginator.handleContentUpdate(content)
        }

        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            eventDetailsCoordinator.handleContentUpdate(content)
        }

        for marketUpdatesCoordinator in self.marketUpdatesCoordinators.values {
            marketUpdatesCoordinator.handleContentUpdate(content)
        }
    }

}

//
// MARK: - Competition and Match Details
//
extension SportRadarEventsProvider {

    func getMarketsFilters(event: Event) -> AnyPublisher<[MarketGroup], Never> {

        let defaultMarketGroups = [MarketGroup.init(type: "0",
                                                    id: "0",
                                                    groupKey: "All Markets",
                                                    translatedName: "All Markets",
                                                    position: 0,
                                                    isDefault: true,
                                                    numberOfMarkets: nil,
                                                    markets: event.markets)]

        let endpoint = SportRadarRestAPIClient.marketsFilter
        let requestPublisher: AnyPublisher<MarketFilter, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.flatMap({ marketFilters -> AnyPublisher<[MarketGroup], ServiceProviderError> in
            let marketGroups = self.processMarketFilters(marketFilter: marketFilters, match: event)
            return Just(marketGroups).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
        })
        .replaceError(with: defaultMarketGroups)
        .eraseToAnyPublisher()

    }

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.fieldWidgetId(eventId: eventId)
        let requestPublisher: AnyPublisher<FieldWidget, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher
    }

    func getFieldWidget(eventId: String, isDarkTheme: Bool? = nil) -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError> {

        var fieldWidgetFile = "field_widget_light.html"

        if isDarkTheme ?? true {
            fieldWidgetFile = "field_widget_dark.html"
        }

        return self.getFieldWidgetId(eventId: eventId).flatMap({ fieldWidget -> AnyPublisher<FieldWidgetRenderDataType, ServiceProviderError> in

            let fileStringSplit = fieldWidgetFile.components(separatedBy: ".")

            let filePath = Bundle.main.path(forResource: fileStringSplit[0], ofType: fileStringSplit[1])
            let contentData = FileManager.default.contents(atPath: filePath!)
            let emailTemplate = NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String
            if let fieldWidgetId = fieldWidget.data,
               let replacedHtmlContent = emailTemplate?.replacingOccurrences(of: "@eventId", with: fieldWidgetId),
               let bundleUrl = Bundle.main.url(forResource: fileStringSplit[0], withExtension: fileStringSplit[1]) {
                // let fieldWidgetRenderData = FieldWidgetRenderData(url: bundleUrl, htmlString: replacedHtmlContent)
                let fieldWidgetRenderDataType = FieldWidgetRenderDataType.htmlString(url: bundleUrl, htmlString: replacedHtmlContent)
                return Just(fieldWidgetRenderDataType).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: FieldWidgetRenderDataType.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()

        })
        .eraseToAnyPublisher()

    }

    func getAvailableSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<[SportType], ServiceProviderError> {

        // Navigation Sports
        let sportsEndpoint = SportRadarRestAPIClient.sportsBoNavigationList
        let sportsRequestPublisher: AnyPublisher<SportRadarModels.RestResponse<SportRadarModels.SportsList>, ServiceProviderError> = self.restConnector.request(sportsEndpoint)

        // Code Sports
//        let dateRange = ContentDateFormatter.getDateRangeId(startDate: initialDate, endDate: endDate)
//        let codeSportsEndpoint = SportRadarRestAPIClient.sportsScheduledList(dateRange: dateRange)
//
//        let codeSportsRequestPublisher: AnyPublisher<SportRadarModels.RestResponse<[SportRadarModels.ScheduledSport]>, ServiceProviderError> = self.restConnector.request(codeSportsEndpoint)

//        return Publishers.CombineLatest(sportsRequestPublisher, codeSportsRequestPublisher)
//            .flatMap({ numericSportsList, alphaSportsList -> AnyPublisher<[SportType], ServiceProviderError> in
//                if
//                    let numericSports = numericSportsList.data?.sportNodes?.filter({
//                        $0.numberEvents > 0 || $0.numberOutrightEvents > 0 //|| $0.numberOutrightMarkets > 0
//                    }),
//                    let alphaSports = alphaSportsList.data
//                {
//                    let newNumericSports = numericSports.map(SportRadarModelMapper.sportType(fromSportNode:))
//                    let newAlphaSports = alphaSports.map(SportRadarModelMapper.sportType(fromScheduledSport:))
//                    let unifiedSportsList = self.mergeSports(numericSportArray: newNumericSports, alphaSportArray: newAlphaSports)
//                    let sportTypes = unifiedSportsList.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
//                    return Just(sportTypes).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
//                }
//                return Fail(outputType: [SportType].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
//            })
//            .eraseToAnyPublisher()

        return sportsRequestPublisher.flatMap({ numericSportsList -> AnyPublisher<[SportType], ServiceProviderError> in
            if
                let numericSports = numericSportsList.data?.sportNodes?.filter({
                    $0.numberEvents > 0 || $0.numberOutrightEvents > 0 || $0.numberLiveEvents > 0
                }) {

                let mappedNumericSports = numericSports.map(SportRadarModelMapper.sportType(fromSportNode:))

                let sportTypes = mappedNumericSports.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))

                return Just(sportTypes).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
            return Fail(outputType: [SportType].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }

    func getSportRegions(sportId: String) -> AnyPublisher<SportNodeInfo, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.sportRegionsNavigationList(sportId: sportId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.SportNodeInfo>, ServiceProviderError> = self.restConnector.request(endpoint)


        return requestPublisher.map( { sportRadarResponse -> SportNodeInfo in
            let sportNodeInfo = sportRadarResponse.data
            let mappedSportNodeInfo = SportRadarModelMapper.sportNodeInfo(fromInternalSportNodeInfo:sportNodeInfo)

            let filteredRegionNode = mappedSportNodeInfo.regionNodes.filter({
                $0.numberEvents != "0" || $0.numberOutrightEvents != "0"
            })

            let filteredSportNodeInfo = SportNodeInfo(id: mappedSportNodeInfo.id, regionNodes: filteredRegionNode)

            return filteredSportNodeInfo

        }).eraseToAnyPublisher()

    }

    func getRegionCompetitions(regionId: String) -> AnyPublisher<SportRegionInfo, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.regionCompetitions(regionId: regionId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.SportRegionInfo>, ServiceProviderError> = self.restConnector.request(endpoint)


        return requestPublisher.map( { sportRadarResponse -> SportRegionInfo in
            let sportRegionInfo = sportRadarResponse.data
            let mappedSportRegionInfo = SportRadarModelMapper.sportRegionInfo(fromInternalSportRegionInfo: sportRegionInfo)

            let filteredCompetitionNodes = mappedSportRegionInfo.competitionNodes.filter({
                $0.numberEvents != "0" || $0.numberOutrightEvents != "0"
            })

            let filteredSportRegionInfo = SportRegionInfo(id: mappedSportRegionInfo.id, name: mappedSportRegionInfo.name, competitionNodes: filteredCompetitionNodes)

            return filteredSportRegionInfo

        }).eraseToAnyPublisher()

    }

    func getCompetitionMarketGroups(competitionId: String) -> AnyPublisher<SportCompetitionInfo, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.competitionMarketGroups(competitionId: competitionId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.SportCompetitionInfo>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> SportCompetitionInfo in
            let sportCompetitionInfo = sportRadarResponse.data
            let mappedSportCompetitionInfo = SportRadarModelMapper.sportCompetitionInfo(fromInternalSportCompetitionInfo: sportCompetitionInfo)
            return mappedSportCompetitionInfo
        })
        .eraseToAnyPublisher()
    }

    func getSearchEvents(query: String, resultLimit: String, page: String, isLive: Bool = false) -> AnyPublisher<EventsGroup, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.search(query: query, resultLimit: resultLimit, page: page, isLive: isLive)

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<[SportRadarModels.Event]>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> EventsGroup in
            let events = sportRadarResponse.data
            let mappedEventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEvents: events)

            let filteredEvents = mappedEventsGroup.events.filter({
                $0.id != "_TOKEN_"
            })

            let filteredEventsGroup = EventsGroup(events: filteredEvents, marketGroupId: mappedEventsGroup.marketGroupId)

            return filteredEventsGroup
        })
        .eraseToAnyPublisher()

    }

    func getHomeSliders() -> AnyPublisher<BannerResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.homeSliders

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.BannerResponse>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> BannerResponse in
            let bannersResponse = sportRadarResponse.data
            let mappedBannersResponse = SportRadarModelMapper.bannerResponse(fromInternalBannerResponse: bannersResponse)
            //            let mappedEventsGroup = SportRadarModelMapper.events(fromInternalEvents: events)

            return mappedBannersResponse
        })
        .eraseToAnyPublisher()

    }

    public func getPromotionalTopBanners() -> AnyPublisher<[PromotionalBanner], ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.promotionalTopBanners
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<[SportRadarModels.PromotionalBannersResponse]>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> [PromotionalBanner] in
            let promotionalBannersResponse = sportRadarResponse.data.flatMap({ $0.promotionalBannerItems })
            let mappedBannersResponse: [PromotionalBanner] = promotionalBannersResponse.map(SportRadarModelMapper.promotionalBanner(fromInternalPromotionalBanner:))
            return mappedBannersResponse
        })
        .eraseToAnyPublisher()
    }

    public func getPromotionalSlidingTopEvents() -> AnyPublisher<[Event], ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.promotionalTopEvents
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.HeadlineResponse>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher
            .map(\.data)
            .flatMap({ headlineResponse -> AnyPublisher<[Event], ServiceProviderError> in

                let headlineItems = headlineResponse.headlineItems ?? []
                var headlineItemsImages: [String: String] = [:]
                headlineItems.forEach({ item in
                    if let id = item.marketId, let imageURL = item.imageURL {
                        headlineItemsImages[id] = imageURL
                    }
                })
                let marketIds = headlineItems.map({ item in return item.marketId }).compactMap({ $0 })

                let publishers = marketIds.map(self.getEventForMarket(withId:))
                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> [Event] in
                        return events.compactMap({ $0 })
                    })
                    .map({ events -> [Event] in // Configure the image of each market
                        for event in events {
                            let firstMarketId = event.markets.first?.id ?? ""
                            event.promoImageURL =  headlineItemsImages[firstMarketId]
                        }

                        let cleanedEvents = events.compactMap({ $0 })

                        // create a dictionary from cleanedEvents using marketId as a key
                        var eventDict: [String: Event] = [:] // Dictionary(uniqueKeysWithValues: cleanedEvents.map { ($0.markets.first?.id ?? "", $0) })
                        cleanedEvents.forEach({ event in
                            let firstMarketId = event.markets.first?.id ?? ""
                            eventDict[firstMarketId] = event
                        })
                        
                        // re-order the cleanedEvents based on the order of marketIds in headlineItems
                        let orderedEvents = headlineItems.compactMap { eventDict[$0.marketId ?? ""] }
                        return orderedEvents
                    })
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getHighlightedBoostedEvents() -> AnyPublisher<[Event], ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.highlightsBoostedOddsEvents
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.HeadlineResponse>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher
            .map(\.data)
            .flatMap({ headlineResponse -> AnyPublisher<[Event], ServiceProviderError> in

                let headlineItems = headlineResponse.headlineItems ?? []
                var headlineItemsOldMarkets: [String: String] = [:]
                headlineItems.forEach({ item in
                    if let id = item.marketId, let oldMarketId = item.oldMarketId {
                        headlineItemsOldMarkets[id] = oldMarketId
                    }
                })

                let marketIds = headlineItems.map({ item in return item.marketId }).compactMap({ $0 })

                let publishers = marketIds.map(self.getEventForMarket(withId:))
                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> [Event] in
                        return events.compactMap({ $0 })
                    })
                    .map({ (events: [Event]) -> [Event] in

                        for event in events {
                            let firstMarketId = event.markets.first?.id ?? ""
                            event.oldMainMarketId =  headlineItemsOldMarkets[firstMarketId]
                        }

                        let cleanedEvents = events.compactMap({ $0 })

                        // create a dictionary from cleanedEvents using marketId as a key
                        var eventDict: [String: Event] = [:] // Dictionary(uniqueKeysWithValues: cleanedEvents.map { ($0.markets.first?.id ?? "", $0) })
                        cleanedEvents.forEach({ event in
                            let firstMarketId = event.markets.first?.id ?? ""
                            eventDict[firstMarketId] = event
                        })

                        // re-order the cleanedEvents based on the order of marketIds in headlineItems
                        let orderedEvents = headlineItems.compactMap { eventDict[$0.marketId ?? ""] }
                        return orderedEvents
                    })

                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    func getHighlightedVisualImageEvents() -> AnyPublisher<[Event], ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.highlightsImageVisualEvents
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.HeadlineResponse>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher
            .map(\.data)
            .flatMap({ headlineResponse -> AnyPublisher<[Event], ServiceProviderError> in

                let headlineItems = headlineResponse.headlineItems ?? []
                var headlineItemsImages: [String: String] = [:]
                headlineItems.forEach({ item in
                    if let id = item.marketId, let imageURL = item.imageURL {
                        headlineItemsImages[id] = imageURL
                    }
                })
                let marketIds = headlineItems.map({ item in return item.marketId }).compactMap({ $0 })

                let publishers = marketIds.map(self.getEventForMarket(withId:))
                let finalPublisher = Publishers.MergeMany(publishers)
                    .collect()
                    .map({ (events: [Event?]) -> [Event] in
                        return events.compactMap({ $0 })
                    })
                    .map({ events -> [Event] in // Configure the image of each market
                        for event in events {
                            let firstMarketId = event.markets.first?.id ?? ""
                            event.promoImageURL =  headlineItemsImages[firstMarketId]
                        }

                        let cleanedEvents = events.compactMap({ $0 })

                        // create a dictionary from cleanedEvents using marketId as a key
                        var eventDict: [String: Event] = [:] // Dictionary(uniqueKeysWithValues: cleanedEvents.map { ($0.markets.first?.id ?? "", $0) })
                        cleanedEvents.forEach({ event in
                            let firstMarketId = event.markets.first?.id ?? ""
                            eventDict[firstMarketId] = event
                        })

                        // re-order the cleanedEvents based on the order of marketIds in headlineItems
                        let orderedEvents = headlineItems.compactMap { eventDict[$0.marketId ?? ""] }
                        return orderedEvents
                    })
                    .eraseToAnyPublisher()

                return finalPublisher
                    .setFailureType(to: ServiceProviderError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }


    public func getPromotionalTopStories() -> AnyPublisher<[PromotionalStory], ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.promotionalTopStories

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.PromotionalStoriesResponse>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> [PromotionalStory] in

            let promotionalStoriesResponse = sportRadarResponse.data

            let mappedPromotionalStoriesResponse = SportRadarModelMapper.promotionalStoriesResponse(fromInternalPromotionalStoriesResponse: promotionalStoriesResponse)

            let mappedPromotionalStories = mappedPromotionalStoriesResponse.promotionalStories

            return mappedPromotionalStories
        })
        .eraseToAnyPublisher()
    }


    public func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.promotedSports
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.PromotedSportsResponse>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> [PromotedSport] in
            let promotedSports = sportRadarResponse.data.promotedSports
            let mappedPromotedSports = promotedSports.map(SportRadarModelMapper.promotedSport(fromInternalPromotedSport:))
            return mappedPromotedSports
        })
        .eraseToAnyPublisher()
    }

    func getCashbackSuccessBanner() -> AnyPublisher<BannerResponse, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getCashbackSuccessBanner
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.BannerResponse>, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher.map( { sportRadarResponse -> BannerResponse in
            let bannersResponse = sportRadarResponse.data
            let mappedBannersResponse = SportRadarModelMapper.bannerResponse(fromInternalBannerResponse: bannersResponse)
            return mappedBannersResponse
        })
        .eraseToAnyPublisher()

    }

    func getTopCompetitionsPointers() -> AnyPublisher<[TopCompetitionPointer], ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getTopCompetitions
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<[SportRadarModels.TopCompetitionData]>, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher.map( { sportRadarResponse -> [TopCompetitionPointer] in
            let topCompetitions = sportRadarResponse.data.flatMap({
                $0.competitions
            })
            let mappedTopCompetitions = topCompetitions.map(SportRadarModelMapper.topCompetitionPointer(fromInternalTopCompetitionPointer:))
            return mappedTopCompetitions
        })
        .eraseToAnyPublisher()
    }

    func getTopCompetitions() -> AnyPublisher<[TopCompetition], ServiceProviderError> {
        
        let publisher = self.getTopCompetitionsPointers()
            .flatMap({ (topCompetitionPointers: [TopCompetitionPointer]) -> AnyPublisher<[TopCompetition], ServiceProviderError> in
                
                let getCompetitonNodesRequests: [AnyPublisher<SportRadarModels.SportCompetitionInfo?, ServiceProviderError>] = topCompetitionPointers
                    .map { topCompetitionPointer in
                        let competitionIdComponents = topCompetitionPointer.competitionId.components(separatedBy: "/")
                        let competitionId: String = (competitionIdComponents.last ?? "").lowercased()
                        
                        let endpoint = SportRadarRestAPIClient.competitionMarketGroups(competitionId: competitionId)
                        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.SportCompetitionInfo>, ServiceProviderError> = self.restConnector.request(endpoint)
                        return requestPublisher.map({ response in
                            return response.data
                        })
                        .catch({ (error: ServiceProviderError) -> AnyPublisher<SportRadarModels.SportCompetitionInfo?, ServiceProviderError> in
                            return Just(Optional<SportRadarModels.SportCompetitionInfo>.none)
                                .setFailureType(to: ServiceProviderError.self)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                    }
                
                let mergedPublishers = Publishers.MergeMany(getCompetitonNodesRequests)
                    .compactMap({ $0 })
                    .collect()
                    .flatMap { competitionsInfoArray -> AnyPublisher<[TopCompetition], ServiceProviderError> in
                        
                        let getCompetitonCountryRequests: [AnyPublisher<SportRadarModels.CompetitionParentNode, ServiceProviderError>] = competitionsInfoArray
                            .map { (competitionsInfo: SportRadarModels.SportCompetitionInfo) -> AnyPublisher<SportRadarModels.CompetitionParentNode, ServiceProviderError>? in
                                
                                guard
                                    let parentId = competitionsInfo.parentId
                                else {
                                    // If no parent id, we cannot request country info
                                    return nil
                                }
                                
                                let endpoint = SportRadarRestAPIClient.getTopCompetitionCountry(competitionId: parentId)
                                let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.CompetitionParentNode>, ServiceProviderError> = self.restConnector.request(endpoint)
                                
                                return requestPublisher.map({ (response: SportRadarModels.SportRadarResponse<SportRadarModels.CompetitionParentNode>) -> SportRadarModels.CompetitionParentNode in
                                    return response.data
                                })
                                .eraseToAnyPublisher()
                            }
                            .compactMap({ $0 })
                        
                        return Publishers.MergeMany(getCompetitonCountryRequests)
                            .collect()
                            .map { (competitionParentNodes: [SportRadarModels.CompetitionParentNode]) -> [TopCompetition] in
                                var topCompetitionsArray: [TopCompetition] = []
                                
                                var competitionCountriesDictionary: [String: String] = [:]
                                for competitionParentNode in competitionParentNodes {
                                    competitionCountriesDictionary[competitionParentNode.id] = competitionParentNode.name
                                }
                                
                                var competitionAndParentIdDictionary: [String: String] = [:]
                                for competitionsInfo in competitionsInfoArray {
                                    if let parentId = competitionsInfo.parentId {
                                        competitionAndParentIdDictionary[competitionsInfo.id] = parentId
                                    }
                                }
                                
                                for topCompetitionPointer in topCompetitionPointers {
                                    
                                    let competitionIdComponents = topCompetitionPointer.competitionId.components(separatedBy: "/")
                                    let competitionId: String = (competitionIdComponents.last ?? "").lowercased()
                                    
                                    let competitionParentId = competitionAndParentIdDictionary[competitionId] ?? ""
                                    
                                    guard
                                        let competitonCountryName = competitionCountriesDictionary[competitionParentId]
                                    else {
                                        continue
                                    }
                                    
                                    let country: Country? = Country.country(withName: competitonCountryName)
                                    
                                    let sportNameComponents = topCompetitionPointer.competitionId.components(separatedBy: "/")
                                    let sportName: String = (sportNameComponents[safe: sportNameComponents.count - 2] ?? "").lowercased()
                                    
                                    let namedSport: SportRadarModels.SportType = SportRadarModels.SportType.init(name: sportName, numberEvents: 0, numberOutrightEvents: 0, numberOutrightMarkets: 0, numberLiveEvents: 0)
                                    let mappedSport = SportRadarModelMapper.sportType(fromSportRadarSportType: namedSport)
                                    
                                    topCompetitionsArray.append(
                                        TopCompetition(id: competitionId,
                                                       name: topCompetitionPointer.name,
                                                       country: country,
                                                       sportType: mappedSport)
                                    )
                                    
                                }
                                return topCompetitionsArray
                            }
                            .eraseToAnyPublisher()
                    }
                
                return mergedPublishers.eraseToAnyPublisher()
            })
        
        return publisher.eraseToAnyPublisher()
    }

    func getEventSummary(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getEventSummary(eventId: eventId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Event>, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher.map( { sportRadarResponse -> Event in
            let event = sportRadarResponse.data
            let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: event)
            return mappedEvent
        })
        .eraseToAnyPublisher()
    }

    public func getEventSummary(forMarketId marketId: String) -> AnyPublisher<Event, ServiceProviderError> {
        
        let endpoint = SportRadarRestAPIClient.getMarketInfo(marketId: marketId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Event>, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher.map( { sportRadarResponse -> Event in
            let event = sportRadarResponse.data
            let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: event)
            return mappedEvent
        })
        .eraseToAnyPublisher()
        
    }
    
    func getMarketInfo(marketId: String) -> AnyPublisher<Market, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getMarketInfo(marketId: marketId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Market>, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher.map( { sportRadarResponse -> Market in
            let market = sportRadarResponse.data
            let mappedMarket = SportRadarModelMapper.market(fromInternalMarket: market)
            return mappedMarket
        })
        .eraseToAnyPublisher()
    }

    func getEventsForMarketGroup(withId marketGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.getEventsForMarketGroup(marketGroupId: marketGroupId)

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.EventsGroup>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> EventsGroup in
            let eventsGroup = sportRadarResponse.data
            let mappedEventsGroup = SportRadarModelMapper.eventsGroup(fromInternalEventsGroup: eventsGroup)

            let filteredEvents = mappedEventsGroup.events.filter({
                $0.id != "_TOKEN_"
            })

            let filteredEventsGroup = EventsGroup(events: filteredEvents, marketGroupId: eventsGroup.marketGroupId)
            return filteredEventsGroup
        })
        .eraseToAnyPublisher()
    }

    func getEventForMarket(withId marketId: String) -> AnyPublisher<Event?, Never> {
        let endpoint = SportRadarRestAPIClient.getEventForMarket(marketId: marketId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Event>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> Event in
            let event = sportRadarResponse.data
            let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: event)
            return mappedEvent
        })
        .replaceError(with: nil)
        .eraseToAnyPublisher()
    }


    //
    // MARK: - Favorites
    //
    func getFavoritesList() -> AnyPublisher<FavoritesListResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.favoritesList

        let requestPublisher: AnyPublisher<SportRadarModels.FavoritesListResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { favoritesListResponse -> FavoritesListResponse in

            let mappedFavoritesListResponse = SportRadarModelMapper.favoritesListResponse(fromInternalFavoritesListResponse: favoritesListResponse)

            return mappedFavoritesListResponse
        })
        .eraseToAnyPublisher()
    }

    func addFavoritesList(name: String) -> AnyPublisher<FavoritesListAddResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.addFavoriteList(name: name)

        let requestPublisher: AnyPublisher<SportRadarModels.FavoritesListAddResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { favoritesListAddResponse -> FavoritesListAddResponse in

            let mappedFavoritesListAddResponse = SportRadarModelMapper.favoritesListAddResponse(fromInternalFavoritesListAddResponse: favoritesListAddResponse)

            return mappedFavoritesListAddResponse
        })
        .eraseToAnyPublisher()
    }

    func deleteFavoritesList(listId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.deleteFavoriteList(listId: listId)

        let requestPublisher: AnyPublisher<SportRadarModels.FavoritesListDeleteResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { favoritesListDeleteResponse -> FavoritesListDeleteResponse in

            let mappedFavoritesListDeleteResponse = SportRadarModelMapper.favoritesListDeleteResponse(fromInternalFavoritesListDeleteResponse: favoritesListDeleteResponse)

            return mappedFavoritesListDeleteResponse
        })
        .eraseToAnyPublisher()
    }

    func addFavoriteToList(listId: Int, eventId: String) -> AnyPublisher<FavoriteAddResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.addFavoriteToList(listId: listId, eventId: eventId)

        let requestPublisher: AnyPublisher<SportRadarModels.FavoriteAddResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { favoriteAddResponse -> FavoriteAddResponse in

            let mappedFavoriteAddResponse = SportRadarModelMapper.favoriteAddResponse(fromInternalFavoriteAddResponse: favoriteAddResponse)

            return mappedFavoriteAddResponse
        })
        .eraseToAnyPublisher()
    }

    func getFavoritesFromList(listId: Int) -> AnyPublisher<FavoriteEventResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.getFavoritesFromList(listId: listId)

        let requestPublisher: AnyPublisher<SportRadarModels.FavoriteEventResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { favoriteEventResponse -> FavoriteEventResponse in

            let mappedFavoriteEventResponse = SportRadarModelMapper.favoritesEventResponse(fromInternalFavoritesEventResponse: favoriteEventResponse)

            return mappedFavoriteEventResponse
        })
        .eraseToAnyPublisher()
    }

    func deleteFavoriteFromList(eventId: Int) -> AnyPublisher<FavoritesListDeleteResponse, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.deleteFavoriteFromList(eventId: eventId)

        let requestPublisher: AnyPublisher<SportRadarModels.FavoritesListDeleteResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { favoritesListDeleteResponse -> FavoritesListDeleteResponse in

            let mappedFavoritesListDeleteResponse = SportRadarModelMapper.favoritesListDeleteResponse(fromInternalFavoritesListDeleteResponse: favoritesListDeleteResponse)

            return mappedFavoritesListDeleteResponse
        })
        .eraseToAnyPublisher()
    }

    func getEventDetails(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getEventDetails(eventId: eventId)

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Event>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> Event in
            let event = sportRadarResponse.data
            let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: event)
            return mappedEvent
        })
        .eraseToAnyPublisher()
    }

}

extension SportRadarEventsProvider: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        let endpoint = SportRadarRestAPIClient.unsubscribe(sessionToken: subscription.sessionToken, contentIdentifier: subscription.contentIdentifier)
        guard let request = endpoint.request() else { return }
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("SportRadarEventsProvider unsubscribe failed")
                return
            }
            print("SportRadarEventsProvider unsubscribe ok")
        }
        sessionDataTask.resume()
    }

}

// Helpers
extension SportRadarEventsProvider {

}

extension SportRadarEventsProvider {

    private func mergeSports(numericSportArray: [SportRadarModels.SportType], alphaSportArray: [SportRadarModels.SportType]) -> [SportRadarModels.SportType] {

        var uniqueSportsArray: [SportRadarModels.SportType] = []

        for numericSport in numericSportArray {

            if numericSport.name.lowercased() == "top bets"
                || numericSport.name.lowercased() == "top bet"
                || numericSport.name.lowercased() == "outrights"
                || numericSport.name.lowercased() == "popular" {
                continue
            }

            let alphaFilter = alphaSportArray.filter({ $0.name.lowercased() == numericSport.name.lowercased() })

            if let alphaSport = alphaFilter.first {
                let mergedSport = SportRadarModels.SportType(name: numericSport.name,
                                                             numericId: numericSport.numericId,
                                                             alphaId: alphaSport.alphaId,
                                                             numberEvents: numericSport.numberEvents,
                                                             numberOutrightEvents: numericSport.numberOutrightEvents,
                                                             numberOutrightMarkets: numericSport.numberOutrightMarkets,
                                                             numberLiveEvents: numericSport.numberLiveEvents)
                uniqueSportsArray.append(mergedSport)
            }
            else {
                uniqueSportsArray.append(numericSport)
            }
        }

        for alphaSport in alphaSportArray {
            if !uniqueSportsArray.contains(where: { $0.name.lowercased() == alphaSport.name.lowercased() }) {
                uniqueSportsArray.append(alphaSport)
            }
        }

        return uniqueSportsArray
    }

    private func processMarketFilters(marketFilter: MarketFilter, match: Event) -> [MarketGroup] {

        var eventMarkets: [EventMarket] = []
        var marketGroups: OrderedDictionary<String, MarketGroup> = [:]
        var availableMarkets: [String: [AvailableMarket]] = [:]

        var availableMarketGroups: [String: [AvailableMarket]] = [:]

        // NEW PARSE
        for marketFilter in marketFilter.marketFilters {
            // SPECIFIC MARKET IDS
            var selectedMarketIds: [String] = []

            if let selectedMarketSports = marketFilter.marketsSportType?.marketSports {

                for marketSportType in selectedMarketSports {
                    let eventSportCode = match.sport.alphaId ?? ""
                    for marketSport in marketSportType.value {

                        if eventSportCode.contains(marketSportType.key) || marketSportType.key.lowercased() == "all" {
                            let marketSportId = marketSport.ids[0]
                            selectedMarketIds.append(marketSportId)
                        }
                    }
                }
            }
            let eventMarket = EventMarket(id: "\(marketFilter.displayOrder)", name: marketFilter.translations?.english ?? "", marketIds: selectedMarketIds)
            eventMarkets.append(eventMarket)
        }

        let matchMarkets = match.markets

        for matchMarket in matchMarkets {

            if let marketTypeId = matchMarket.marketTypeId {

                for eventMarket in eventMarkets {

                    if eventMarket.marketIds.contains(marketTypeId) {

                        if availableMarkets[eventMarket.name] == nil {
                            let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id,
                                                                  market: matchMarket)
                            availableMarkets[eventMarket.name] = [availableMarket]
                        }
                        else {
                            let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id,
                                                                  market: matchMarket)
                            availableMarkets[eventMarket.name]?.append(availableMarket)
                        }

                    }

                }

                // Add to All Market aswell
                let allEventMarket = eventMarkets.filter({
                    $0.id == "1"
                })

                let eventMarket = allEventMarket[0]

                if availableMarkets[eventMarket.name] == nil {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id,
                                                          market: matchMarket)
                    availableMarkets[eventMarket.name] = [availableMarket]
                }
                else {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id,
                                                          market: matchMarket)
                    availableMarkets[eventMarket.name]?.append(availableMarket)
                }

            }
            else {
                let allEventMarket = eventMarkets.filter({
                    $0.id == "1"
                })

                let eventMarket = allEventMarket[0]
                if availableMarkets[eventMarket.name] == nil {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id,
                                                          market: matchMarket)
                    availableMarkets[eventMarket.name] = [availableMarket]
                }
                else {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id, marketGroupId: eventMarket.id,
                                                          market: matchMarket)
                    availableMarkets[eventMarket.name]?.append(availableMarket)
                }

            }
        }


        availableMarketGroups = availableMarkets

        for availableMarket in availableMarkets {
            let marketGroup = MarketGroup(type: availableMarket.key,
                                          id: availableMarket.value.first?.marketGroupId ?? "0",
                                          groupKey: "\(availableMarket.value.first?.marketGroupId ?? "0")",
                                          translatedName: availableMarket.key.capitalized,
                                          position: Int(availableMarket.value.first?.marketGroupId ?? "0") ?? 0,
                                          isDefault: availableMarket.key == "All Markets" ? true : false,
                                          numberOfMarkets: availableMarket.value.count,
                                          markets: availableMarket.value.map(\.market))

            marketGroups[availableMarket.key] = marketGroup
        }

        let marketGroupsArray = Array(marketGroups.values)

        let sortedMarketGroupsArray = marketGroupsArray.sorted(by: {
            $0.position ?? 0 < $1.position ?? 99
        })

        //self.marketGroupsPublisher.send(sortedMarketGroupsArray)
        return sortedMarketGroupsArray
    }

    func getDatesFilter(timeRange: String) -> [Date] {
        var dates = [Date]()

        let days = timeRange.components(separatedBy: "-")

        if let initialDay = Int(days[safe: 0] ?? "0"),
           let endDay = Int(days[safe: 1] ?? "365") {
            if let startDate = Calendar.current.date(byAdding: .day, value: initialDay, to: Date()),
               let endDate = Calendar.current.date(byAdding: .day, value: endDay, to: Date()) {
                dates.append(startDate)
                dates.append(endDate)
            }
        }

        return dates
    }

}

extension SportRadarEventsProvider {

    func getValidEventDetailsCoordinators() -> [SportRadarEventDetailsCoordinator] {
        self.eventDetailsCoordinators = self.eventDetailsCoordinators.filter({ $0.value.isActive })
        return Array(self.eventDetailsCoordinators.values)
    }

    func getValidEventDetailsCoordinator(forKey key: String) -> SportRadarEventDetailsCoordinator? {
        self.eventDetailsCoordinators = self.eventDetailsCoordinators.filter({ $0.value.isActive })
        return self.eventDetailsCoordinators[key]
    }

    func addEventDetailsCoordinator(_ coordinator: SportRadarEventDetailsCoordinator, withKey key: String) {
        self.eventDetailsCoordinators = self.eventDetailsCoordinators.filter({ $0.value.isActive })
        self.eventDetailsCoordinators[key] = coordinator
    }

}

extension SportRadarEventsProvider {

    private func createPayloadData(with sessionAccessToken: SportRadarSessionAccessToken, contentType: ContentType, contentRoute: ContentRoute) -> Data {
        let bodyString =
        """
        {
            "subscriberId": "\(sessionAccessToken.hash)",
            "contentId": {
                "type": "\(contentType.rawValue)",
                "id": "\(contentRoute.fullRoute)"
            },
            "clientContext": {
                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                "ipAddress": "127.0.0.1"
            }
        }
        """
        return bodyString.data(using: String.Encoding.utf8) ?? Data()
    }

    private func createSubscribeRequest(withHTTPBody body: Data? = nil) -> URLRequest {
        let hostname = SportRadarConfiguration.shared.servicesRestHostname
        let url = URL(string: "\(hostname)/services/content/subscribe")!
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func createUnsubscribeRequest(withHTTPBody body: Data? = nil) -> URLRequest {
        let hostname = SportRadarConfiguration.shared.servicesRestHostname
        let url = URL(string: "\(hostname)/services/content/unsubscribe")!
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

}
