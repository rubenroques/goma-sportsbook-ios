//
//  File.swift
//  
//
//  Created by Ruben Roques on 01/03/2023.
//

import Foundation
import Combine

class SportRadarEventDetailsCoordinator {

    var storage: SportRadarEventStorage
    var sessionToken: String

    let eventDetailsIdentifier: ContentIdentifier
    let liveDataContentIdentifier: ContentIdentifier
    
    weak var liveDataSubscription: Subscription?
    
    weak var marketsSubscription: Subscription?
    
    var isActive: Bool {
        if self.waitingSubscription {
            // We haven't tried to subscribe or the
            // subscribe request it's ongoing right now
            return true
        }
        return self.marketsSubscription != nil
    }

    var eventDetailsPublisher: AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return eventDetailsCurrentValueSubject
            .eraseToAnyPublisher()
    }

    private var eventDetailsCurrentValueSubject: CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError> = .init(.disconnected)
    
    private var waitingSubscription = true
    private let decoder = JSONDecoder()
    private let session = URLSession.init(configuration: .default)
    
    private var cancellables = Set<AnyCancellable>()

    init(matchId: String, sessionToken: String, storage: SportRadarEventStorage) {
        self.sessionToken = sessionToken
        self.storage = storage

        let eventDetailsType = ContentType.eventDetails
        let eventDetailsRoute = ContentRoute.eventDetails(eventId: matchId)
        let eventDetailsIdentifier = ContentIdentifier(contentType: eventDetailsType, contentRoute: eventDetailsRoute)

        self.eventDetailsIdentifier = eventDetailsIdentifier

        let liveDataContentType = ContentType.eventDetailsLiveData
        let liveDataContentRoute = ContentRoute.eventDetailsLiveData(eventId: matchId)
        let liveDataContentIdentifier = ContentIdentifier(contentType: liveDataContentType, contentRoute: liveDataContentRoute)

        self.liveDataContentIdentifier = liveDataContentIdentifier

        //DEBUG SUBS
        self.eventDetailsPublisher.sink { completion in
            
        } receiveValue: { subscribableContent in
            switch subscribableContent {
            case .connected(let subscription):
                print("LiveBug Event: connected")
            case .contentUpdate(let event):
                print("LiveBug Event: \(event.id) - \(String(describing: event.status))")
            case .disconnected:
                print("LiveBug Event: disconnected")
            }
        }
        .store(in: &self.cancellables)
        
        
        // Boot the coordinator
        self.checkEventDetailsAvailable()
            .flatMap { [weak self] _ -> AnyPublisher<Void, ServiceProviderError>  in
                guard let self = self else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
                return self.subscribeEventDetails()
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    let subscription = Subscription(contentIdentifier: self.eventDetailsIdentifier,
                                                    sessionToken: self.sessionToken,
                                                    unsubscriber: self)
                    self.eventDetailsCurrentValueSubject.send(.connected(subscription: subscription))
                    self.marketsSubscription = subscription
                    
                    
                    // try to get live data
                    self.requestEventLiveData()
                    
                case .failure(let error):
                    self.eventDetailsCurrentValueSubject.send(completion: .failure(error))
                }
                self.waitingSubscription = false
            } receiveValue: { _ in
            }
            .store(in: &self.cancellables)

    }

    deinit {
    }
    
    private func checkEventDetailsAvailable() -> AnyPublisher<Void, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.get(contentIdentifier: self.eventDetailsIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return self.session.dataTaskPublisher(for: request)
            .map({ response in
                return String(data: response.data, encoding: .utf8) ?? ""
            })
            .mapError({ error in
                return ServiceProviderError.resourceUnavailableOrDeleted
            })
            .flatMap { responseString -> AnyPublisher<Void, ServiceProviderError> in
                if responseString.uppercased().contains("CONTENT_NOT_FOUND") {
                    return Fail(outputType: Void.self, failure: ServiceProviderError.resourceUnavailableOrDeleted).eraseToAnyPublisher()
                }
                else {
                    return Just(()).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

    }

    func subscribeEventDetails() -> AnyPublisher<Void, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.eventDetailsIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
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
            .eraseToAnyPublisher()
    }
        
    func requestEventLiveData() {
        let publisher = CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError>.init(.disconnected)
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.liveDataContentIdentifier)
        guard
            let request = endpoint.request()
        else {
            return
        }

        print("LoadingBug requestEventLiveData")
        let sessionDataTask = self.session.dataTask(with: request) { data, response, error in
            guard
                (error == nil),
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                print("LoadingBug requestEventLiveData not found")
                return
            }
            let subscription = Subscription(contentIdentifier: self.liveDataContentIdentifier,
                                            sessionToken: self.sessionToken,
                                            unsubscriber: self)
            self.liveDataSubscription = subscription
            self.marketsSubscription?.associateSubscription(subscription)
            print("LoadingBug requestEventLiveData found")
        }

        sessionDataTask.resume()
    }

    func updateEventDetails(_ updatedEvent: Event, forContentIdentifier contentIdentifier: ContentIdentifier) {
        print("ServiceProvider SportRadarEventDetailsCoordinator updateEventDetails \(eventDetailsIdentifier) \(liveDataContentIdentifier)")

        if contentIdentifier == self.liveDataContentIdentifier || contentIdentifier == self.eventDetailsIdentifier {
            self.storage.storeEvent(updatedEvent)
            self.eventDetailsCurrentValueSubject.send(.contentUpdate(content: updatedEvent))
        }
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        self.sessionToken = newSessionToken
        self.storage.reset()

        //
        //
        let marketsEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                contentIdentifier: self.eventDetailsIdentifier)

        guard let marketsRequest = marketsEndpoint.request() else { return }
        let marketsSessionDataTask = self.session.dataTask(with: marketsRequest) { data, response, error in
            if let error {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.eventDetailsIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.eventDetailsIdentifier) data \(dataString)")
            }
        }
        marketsSessionDataTask.resume()

        //
        //
        let liveDataEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                 contentIdentifier: self.liveDataContentIdentifier)

        guard let liveDataRequest = liveDataEndpoint.request() else { return }
        let liveDataSessionDataTask = self.session.dataTask(with: liveDataRequest) { data, response, error in
            if let error {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.liveDataContentIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.liveDataContentIdentifier) data \(dataString)")
            }
        }
        liveDataSessionDataTask.resume()
    }

}


