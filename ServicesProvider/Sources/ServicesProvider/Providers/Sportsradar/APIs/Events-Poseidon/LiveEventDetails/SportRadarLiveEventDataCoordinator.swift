//
//  File.swift
//  
//
//  Created by Ruben Roques on 14/10/2023.
//

import Foundation
import Combine

//
// This class subscribes only to the Live details of the event.
class SportRadarLiveEventDataCoordinator {

    var sessionToken: String

    let liveEventContentIdentifier: ContentIdentifier

    weak var subscription: Subscription?
    var isActive: Bool {
        if self.waitingSubscription {
            // We haven't tried to subscribe or the
            // subscribe request it's ongoing right now
            return true
        }
        return self.subscription != nil
    }

    var eventLiveDataPublisher: AnyPublisher<SubscribableContent<EventLiveData>, ServiceProviderError> {
        return liveEventCurrentValueSubject.eraseToAnyPublisher()
    }

    private var liveEventCurrentValueSubject: CurrentValueSubject<SubscribableContent<EventLiveData>, ServiceProviderError> = .init(.disconnected)
    
    private var eventLiveData: EventLiveData? {
        set {
            if let eventLiveData = newValue {
                self.liveEventCurrentValueSubject.send(.contentUpdate(content: eventLiveData))
            }
        }
        get {
            switch self.liveEventCurrentValueSubject.value {
            case .disconnected, .connected:
                return nil
            case .contentUpdate(let eventLiveDataValue):
                return eventLiveDataValue
            }
        }
    }
    
    private let eventIdObserved: String
    private var waitingSubscription = true
    private let decoder = JSONDecoder()
    private let session = URLSession.init(configuration: .default)
    
    private var cancellables = Set<AnyCancellable>()

    init(eventId: String, sessionToken: String, storage: SportRadarEventStorage) {
        print("LoadingBug ledc 1")
        self.eventIdObserved = eventId
        
        self.sessionToken = sessionToken

        let liveDataContentType = ContentType.eventDetailsLiveData
        let liveDataContentRoute = ContentRoute.eventDetailsLiveData(eventId: eventId)
        let liveDataContentIdentifier = ContentIdentifier(contentType: liveDataContentType, contentRoute: liveDataContentRoute)

        self.liveEventContentIdentifier = liveDataContentIdentifier

        self.waitingSubscription = true
        
        // Boot the coordinator
        self.checkLiveEventDetailsAvailable()
            .flatMap { [weak self] _ -> AnyPublisher<Bool, ServiceProviderError>  in
                guard let self = self else {
                    return Fail(error: ServiceProviderError.onSubscribe).eraseToAnyPublisher()
                }
                
                let subscription = Subscription(contentIdentifier: self.liveEventContentIdentifier,
                                                sessionToken: self.sessionToken,
                                                unsubscriber: self)
                self.liveEventCurrentValueSubject.send(.connected(subscription: subscription))
                self.subscription = subscription
                
                self.waitingSubscription = false
                
                return self.subscribeLiveEventDetails()
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                   break
                case .failure(let error):
                    self.liveEventCurrentValueSubject.send(completion: .failure(error))
                }
                self.waitingSubscription = false
            } receiveValue: { [weak self] success in
                // Publish the event live details
            }
            .store(in: &self.cancellables)

    }

    private func checkLiveEventDetailsAvailable() -> AnyPublisher<Void, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.get(contentIdentifier: self.liveEventContentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }

        return self.session.dataTaskPublisher(for: request)
            .retry(1)
            .map({ return String(data: $0.data, encoding: .utf8) ?? "" })
            .mapError({ _ in return ServiceProviderError.resourceUnavailableOrDeleted })
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

    func subscribeLiveEventDetails() -> AnyPublisher<Bool, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                         contentIdentifier: self.liveEventContentIdentifier)

        guard
            let request = endpoint.request()
        else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
        return self.session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw ServiceProviderError.onSubscribe
                }
                return data
            }
            .tryMap { data in
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let version = json["version"] as? Int {
                            return version
                        }
                    }
                    throw ServiceProviderError.invalidResponse
                } catch {
                    throw ServiceProviderError.invalidResponse
                }
            }
            .map { version in
                return version != 0
            }
            .mapError { error in
                if let typedError = error as? ServiceProviderError {
                    return typedError
                }
               return ServiceProviderError.onSubscribe
            }
            .eraseToAnyPublisher()
    }

    func reconnect(withNewSessionToken newSessionToken: String) {
        self.sessionToken = newSessionToken

        //
        //
        let marketsEndpoint = SportRadarRestAPIClient.subscribe(sessionToken: self.sessionToken,
                                                                contentIdentifier: self.liveEventContentIdentifier)

        guard let marketsRequest = marketsEndpoint.request() else { return }
        let marketsSessionDataTask = self.session.dataTask(with: marketsRequest) { data, response, error in
            if let error {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.liveEventContentIdentifier) error \(error)")
            }
            if let data, let dataString = String(data: data, encoding: .utf8) {
                print("SportRadarEventDetailsCoordinator: reconnect dataTask contentIdentifier \(self.liveEventContentIdentifier) data \(dataString)")
            }
        }
        marketsSessionDataTask.resume()

    }

}


