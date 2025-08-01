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

    private var sportsMerger: SportsMerger?

    required init(sessionCoordinator: SportRadarSessionCoordinator,
                  socketConnector: SportRadarSocketConnector = SportRadarSocketConnector(),
                  restConnector: SportRadarRestConnector = SportRadarRestConnector()) {
        print("[SERVICEPROVIDER][PROVIDER] Initializing SportRadarEventsProvider")
        self.sessionCoordinator = sessionCoordinator

        self.socketConnector = socketConnector
        self.restConnector = restConnector

        self.socketConnector.connectionStatePublisher.sink { completion in
            print("[SERVICEPROVIDER][SOCKET] Socket connection publisher completed")
        } receiveValue: { [weak self] connectorState in
            print("[SERVICEPROVIDER][SOCKET] Socket connection state changed to: \(connectorState)")
            self?.connectionStateSubject.send(connectorState)
        }
        .store(in: &self.cancellables)

        self.sessionCoordinator.token(forKey: .launchToken)
            .sink { [weak self] launchToken in
                if let launchTokenValue = launchToken  {
                    print("[SERVICEPROVIDER][PROVIDER] Launch token received: \(launchTokenValue)")
                    self?.restConnector.saveSessionKey(launchTokenValue)
                }
                else {
                    print("[SERVICEPROVIDER][PROVIDER] No launch token available, clearing session key")
                    self?.restConnector.clearSessionKey()
                }
            }
            .store(in: &self.cancellables)

        self.socketConnector.tokenPublisher
            .removeDuplicates()
            .compactMap({ $0 })
            .withPrevious()
            .sink(receiveValue: { [weak self] (oldToken, newToken) in
                print("[SERVICEPROVIDER][SOCKET] Socket token updated")
                self?.sessionCoordinator.saveToken(newToken.hash, withKey: .socketSessionToken)

                if let oldToken, oldToken != newToken {
                    print("[SERVICEPROVIDER][SOCKET] Socket reconnected with new token: \(newToken.hash)")
                    self?.subscribePreviousTopics(withNewSocketToken: newToken.hash)
                }
                else {
                    print("[SERVICEPROVIDER][SOCKET] Initial socket connection with token: \(newToken.hash)")
                }
            })
            .store(in: &self.cancellables)

        self.socketConnector.messageSubscriber = self
        print("[SERVICEPROVIDER][SOCKET] Initiating socket connection")
        self.socketConnector.connect()

    }

    private weak var liveSportsSubscription: Subscription?
    private weak var allSportTypesSubscription: Subscription?

    private var liveSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var allSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var allSportsListTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var eventsPaginators: [String: SportRadarEventsPaginator] = [:]
    private var eventDetailsCoordinators: [String: SportRadarEventDetailsCoordinator] = [:]
    private var liveEventDetailsCoordinators: [String: SportRadarLiveEventDataCoordinator] = [:]
    private var marketUpdatesCoordinators: [String: SportRadarMarketDetailsCoordinator] = [:]

    private var eventsSecundaryMarketsUpdatesCoordinators: [String: SportRadarEventMarketsCoordinator] = [:]

    private var competitionEventsPublisher: [ContentIdentifier: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>] = [:]
    private var outrightDetailsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var eventSummaryPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var eventLiveDataPublisher: CurrentValueSubject<SubscribableContent<Events>, ServiceProviderError>?

    //
    // Keep a reference for all the subscriptions. This allows the ServiceProvider to subscribe to the same content in two different app places
    private var activeSubscriptions: NSMapTable<ContentIdentifier, Subscription> = .init(keyOptions: .strongMemory , valueOptions: .weakMemory)

    private let defaultEventCount = 10

    func reconnectIfNeeded() {
        print("[SERVICEPROVIDER][SOCKET] Attempting socket reconnection if needed")
        self.socketConnector.refreshConnection()
    }

    func subscribePreviousTopics(withNewSocketToken newSocketToken: String) {
        print("[SERVICEPROVIDER][PROVIDER] Resubscribing to previous topics with new socket token")
        self.eventsPaginators = self.eventsPaginators.filter { $0.value.isActive }
        for paginator in self.eventsPaginators.values where paginator.isActive {
            print("[SERVICEPROVIDER][PROVIDER] Reconnecting paginator")
            paginator.reconnect(withNewSessionToken: newSocketToken)
        }

        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            print("[SERVICEPROVIDER][PROVIDER] Reconnecting event details coordinator")
            eventDetailsCoordinator.reconnect(withNewSessionToken: newSocketToken)
        }

        for liveEventDetailsCoordinator in self.getValidLiveEventDetailsCoordinators() {
            print("[SERVICEPROVIDER][PROVIDER] Reconnecting live event details coordinator")
            liveEventDetailsCoordinator.reconnect(withNewSessionToken: newSocketToken)
        }

        self.marketUpdatesCoordinators = self.marketUpdatesCoordinators.filter { $0.value.isActive }
        for marketUpdatesCoordinator in self.marketUpdatesCoordinators.values {
            print("[SERVICEPROVIDER][PROVIDER] Reconnecting market updates coordinator")
            marketUpdatesCoordinator.reconnect(withNewSessionToken: newSocketToken)
        }
        
        if let sportsMerger = self.sportsMerger {
            sportsMerger.reconnect(withNewSessionToken: newSocketToken)
        }
        
    }

    //
    // MARK: - Custom Request
    func customRequest<T: Codable>(endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        let requestPublisher: AnyPublisher<T, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher
    }

    //
    // MARK: - Pre Live Matches
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
            return paginator.eventsGroupPublisher
        }
        else {
            let paginator = SportRadarEventsPaginator(contentIdentifier: contentIdentifier,
                                                      sessionToken: sessionToken.hash,
                                                      storage: SportRadarEventsStorage())

            self.eventsPaginators[contentIdentifier.pageableId] = paginator
            return paginator.eventsGroupPublisher
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
            return paginator.eventsGroupPublisher
        }
        else {
            let paginator = SportRadarEventsPaginator(contentIdentifier: contentIdentifier,
                                                      sessionToken: sessionToken.hash,
                                                      storage: SportRadarEventsStorage())
            self.eventsPaginators[contentIdentifier.pageableId] = paginator
            return paginator.eventsGroupPublisher
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
            let sessionToken = self.socketConnector.token
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

            // print("NetworkLogs: ", request.cURL(pretty: true), "\nNetworkLogs: ==========================================")

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

    func subscribeSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        guard let sessionToken = self.socketConnector.token else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        if let existingMerger = sportsMerger, existingMerger.isActive {
            return existingMerger.sportsPublisher
        }

        let merger = SportsMerger(sessionToken: sessionToken.hash)
        self.sportsMerger = merger
        self.socketConnector.messageSubscriber = self
        return merger.sportsPublisher
    }

    //
    //
    func subscribeEndedMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func requestEndedMatchesNextPage(forSportType sportType: SportType) -> AnyPublisher<Bool, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    //
    func subscribeOutrightEvent(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {

        return self.getEventForMarketGroup(withId: marketGroupId)
            .map({ event in
                return SubscribableContent.contentUpdate(content: event)
            })
//            .flatMap { event in
//                self.subscribeEventDetails(eventId: event.id)
//            }
            .eraseToAnyPublisher()

    }

    func subscribeOutrightMarkets(forMarketGroupId marketGroupId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        guard
            let sessionToken = socketConnector.token
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

            // print("NetworkLogs: ", request.cURL(pretty: true), "\nNetworkLogs: ==========================================")

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

        // print("NetworkLogs: ", request.cURL(pretty: true), "\nNetworkLogs: ==========================================")

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("ServiceProvider subscribeEventSummary \(String(describing: error)) \(String(describing: response))")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            // TODO: send subscription
            publisher.send(.connected(subscription: subscription))
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
            // Check if we already have a subscription to
            var liveDataExtendedSubscription: Subscription?
            if let liveEventDetailsCoordinator = self.getValidLiveEventDetailsCoordinator(forKey: eventId) {
                liveDataExtendedSubscription = liveEventDetailsCoordinator.liveDataExtendedSubscription
            }

            let eventDetailsCoordinator = SportRadarEventDetailsCoordinator(matchId: eventId,
                                                                            sessionToken: sessionToken.hash,
                                                                            storage: SportRadarEventStorage(),
                                                                            liveDataExtendedSubscription: liveDataExtendedSubscription,
                                                                            marketsSubscription: nil)
            self.addEventDetailsCoordinator(eventDetailsCoordinator, withKey: eventId)
            return eventDetailsCoordinator.eventDetailsPublisher
        }

    }

    func subscribeToMarketGroups(eventId: String) -> AnyPublisher<SubscribableContent<[MarketGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }
    
    func subscribeToMarketGroupDetails(eventId: String, marketGroupKey: String) -> AnyPublisher<SubscribableContent<[Market]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.eventsProviderNotFound).eraseToAnyPublisher()
    }
    
    // Independent Live Data extended info
    public func subscribeToLiveDataUpdates(forEventWithId id: String) -> AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError> {

        guard
            let sessionToken = self.socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        // event details
        if let liveEventDetailsCoordinator = self.getValidLiveEventDetailsCoordinator(forKey: id),
           liveEventDetailsCoordinator.containsEvent(withid: id) {
            return liveEventDetailsCoordinator.eventLiveDataPublisher
        }
        else {
            // Check if we already have a subscription to
            var liveDataExtendedSubscription: Subscription?
            if let eventDetailsCoordinator = self.getValidEventDetailsCoordinator(forKey: id) {
                liveDataExtendedSubscription = eventDetailsCoordinator.liveDataExtendedSubscription
            }

            let liveEventDetailsCoordinator = SportRadarLiveEventDataCoordinator(eventId: id,
                                                                                 sessionToken: sessionToken.hash,
                                                                                 storage: SportRadarEventStorage(),
                                                                                 liveDataExtendedSubscription: liveDataExtendedSubscription)
            self.addLiveEventDetailsCoordinator(liveEventDetailsCoordinator, withKey: id)
            return liveEventDetailsCoordinator.eventLiveDataPublisher
        }

    }

    // live info associated with the paginator lists and event details
    public func subscribeToEventOnListsLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, ServiceProviderError> {

        guard
            self.socketConnector.token != nil
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        // events lists
        for paginator in self.eventsPaginators.values {
            if paginator.containsEvent(withid: id), let publisher = paginator.subscribeToEventOnListsLiveDataUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // event details
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            if eventDetailsCoordinator.containsEvent(withid: id) {
                let publisher = eventDetailsCoordinator.subscribeToEventOnListsLiveDataUpdates(withId: id)
                return publisher.setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        return Fail(error: ServiceProviderError.resourceNotFound).eraseToAnyPublisher()
    }


    public func subscribeToEventOnListsMarketUpdates(withId id: String) -> AnyPublisher<Market?, ServiceProviderError> {

        // events lists
        for paginator in self.eventsPaginators.values {
            if paginator.containsMarket(withid: id), let publisher = paginator.subscribeToEventOnListsMarketUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // event details
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            if eventDetailsCoordinator.containsMarket(withid: id),
               let publisher = eventDetailsCoordinator.subscribeToEventOnListsMarketUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // Event secundary markets details
        for eventMarketsCoordinator in self.getValidEventMarketsCoordinators() {
            if eventMarketsCoordinator.containsMarket(withid: id),
               let publisher = eventMarketsCoordinator.subscribeToEventOnListsMarketUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        return Just(nil).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
    }

    public func subscribeToEventOnListsOutcomeUpdates(withId id: String) -> AnyPublisher<Outcome?, ServiceProviderError> {

        // events lists
        for paginator in self.eventsPaginators.values {
            if paginator.containsOutcome(withid: id), let publisher = paginator.subscribeToEventOnListsOutcomeUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // event details
        for eventDetailsCoordinator in self.getValidEventDetailsCoordinators() {
            if eventDetailsCoordinator.containsOutcome(withid: id),
               let publisher = eventDetailsCoordinator.subscribeToEventOnListsOutcomeUpdates(withId: id) {
                return publisher.map(Optional.init).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }
        }

        // Secundary Markets - event details

        for eventMarketsCoordinator in self.getValidEventMarketsCoordinators() {
            if eventMarketsCoordinator.containsOutcome(withid: id),
               let publisher = eventMarketsCoordinator.subscribeToEventOnListsOutcomeUpdates(withId: id) {
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
        let contentType: ContentType = ContentType.market
        // contentId -> FBL/0 -> /0 means page 0 of pagination
        let contentRoute = ContentRoute.market(marketId: marketId)

        let contentIdentifier = ContentIdentifier(contentType: contentType, contentRoute: contentRoute)

        if let coordinators = self.marketUpdatesCoordinators[marketId], coordinators.isActive {
            print("DebugSgt: marketUpdatesCoordinators \(marketId) isActive")
            return coordinators.marketPublisher
        }
        else {
            print("DebugSgt: marketUpdatesCoordinators \(marketId) not active")
            let coordinator = SportRadarMarketDetailsCoordinator.init(marketId: marketId,
                                                                      eventId: eventId,
                                                                      sessionToken: sessionToken.hash,
                                                                      contentIdentifier: contentIdentifier)
            self.marketUpdatesCoordinators[marketId] = coordinator
            return coordinator.marketPublisher
        }

    }

    func subscribePopularTournaments(forSportType sportType: SportType, tournamentsCount: Int) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeSportTournaments(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[Tournament]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - Tournament RPC Methods
    
    func getPopularTournaments(forSportType sportType: SportType, tournamentsCount: Int) -> AnyPublisher<[Tournament], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func getTournaments(forSportType sportType: SportType) -> AnyPublisher<[Tournament], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
}

//
// MARK: - Socket event delegate
//
extension SportRadarEventsProvider: SportRadarConnectorSubscriber {

    //
    // EVENTS
    //
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

    //
    // SPORTS
    //
    // Update the socket delegate methods to use SportsMerger
    func liveSportsUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        print("[SERVICEPROVIDER][DELEGATE] Received live sports update with \(sportTypes.count) sports")
        let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
        sportsMerger?.updateSports(sports, forContentIdentifier: ContentIdentifier(contentType: .liveSports, contentRoute: .liveSports))
    }

    func preLiveSportsUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        print("[SERVICEPROVIDER][DELEGATE] Received pre-live sports update with \(sportTypes.count) sports")
        if let allSportTypesPublisher = self.allSportTypesPublisher {
            let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
            allSportTypesPublisher.send(.contentUpdate(content: sports))
        }
    }

    func allSportsUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        print("[SERVICEPROVIDER][DELEGATE] Received all sports update with \(sportTypes.count) sports")
        let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
        sportsMerger?.updateSports(sports, forContentIdentifier: ContentIdentifier(contentType: .allSports, contentRoute: .allSports))
    }


    func updateSportLiveCount(nodeId: String, liveCount: Int) {
        print("[SERVICEPROVIDER][DELEGATE] Updating live count for sport \(nodeId): \(liveCount)")
        guard let merger = self.sportsMerger else {
            print("[SERVICEPROVIDER][DELEGATE] Error: SportsMerger not available")
            return
        }
        merger.updateSportLiveCount(nodeId: nodeId, liveCount: liveCount)
    }

    func updateSportEventCount(nodeId: String, eventCount: Int) {
        print("[SERVICEPROVIDER][DELEGATE] Updating event count for sport \(nodeId): \(eventCount)")
        guard let merger = self.sportsMerger else {
            print("[SERVICEPROVIDER][DELEGATE] Error: SportsMerger not available")
            return
        }
        merger.updateSportEventCount(nodeId: nodeId, eventCount: eventCount)
    }

    //
    // EVENTS DETAILS
    //
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

        for liveEventDetailsCoordinator in self.getValidLiveEventDetailsCoordinators() {
            liveEventDetailsCoordinator.updatedLiveData(eventLiveDataExtended: eventLiveDataExtended, forContentIdentifier: contentIdentifier)
        }

    }

    func updateEventSecundaryMarkets(forContentIdentifier identifier: ContentIdentifier, event: Event) {
        for eventDetailsCoordinator in self.getValidEventMarketsCoordinators() {
            eventDetailsCoordinator.updatedSecundaryMarkets(forContentIdentifier: identifier,
                                                            onEvent: event)
        }
    }

    func updateEventMainMarket(forContentIdentifier identifier: ContentIdentifier, event: Event) {
        for eventDetailsCoordinator in self.getValidEventMarketsCoordinators() {
            eventDetailsCoordinator.updatedMainMarket(forContentIdentifier: identifier,
                                                            onEvent: event)
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

        for liveEventDetailsCoordinator in self.getValidLiveEventDetailsCoordinators() {
            liveEventDetailsCoordinator.handleContentUpdate(content)
        }

        for marketUpdatesCoordinator in self.marketUpdatesCoordinators.values {
            marketUpdatesCoordinator.handleContentUpdate(content)
        }

        for secundaryMarketsCoordinators in self.getValidEventMarketsCoordinators() {
            secundaryMarketsCoordinators.handleContentUpdate(content)
        }
    }

}
//
//
extension SportRadarEventsProvider {

    func getNews() -> AnyPublisher<[News], ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func addFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func deleteFavoriteItem(favoriteId: Int, type: String) -> AnyPublisher<BasicMessageResponse, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }

    func getFeaturedTips(page: Int?, limit: Int?, topTips: Bool?, followersTips: Bool?, friendsTips: Bool?, userId: String?, homeTips: Bool?) -> AnyPublisher<FeaturedTips, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    // MARK: - New Filtered Subscription Methods (Not Supported)
    
    func subscribeToFilteredPreLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
    
    func subscribeToFilteredLiveMatches(filters: MatchesFilterOptions) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.notSupportedForProvider).eraseToAnyPublisher()
    }
}

//
// MARK: - Competition and Match Details
//
extension SportRadarEventsProvider {

    public func getMarketGroups(
        forEvent event: Event,
        includeMixMatchGroup hasMixMatchGroup: Bool,
        includeAllMarketsGroup hasAllMarketsGroup: Bool
    ) -> AnyPublisher<[MarketGroup], Never>
    {
        let fallbackMarketGroup = [MarketGroup.init(type: "0",
                                                    id: "0",
                                                    groupKey: "All Markets",
                                                    translatedName: "All Markets",
                                                    position: 0,
                                                    isDefault: true,
                                                    numberOfMarkets: nil,
                                                    loaded: true,
                                                    markets: event.markets)]

        let endpoint = SportRadarRestAPIClient.marketsFilter
        let requestPublisher: AnyPublisher<MarketFilter, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher
            .flatMap({ marketFilters -> AnyPublisher<[MarketGroup], ServiceProviderError> in
                let marketGroups = self.processMarketFilters(
                    marketFilter: marketFilters,
                    match: event,
                    includeMixMatchGroup: hasMixMatchGroup,
                    includeAllMarketsGroup: hasAllMarketsGroup
                )
                return Just(marketGroups).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            })
            .replaceError(with: fallbackMarketGroup)
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
            guard
                let widgetHTMLTemplate = NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String,
                let fieldWidgetId = fieldWidget.data,
                let bundleUrl = Bundle.main.url(forResource: fileStringSplit[0], withExtension: fileStringSplit[1])
            else {
                //
                return Fail(outputType: FieldWidgetRenderDataType.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            }

            var replacedHtmlContent = widgetHTMLTemplate.replacingOccurrences(of: "@eventId", with: fieldWidgetId)
            replacedHtmlContent = replacedHtmlContent.replacingOccurrences(of: "@languageCode", with: "fr")

            let fieldWidgetRenderDataType = FieldWidgetRenderDataType.htmlString(url: bundleUrl, htmlString: replacedHtmlContent)
            return Just(fieldWidgetRenderDataType).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

        }).eraseToAnyPublisher()

    }

    func getStatsWidget(eventId: String, marketTypeName: String, isDarkTheme: Bool?) -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError> {

        var statsWidgetFile = "stats_widget_light.html"
        if isDarkTheme ?? true {
            statsWidgetFile = "stats_widget_dark.html"
        }

        return self.getFieldWidgetId(eventId: eventId).flatMap({ statsWidget -> AnyPublisher<StatsWidgetRenderDataType, ServiceProviderError> in

            let fileStringSplit = statsWidgetFile.components(separatedBy: ".")

            let filePath = Bundle.main.path(forResource: fileStringSplit[0], ofType: fileStringSplit[1])
            let contentData = FileManager.default.contents(atPath: filePath!)
            let widgetHTMLTemplate = NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String
            if let statsWidgetId = statsWidget.data,
               let replacedHtmlContent = widgetHTMLTemplate?.replacingOccurrences(of: "@MATCH_ID_PLACEHOLDER", with: statsWidgetId)
                .replacingOccurrences(of: "@MARKET_TYPE_PLACEHOLDER", with: marketTypeName)
                .replacingOccurrences(of: "@LANGUAGE_CODE_PLACEHOLDER", with: "fr"),

                let bundleUrl = Bundle.main.url(forResource: fileStringSplit[0], withExtension: fileStringSplit[1]) {

                let statsWidgetRenderDataType = StatsWidgetRenderDataType.htmlString(url: bundleUrl, htmlString: replacedHtmlContent)
                return Just(statsWidgetRenderDataType).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
            }

            return Fail(outputType: StatsWidgetRenderDataType.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()

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
            let mappedBannersResponse = SportRadarModelMapper.banners(fromInternalBanners: bannersResponse.bannerItems)
            //            let mappedEventsGroup = SportRadarModelMapper.events(fromInternalEvents: events)

            return mappedBannersResponse
        })
        .eraseToAnyPublisher()

    }
    
    func getPromotedSports() -> AnyPublisher<[PromotedSport], ServiceProviderError> {
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
            let mappedBannersResponse = SportRadarModelMapper.banners(fromInternalBanners: bannersResponse.bannerItems)
            return mappedBannersResponse
        })
        .eraseToAnyPublisher()

    }

    func getEventSummary(eventId: String, marketLimit: Int?) -> AnyPublisher<Event, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getEventSummary(eventId: eventId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Event>, ServiceProviderError> = self.restConnector.request(endpoint)
        return requestPublisher.map( { sportRadarResponse -> Event in
            let event = sportRadarResponse.data
            let mappedEvent = SportRadarModelMapper.event(fromInternalEvent: event)
            return mappedEvent
        })
        .eraseToAnyPublisher()
    }

    func getEventSummary(forMarketId marketId: String) -> AnyPublisher<Event, ServiceProviderError> {

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

    func getEventForMarketGroup(withId marketGroupId: String) -> AnyPublisher<Event, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.getEventForMarketGroup(marketGroupId: marketGroupId)

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.MarketGroup>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.tryMap( { sportRadarResponse -> Event in
            guard
                let event = SportRadarModelMapper.event(fromInternalMarkets: sportRadarResponse.data.markets)
                else {
                throw ServiceProviderError.errorMessage(message: "No event found for marketGroup")
            }
            return event
        })
        .mapError { error -> ServiceProviderError in
            if let serviceProviderError = error as? ServiceProviderError {
                return serviceProviderError
            } else {
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
        }
        .eraseToAnyPublisher()
    }

    public func getEventGroup(withId eventGroupId: String) -> AnyPublisher<EventsGroup, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.getEventsForEventGroup(eventGroupId: eventGroupId)

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

    func getTopCompetitionCountry(competitionParentId: String) -> AnyPublisher<SportRadarModels.CompetitionParentNode, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getTopCompetitionCountry(competitionId: competitionParentId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.CompetitionParentNode>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map({ (response: SportRadarModels.SportRadarResponse<SportRadarModels.CompetitionParentNode>) -> SportRadarModels.CompetitionParentNode in
            return response.data
        })
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


    func getEventLiveData(eventId: String) -> AnyPublisher<EventLiveData, ServiceProviderError> {

        let liveDataContentType = ContentType.eventDetailsLiveData
        let liveDataContentRoute = ContentRoute.eventDetailsLiveData(eventId: eventId)
        let liveDataContentIdentifier = ContentIdentifier(contentType: liveDataContentType, contentRoute: liveDataContentRoute)

        let endpoint = SportRadarRestAPIClient.get(contentIdentifier: liveDataContentIdentifier)

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.EventLiveDataExtended>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> EventLiveData in
            return SportRadarModelMapper.eventLiveData(fromInternalEventLiveData: sportRadarResponse.data)
        })
        .eraseToAnyPublisher()

    }

    func getEventSecundaryMarkets(eventId: String) -> AnyPublisher<Event, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.getEventSecundaryMarkets(eventId: eventId)

        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<SportRadarModels.Event>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { sportRadarResponse -> Event in
            return SportRadarModelMapper.event(fromInternalEvent: sportRadarResponse.data)
        })
        .eraseToAnyPublisher()
    }


    func subscribeEventMarkets(eventId: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {

        guard
            let sessionToken = socketConnector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        if let eventDetailsCoordinator = self.getValidEventMarketsCoordinator(forKey: eventId) {
            return eventDetailsCoordinator.eventWithSecundaryMarketsPublisher
        }
        else {
            let eventDetailsCoordinator = SportRadarEventMarketsCoordinator(matchId: eventId,
                                                                            sessionToken: sessionToken.hash,
                                                                            storage: SportRadarEventStorage())
            self.addEventMarketsCoordinator(eventDetailsCoordinator, withKey: eventId)
            eventDetailsCoordinator.start() // Triggers the subscription
            return eventDetailsCoordinator.eventWithSecundaryMarketsPublisher
        }

    }

    func getPromotedBetslips(userId: String?) -> AnyPublisher<[PromotedBetslip], ServiceProviderError> {
        let endpoint = VaixAPIClient.promotedBetslips(userId: userId)

        let requestPublisher: AnyPublisher<SportRadarModels.PromotedBetslipsBatchResponse, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher
            .mapError({ error in
                return error
            })
            .map { response in
                let promotedBetslipsBatchResponse = SportRadarModelMapper.promotedBetslipsBatchResponse(fromInternalPromotedBetslipsBatchResponse: response)
                return promotedBetslipsBatchResponse.promotedBetslips
            }
            .eraseToAnyPublisher()
    }

    func getHighlightedLiveEventsPointers(eventCount: Int, userId: String?) -> AnyPublisher<[String], ServiceProviderError> {
        let endpoint = VaixAPIClient.popularEvents(eventsCount: eventCount, userId: userId)
        let requestPublisher: AnyPublisher<SportRadarModels.SportRadarResponse<[SportRadarModels.HighlightedEventPointer]>, ServiceProviderError> = self.restConnector.request(endpoint)

        return requestPublisher.map( { highlightedEventPointerResponse -> [String] in
            let eventsIds = highlightedEventPointerResponse.data
                .compactMap { fullEvent in
                    return fullEvent.eventId.split(separator: ":").last
                }
                .map(String.init)
            return eventsIds
        })
        .mapError({ error in
            return error
        })
        .eraseToAnyPublisher()

    }

    func getHighlightedLiveEvents(eventCount: Int, userId: String?) -> AnyPublisher<Events, ServiceProviderError> {

        let publisher = self.getHighlightedLiveEventsPointers(eventCount: eventCount, userId: userId) // Get the ids
            .flatMap({ (eventPointers: [String]) -> AnyPublisher<Events, ServiceProviderError> in

                let getEventSummaryRequests: [AnyPublisher<Event?, ServiceProviderError>] = eventPointers
                    .map { (eventId: String) -> AnyPublisher<Event?, ServiceProviderError> in
                        return self.getEventSummary(eventId: eventId, marketLimit: nil) // Get the event summary for each id
                            .map({ Optional<Event>.some($0) })
                            // Replace the errors for nil so we can continue with other requests
                            .catch({ (error: ServiceProviderError) -> AnyPublisher<Event?, ServiceProviderError> in
                                return Just(Optional<Event>.none)
                                    .setFailureType(to: ServiceProviderError.self)
                                    .eraseToAnyPublisher()
                            })
                            .compactMap({ $0 })
                            .eraseToAnyPublisher()
                    }

                let mergedPublishers = Publishers.MergeMany(getEventSummaryRequests) // Combine the publishers
                    .compactMap({ $0 }) //
                    .collect()
                    .map({ validEvents in
                        print("getHighlightedLiveEvents: \(validEvents.count)")
                        return validEvents
                    })
                return mergedPublishers.eraseToAnyPublisher()
            })
        return publisher.eraseToAnyPublisher()
    }

    func subscribeToEventAndSecondaryMarkets(withId id: String) -> AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
    }

}