extension SportRadarEventDetailsCoordinator {

    func updatedLiveData(eventLiveDataExtended: SportRadarModels.EventLiveDataExtended, forContentIdentifier contentIdentifier: ContentIdentifier) {

        guard
            contentIdentifier == self.liveDataContentIdentifier ||  contentIdentifier == self.eventDetailsIdentifier
        else {
            return
        }

        if let newStatus = eventLiveDataExtended.status?.stringValue {
            self.storage.updateEventStatus(newStatus: newStatus)
        }
        if let newTime = eventLiveDataExtended.matchTime {
            self.storage.updateEventTime(newTime: newTime)
        }

        self.storage.updateEventScore(newHomeScore: eventLiveDataExtended.homeScore, newAwayScore: eventLiveDataExtended.awayScore)

        if let storedEvent = self.storage.storedEvent() {
            self.eventDetailsCurrentValueSubject.send(.contentUpdate(content: storedEvent))
        }
        
    }

    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {

//        guard
//            let updatedContentIdentifier = content.contentIdentifier
//        else {
//            // ignoring contentIdentifierLess updates
//            // print("☁️SP debugdetails ignoring contentIdentifierLess \(content)")
//            return
//        }
//
//        if self.eventDetailsIdentifier != updatedContentIdentifier && self.liveDataContentIdentifier != updatedContentIdentifier {
//            // ignoring this update, not subscribed by this class
//            // print("☁️SP debugdetails ignoring \(updatedContentIdentifier) != \(eventDetailsIdentifier) \(liveDataContentIdentifier)")
//            return
//        }

        // print("☁️SP debugdetails SportRadarEventDetailsCoordinator handleContentUpdate \(content)")

        switch content {

        // Odds
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)
        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            self.storage.updateOutcomeTradability(withId: selectionId, isTradable: isTradable)

        // Live Data
        case .updateEventLiveDataExtended(_, _, let eventLiveDataExtended):
            if let newTime = eventLiveDataExtended.matchTime {
                self.storage.updateEventTime(newTime: newTime)
            }
            if let newStatus = eventLiveDataExtended.status {
                self.storage.updateEventStatus(newStatus: newStatus.stringValue)
            }
            self.storage.updateEventScore(newHomeScore: eventLiveDataExtended.homeScore, newAwayScore: eventLiveDataExtended.awayScore)

        case .updateEventState(_, _, let newStatus):
            self.storage.updateEventStatus(newStatus: newStatus)
            
        case .updateEventTime(_, _, let newTime):
            self.storage.updateEventTime(newTime: newTime)
        case .updateEventScore(_, _, let homeScore, let awayScore):
            self.storage.updateEventScore(newHomeScore: homeScore, newAwayScore: awayScore)

        // Markets
        case .updateMarketTradability(_, let marketId, let isTradable):
            self.storage.updateMarketTradability(withId: marketId, isTradable: isTradable)

        case .addMarket(_, let market):
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


//        case .removeEvent(_, let eventId):
//            self.storage.removedEvent(withId: eventId)

        default:
            () // Ignore other cases
        }
    }
}

extension SportRadarEventDetailsCoordinator {

    func subscribeToEventLiveDataUpdates(withId id: String) -> AnyPublisher<Event?, Never> {
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

extension SportRadarEventDetailsCoordinator: UnsubscriptionController {

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