extension SportRadarLiveEventDataCoordinator {

    func updateEventStatus(newStatus: String) {
        guard var event = self.eventLiveData else { return }
        event.status = EventStatus(value: newStatus)
        self.eventLiveData = event
    }

    func updateEventTime(newTime: String) {
        guard var event = self.eventLiveData else { return }
        event.matchTime = newTime
        self.eventLiveData = event
    }

    func updateEventScore(newHomeScore: Int?, newAwayScore: Int?) {
        guard var event = self.eventLiveData else { return }
        if let newHomeScoreValue = newHomeScore {
            event.homeScore = newHomeScoreValue
        }
        if let newAwayScoreValue = newAwayScore {
            event.awayScore = newAwayScoreValue
        }
        self.eventLiveData = event
    }
    
    func updatedLiveData(eventLiveDataExtended: SportRadarModels.EventLiveDataExtended, forContentIdentifier contentIdentifier: ContentIdentifier) {

        guard
            contentIdentifier == self.liveEventContentIdentifier
        else {
            return
        }

        if let newStatus = eventLiveDataExtended.status?.stringValue {
            self.updateEventStatus(newStatus: newStatus)
        }
        if let newTime = eventLiveDataExtended.matchTime {
            self.updateEventTime(newTime: newTime)
        }

        self.updateEventScore(newHomeScore: eventLiveDataExtended.homeScore, newAwayScore: eventLiveDataExtended.awayScore)

        let mappedEventLiveData = SportRadarModelMapper.eventLiveData(fromInternalEventLiveData: eventLiveDataExtended)
        self.eventLiveData = mappedEventLiveData
    }

    func handleContentUpdate(_ content: SportRadarModels.ContentContainer) {

        guard
            let updatedContentIdentifier = content.contentIdentifier,
            self.liveEventContentIdentifier == updatedContentIdentifier
        else {
            return
        }

        switch content {
        case .updateEventLiveDataExtended(_, _, let eventLiveDataExtended):
            if let newTime = eventLiveDataExtended.matchTime {
                self.updateEventTime(newTime: newTime)
            }
            if let newStatus = eventLiveDataExtended.status {
                self.updateEventStatus(newStatus: newStatus.stringValue)
            }
            self.updateEventScore(newHomeScore: eventLiveDataExtended.homeScore, newAwayScore: eventLiveDataExtended.awayScore)
        default:
            break // Ignore other cases
        }
    }
    
    func containsEvent(withid id: String) -> Bool {
        return self.eventIdObserved == id
    }
    
}

extension SportRadarLiveEventDataCoordinator: UnsubscriptionController {

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