//
//extension SportRadarEventsProvider: UnsubscriptionController {
//    func getSuggestedBets() -> {
//
//    }
//}
//

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

    private func processMarketFilters(
        marketFilter: MarketFilter,
        match: Event,
        includeMixMatchGroup hasMixMatchGroup: Bool,
        includeAllMarketsGroup hasAllMarketsGroup: Bool
    ) -> [MarketGroup]
    {

        var eventMarkets: [MarketGroupPointer] = []
        var marketGroups: OrderedDictionary<String, MarketGroup> = [:]
        var availableMarkets: [String: [AvailableMarket]] = [:]

        var marketPositions: [String: Int] = [:] //mmarket id : market position

        // NEW PARSE
        for marketFilter in marketFilter.marketFilters {
            let marketGroupKey = (marketFilter.translations?.english ?? "")
            // SPECIFIC MARKET IDS
            var selectedMarketIds: [String] = []

            if let selectedMarketSports = marketFilter.marketsSportType?.marketSports {

                for marketSportType in selectedMarketSports {
                    let eventSportCode = match.sport.alphaId ?? ""
                    for marketSport in marketSportType.value {

                        if eventSportCode.contains(marketSportType.key) || marketSportType.key.lowercased() == "all" {
                            let marketSportId = marketSport.ids[0]
                            let marketPosition = marketSport.marketOrder

                            marketPositions["\(marketGroupKey)-\(marketSportId)"] = marketPosition

                            selectedMarketIds.append(marketSportId)
                        }
                    }
                }
            }
            let id = marketFilter.translations?.english ??  "\(marketFilter.displayOrder)"
            let eventMarket = MarketGroupPointer(id: id,
                                                 name: marketGroupKey,
                                                 marketGroupIds: selectedMarketIds,
                                                 groupOrder: marketFilter.displayOrder)
            eventMarkets.append(eventMarket)
        }

        let matchMarkets = match.markets

        for matchMarket in matchMarkets {

            if let marketFilterId = matchMarket.marketFilterId {

                for eventMarket in eventMarkets {

                    if eventMarket.marketGroupIds.contains(marketFilterId) {

                        if availableMarkets[eventMarket.name] == nil {
                            let availableMarket = AvailableMarket(marketId: matchMarket.id,
                                                                  marketGroupId: eventMarket.id,
                                                                  market: matchMarket,
                                                                  orderGroupOrder: eventMarket.groupOrder)
                            availableMarkets[eventMarket.name] = [availableMarket]
                        }
                        else {
                            let availableMarket = AvailableMarket(marketId: matchMarket.id,
                                                                  marketGroupId: eventMarket.id,
                                                                  market: matchMarket,
                                                                  orderGroupOrder: eventMarket.groupOrder)
                            availableMarkets[eventMarket.name]?.append(availableMarket)
                        }

                    }

                }

                // Add to All Market aswell
                let allEventMarket = eventMarkets.filter({
                    $0.name.lowercased() == "all markets"
                })

                let eventMarket = allEventMarket[0]

                if availableMarkets[eventMarket.name] == nil {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id,
                                                          marketGroupId: eventMarket.id,
                                                          market: matchMarket,
                                                          orderGroupOrder: eventMarket.groupOrder)
                    availableMarkets[eventMarket.name] = [availableMarket]
                }
                else {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id,
                                                          marketGroupId: eventMarket.id,
                                                          market: matchMarket,
                                                          orderGroupOrder: eventMarket.groupOrder)
                    availableMarkets[eventMarket.name]?.append(availableMarket)
                }

            }
            else {
                let allEventMarket = eventMarkets.filter({
                    $0.name.lowercased() == "all markets"
                })

                let eventMarket = allEventMarket[0]
                if availableMarkets[eventMarket.name] == nil {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id,
                                                          marketGroupId: eventMarket.id,
                                                          market: matchMarket,
                                                          orderGroupOrder: eventMarket.groupOrder)
                    availableMarkets[eventMarket.name] = [availableMarket]
                }
                else {
                    let availableMarket = AvailableMarket(marketId: matchMarket.id,
                                                          marketGroupId: eventMarket.id,
                                                          market: matchMarket,
                                                          orderGroupOrder: eventMarket.groupOrder)
                    availableMarkets[eventMarket.name]?.append(availableMarket)
                }
            }
        }

        for availableMarket in availableMarkets {
            let groupMarkets = availableMarket.value
                .map(\.market)

            let sortedMarkets = groupMarkets
                .sorted { lhs, rhs in
                    let lhsKey = "\(availableMarket.key)-\(lhs.marketFilterId ?? "")"
                    let rhsKey = "\(availableMarket.key)-\(rhs.marketFilterId ?? "")"

                    let lhsPosition = marketPositions[lhsKey] ?? 999
                    let rhsPosition = marketPositions[rhsKey] ?? 999

                    return lhsPosition < rhsPosition
                }

            let marketGroup = MarketGroup(type: availableMarket.key,
                                          id: availableMarket.value.first?.marketGroupId ?? "0",
                                          groupKey: "\(availableMarket.value.first?.marketGroupId ?? "0")",
                                          translatedName: availableMarket.key.capitalized,
                                          position: availableMarket.value.first?.orderGroupOrder ?? 120,
                                          isDefault: false,
                                          numberOfMarkets: availableMarket.value.count,
                                          loaded: true,
                                          markets: sortedMarkets)

            marketGroups[availableMarket.key] = marketGroup
        }

        var marketGroupsArray = Array(marketGroups.values)
        var sortedMarketGroupsArray: [MarketGroup]

        // Make sure all markets is last
        if let allMarketsIndex = marketGroupsArray.firstIndex(where: { $0.id.lowercased() == "all markets" }) {
            // Remove "All Markets" from the array
            let allMarketsItem = marketGroupsArray.remove(at: allMarketsIndex)

            // Sort the remaining items
            let remainingItems = marketGroupsArray.sorted(by: {
                if ($0.position ?? 0) == ($1.position ?? 0) {
                    return ($0.groupKey ?? "") < ($1.groupKey ?? "")
                }
                return ($0.position ?? 0) < ($1.position ?? 999)
            })

            // Insert "All Markets" at the start of the sorted array
            // sortedMarketGroupsArray = [allMarketsItem] + remainingItems

            // Now AllMarkets group tab should be in the end
            sortedMarketGroupsArray = remainingItems + [allMarketsItem]

        } else {
            // If "All Markets" is not found, just sort the array as usual
            sortedMarketGroupsArray = marketGroupsArray.sorted(by: {
                if ($0.position ?? 0) == ($1.position ?? 0) {
                    return ($0.groupKey ?? "") < ($1.groupKey ?? "")
                }
                return ($0.position ?? 0) < ($1.position ?? 999)
            })
        }

        // Verify for BetBuilder markets
        let betBuilderMarkets = matchMarkets.filter( {
            $0.customBetAvailable ?? false
        })

        // Only create the MixMatch market group if the feature is enabled
        if hasMixMatchGroup {
            let betBuilderMarketGroup = MarketGroup(type: "MixMatch",
                                                    id: "99",
                                                    groupKey: "99",
                                                    translatedName: "MixMatch",
                                                    position: 99,
                                                    isDefault: false,
                                                    numberOfMarkets: betBuilderMarkets.count,
                                                    loaded: true,
                                                    markets: betBuilderMarkets)

            if sortedMarketGroupsArray.count >= 1 && !betBuilderMarkets.isEmpty {
                sortedMarketGroupsArray.insert(betBuilderMarketGroup, at: 1)
            }
        }

        //self.marketGroupsPublisher.send(sortedMarketGroupsArray)
        return sortedMarketGroupsArray
    }

    func getDatesFilter(timeRange: String) -> [Date] {
        var dates = [Date]()

        let days = timeRange.components(separatedBy: "-")

        if let initialDay = Int(days[safe: 0] ?? "0"),
           let endDay = Int(days[safe: 1] ?? "90") {
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

    func getValidLiveEventDetailsCoordinators() -> [SportRadarLiveEventDataCoordinator] {
        self.liveEventDetailsCoordinators = self.liveEventDetailsCoordinators.filter({ $0.value.isActive })
        return Array(self.liveEventDetailsCoordinators.values)
    }

    func getValidLiveEventDetailsCoordinator(forKey key: String) -> SportRadarLiveEventDataCoordinator? {
        self.liveEventDetailsCoordinators = self.liveEventDetailsCoordinators.filter({ $0.value.isActive })
        return self.liveEventDetailsCoordinators[key]
    }

    func addLiveEventDetailsCoordinator(_ coordinator: SportRadarLiveEventDataCoordinator, withKey key: String) {
        self.liveEventDetailsCoordinators = self.liveEventDetailsCoordinators.filter({ $0.value.isActive })
        self.liveEventDetailsCoordinators[key] = coordinator
    }

}

extension SportRadarEventsProvider {

    func getValidEventMarketsCoordinators() -> [SportRadarEventMarketsCoordinator] {

        let oldList = self.eventsSecundaryMarketsUpdatesCoordinators
        let newValidList = oldList.filter({ coordinatorPair in
            coordinatorPair.value.isActive
        })

        self.eventsSecundaryMarketsUpdatesCoordinators = newValidList

        return Array(self.eventsSecundaryMarketsUpdatesCoordinators.values)
    }

    func getValidEventMarketsCoordinator(forKey key: String) -> SportRadarEventMarketsCoordinator? {
        self.eventsSecundaryMarketsUpdatesCoordinators = self.eventsSecundaryMarketsUpdatesCoordinators.filter({ $0.value.isActive })
        return self.eventsSecundaryMarketsUpdatesCoordinators[key]
    }

    func addEventMarketsCoordinator(_ coordinator: SportRadarEventMarketsCoordinator, withKey key: String) {
        self.eventsSecundaryMarketsUpdatesCoordinators = self.eventsSecundaryMarketsUpdatesCoordinators.filter({ $0.value.isActive })
        self.eventsSecundaryMarketsUpdatesCoordinators[key] = coordinator
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
