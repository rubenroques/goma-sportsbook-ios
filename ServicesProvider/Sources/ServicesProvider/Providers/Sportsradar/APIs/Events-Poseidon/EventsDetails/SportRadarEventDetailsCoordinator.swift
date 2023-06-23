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

    let marketsContentIdentifier: ContentIdentifier
    let liveDataContentIdentifier: ContentIdentifier

    weak var marketsSubscription: Subscription?
    var isActive: Bool {
        return self.marketsSubscription != nil
    }

    weak var liveDataSubscription: Subscription?

    var eventDetailsPublisher: AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return eventDetailsCurrentValueSubject.eraseToAnyPublisher()
    }

    private var eventDetailsCurrentValueSubject: CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError> = .init(.disconnected)

    private var cancellables = Set<AnyCancellable>()

    init(matchId: String, sessionToken: String, storage: SportRadarEventDetailsStorage) {
        self.sessionToken = sessionToken
        self.storage = storage

        let marketsContentType = ContentType.eventDetails
        let marketsContentRoute = ContentRoute.eventDetails(eventId: matchId)
        let marketsContentIdentifier = ContentIdentifier(contentType: marketsContentType, contentRoute: marketsContentRoute)

        self.marketsContentIdentifier = marketsContentIdentifier

        let liveDataContentType = ContentType.eventDetailsLiveData
        let liveDataContentRoute = ContentRoute.eventDetailsLiveData(eventId: matchId)
        let liveDataContentIdentifier = ContentIdentifier(contentType: liveDataContentType, contentRoute: liveDataContentRoute)

        self.liveDataContentIdentifier = liveDataContentIdentifier

        self.requestEventDetails()

        self.eventDetailsPublisher
            .sink { _ in

            } receiveValue: { [weak self] subscribableContent in
                if case .connected = subscribableContent {
                    self?.requestEventLiveData()
                }
            }
            .store(in: &self.cancellables)

    }

    func requestEventDetails() {
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.marketsContentIdentifier)
        guard
            let request = endpoint.request()
        else {
            self.eventDetailsCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe))
            return
        }

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                (error == nil),
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                dump(error, name: "SportRadarEventDetailsCoordinator requestEventDetails error", maxDepth: 3)
                dump(response, name: "SportRadarEventDetailsCoordinator requestEventDetails error", maxDepth: 3)
                self.eventDetailsCurrentValueSubject.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            let subscription = Subscription(contentIdentifier: self.marketsContentIdentifier,
                                            sessionToken: self.sessionToken,
                                            unsubscriber: self)
            self.eventDetailsCurrentValueSubject.send(.connected(subscription: subscription))
            self.marketsSubscription = subscription
        }
        sessionDataTask.resume()
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

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                (error == nil),
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("SportRadarEventDetailsCoordinator: requestEventLiveData")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            let subscription = Subscription(contentIdentifier: self.liveDataContentIdentifier,
                                            sessionToken: self.sessionToken,
                                            unsubscriber: self)
            self.liveDataSubscription = subscription
            self.marketsSubscription?.associateSubscription(subscription)
        }

        sessionDataTask.resume()
    }

    func updateEventDetails(_ updatedEvent: Event) {
        print("☁️SP debugbetslip updateEventDetails SportRadarEventDetailsCoordinator \(marketsContentIdentifier) \(liveDataContentIdentifier)")

        self.storage.storeEvent(updatedEvent)
        self.eventDetailsCurrentValueSubject.send(.contentUpdate(content: updatedEvent))
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        self.sessionToken = newSessionToken
        self.storage.reset()

        //
        //
        let marketsEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                contentIdentifier: self.marketsContentIdentifier)

        guard let marketsRequest = marketsEndpoint.request() else { return }
        let marketsSessionDataTask = URLSession.shared.dataTask(with: marketsRequest) { data, response, error in
            if let error {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.marketsContentIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.marketsContentIdentifier) data \(dataString)")
            }
        }
        marketsSessionDataTask.resume()

        //
        //
        let liveDataEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                 contentIdentifier: self.liveDataContentIdentifier)

        guard let liveDataRequest = liveDataEndpoint.request() else { return }
        let liveDataSessionDataTask = URLSession.shared.dataTask(with: liveDataRequest) { data, response, error in
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

    func updatedLiveData(eventLiveDataExtended: SportRadarModels.EventLiveDataExtended) {

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

        guard
            let updatedContentIdentifier = content.contentIdentifier
        else {
            // ignoring contentIdentifierLess updates
            // print("☁️SP debugdetails ignoring contentIdentifierLess \(content)")
            return
        }

        if self.marketsContentIdentifier != updatedContentIdentifier && self.liveDataContentIdentifier != updatedContentIdentifier {
            // ignoring this update, not subscribed by this class
            // print("☁️SP debugdetails ignoring \(updatedContentIdentifier) != \(marketsContentIdentifier) \(liveDataContentIdentifier)")
            return
        }

        // print("☁️SP debugdetails SportRadarEventDetailsCoordinator handleContentUpdate \(content)")

        switch content {

        // Odds
        case .updateOutcomeOdd(_, let selectionId, let newOddNumerator, let newOddDenominator):
            self.storage.updateOutcomeOdd(withId: selectionId, newOddNumerator: newOddNumerator, newOddDenominator: newOddDenominator)
        case .updateOutcomeTradability(_, let selectionId, let isTradable):
            self.storage.updateOutcomeTradability(withId: selectionId, isTradable: isTradable)

        // Live Data
        case .updateEventLiveDataExtended(_, let eventId, let eventLiveDataExtended):
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

    func setupEvent(withId id: String) {
        self.storage.setEventSubject(eventId: id)
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
