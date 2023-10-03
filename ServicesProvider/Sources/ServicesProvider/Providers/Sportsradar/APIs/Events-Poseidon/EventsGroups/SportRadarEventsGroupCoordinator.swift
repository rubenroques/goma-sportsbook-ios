//
//  File.swift
//  
//
//  Created by Ruben Roques on 01/03/2023.
//

import Foundation
import Combine

class SportRadarEventsGroupCoordinator {

    var storage: SportRadarEventsGroupStorage
    var sessionToken: String

    let eventsGroupIdentifier: ContentIdentifier

    weak var marketsSubscription: Subscription?
    var isActive: Bool {
        return self.marketsSubscription != nil
    }

    var eventsGroupPublisher: AnyPublisher<SubscribableContent<Event>, ServiceProviderError> {
        return eventsGroupCurrentValueSubject.eraseToAnyPublisher()
    }

    private var eventsGroupCurrentValueSubject: CurrentValueSubject<SubscribableContent<Event>, ServiceProviderError> = .init(.disconnected)

    private let decoder = JSONDecoder()
    private let session = URLSession.init(configuration: .default)
    
    private var cancellables = Set<AnyCancellable>()

    init(eventsGroupId: String, sessionToken: String, storage: SportRadarEventsGroupStorage) {
        self.sessionToken = sessionToken
        self.storage = storage

        let eventsGroupType = ContentType.eventGroup
        let eventsGroupRoute = ContentRoute.eventGroup(marketGroupId: eventsGroupId)
        let eventsGroupIdentifier = ContentIdentifier(contentType: eventsGroupType, contentRoute: eventsGroupRoute)

        self.eventsGroupIdentifier = eventsGroupIdentifier

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
                    let subscription = Subscription(contentIdentifier: self.eventsGroupIdentifier,
                                                    sessionToken: self.sessionToken,
                                                    unsubscriber: self)
                    self.eventsGroupCurrentValueSubject.send(.connected(subscription: subscription))
                    self.marketsSubscription = subscription
                    
                case .failure(let error):
                    self.eventsGroupCurrentValueSubject.send(completion: .failure(error))
                }
            } receiveValue: { _ in }
            .store(in: &self.cancellables)

    }

    private func checkEventDetailsAvailable() -> AnyPublisher<Void, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.get(contentIdentifier: self.eventsGroupIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return self.session.dataTaskPublisher(for: request)
            .retry(1)
            .map({ return String(data: $0.data, encoding: .utf8) ?? "" })
            .mapError({ _ in return ServiceProviderError.invalidRequestFormat })
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
                                                         contentIdentifier: self.eventsGroupIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return self.session.dataTaskPublisher(for: request)
            .retry(1) // 
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
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

    func updateEventDetails(_ updatedEvent: Event, forContentIdentifier contentIdentifier: ContentIdentifier) {
        print("ServiceProvider SportRadarEventsGroupCoordinator update \(eventsGroupIdentifier) ")

        if contentIdentifier == self.eventsGroupIdentifier {
            self.storage.storeEvent(updatedEvent)
            self.eventsGroupCurrentValueSubject.send(.contentUpdate(content: updatedEvent))
        }
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        self.sessionToken = newSessionToken
        self.storage.reset()

        //
        //
        let marketsEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                contentIdentifier: self.eventsGroupIdentifier)

        guard let marketsRequest = marketsEndpoint.request() else { return }
        let marketsSessionDataTask = self.session.dataTask(with: marketsRequest) { data, response, error in
            if let error {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.eventsGroupIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.eventsGroupIdentifier) data \(dataString)")
            }
        }
        marketsSessionDataTask.resume()

    }

}


extension SportRadarEventsGroupCoordinator {

    func updatedLiveData(eventLiveDataExtended: SportRadarModels.EventLiveDataExtended, forContentIdentifier contentIdentifier: ContentIdentifier) {

        guard
            contentIdentifier == self.eventsGroupIdentifier
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
            self.eventsGroupCurrentValueSubject.send(.contentUpdate(content: storedEvent))
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

        if self.eventsGroupIdentifier != updatedContentIdentifier {
            // ignoring this update, not subscribed by this class
            // print("☁️SP debugdetails ignoring \(updatedContentIdentifier) != \(eventsGroupIdentifier) \(liveDataContentIdentifier)")
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

extension SportRadarEventsGroupCoordinator {

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

extension SportRadarEventsGroupCoordinator: UnsubscriptionController {

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
