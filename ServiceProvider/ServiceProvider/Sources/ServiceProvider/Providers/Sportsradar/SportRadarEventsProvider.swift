//
//  SportRadarEventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

class SportRadarEventsProvider: EventsProvider {

    var connector: SportRadarConnector
    
    required init(connector: SportRadarConnector) {
        self.connector = connector
    }
    
    private var liveSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>?
    private var liveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var allSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?
    private var preLiveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
//    private var popularEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
//    private var upcomingEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    
    func unsubscribeLiveMatches(forSportType sportType: SportType) {
        if let liveEventsPublisher = self.liveEventsPublisher {
            liveEventsPublisher.send(.disconnected)
        }
        
        self.liveEventsPublisher = nil
    }
    
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
                
//        if self.liveEventsPublisher == nil {
//            self.liveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
//        }
//        else {
//            return self.liveEventsPublisher?.eraseToAnyPublisher()
//        }

        self.liveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
        
        guard
            let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sessionToken = connector.token
        else {
            return nil
        }
        
        let contentType = SportRadarModels.ContentType.liveAdvancedList
        let pageIndex = 0
        let contentId = "\(sportId)/\(pageIndex)" // FBL/0 -> /0 means page 0 of pagination
        
        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        var request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("URLSession shared dataTask error \(error)")
                self.liveEventsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                self.liveEventsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            
            print("liveDataSummaryAdvancedListBySportType - recieved")
            
            self.liveEventsPublisher?.send(.connected)
        }
        
        self.connector.subscribe(self, forContentType: .liveAdvancedList)
        
        sessionDataTask.resume()
        
        print("liveDataSummaryAdvancedListBySportType - requested")
        
        return self.liveEventsPublisher?.eraseToAnyPublisher()
    }
    
    func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>? {
        if self.liveSportTypesPublisher == nil {
            self.liveSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>.init(.disconnected)
        }
        else {
            return self.liveSportTypesPublisher?.eraseToAnyPublisher()
        }
        
        guard let sessionToken = connector.token else { return nil }
        
        let contentType = SportRadarModels.ContentType.inplaySportList
        
        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType)
        var request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.liveSportTypesPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                self.liveSportTypesPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            self.liveSportTypesPublisher?.send(.connected)
        }
        self.connector.subscribe(self, forContentType: .inplaySportList)
        sessionDataTask.resume()
        return self.liveSportTypesPublisher?.eraseToAnyPublisher()
        
    }

    func allSportTypes(dateRangeId: String) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>? {
        if self.allSportTypesPublisher == nil {
            self.allSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
        }
        else {
            return self.allSportTypesPublisher?.eraseToAnyPublisher()
        }

        guard let sessionToken = connector.token else { return nil }

        let contentType = SportRadarModels.ContentType.sportTypeByDate

        // Today sports ID
        let contentId = dateRangeId

        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        var request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.allSportTypesPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                self.allSportTypesPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            self.allSportTypesPublisher?.send(.connected)
        }
        self.connector.subscribe(self, forContentType: .sportTypeByDate)
        sessionDataTask.resume()
        return self.allSportTypesPublisher?.eraseToAnyPublisher()

    }

    func unsubscribeAllSportTypes() {
        self.connector.unsubscribe(forContentType: .sportTypeByDate)

        if let allSportTypesPublisher = self.allSportTypesPublisher {
            allSportTypesPublisher.send(.disconnected)
        }

        self.allSportTypesPublisher = nil
    }

//    func subscribeMatchesByDate(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
//
//
//    }

    func subscribePreLiveMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {

        self.preLiveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
            let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sessionToken = connector.token
        else {
            return nil
        }

        let contentType = SportRadarModels.ContentType.eventListBySportTypeDate
        let pageIndex = 0
        let eventsNumber = 20
        let contentId = "\(sportId)/\(dateRangeId)/\(pageIndex)/\(eventsNumber)/\(sortType)" // FBL/202210210000/202210212359/0/20/T: example content ID

        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        var request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("URLSession shared dataTask error \(error)")
                self.preLiveEventsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                self.preLiveEventsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            print("eventListBySportTypeDate Popular - received")

            self.preLiveEventsPublisher?.send(.connected)
        }

        self.connector.subscribe(self, forContentType: .eventListBySportTypeDate)

        sessionDataTask.resume()

        print("eventListBySportTypeDate Popular - requested")

        return self.preLiveEventsPublisher?.eraseToAnyPublisher()
    }

    func unsubscribePreLiveMatches() {
        self.connector.unsubscribe(forContentType: .eventListBySportTypeDate)

        if let preLiveEventsPublisher = self.preLiveEventsPublisher {
            preLiveEventsPublisher.send(.disconnected)
        }

        self.preLiveEventsPublisher = nil
    }

//    func subscribeUpcomingMatches(forSportType sportType: SportType, dateRangeId: String, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
//
//        self.upcomingEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
//
//        guard
//            let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
//            let sessionToken = connector.token
//        else {
//            return nil
//        }
//
//        let contentType = SportRadarModels.ContentType.eventListBySportTypeDate
//        let pageIndex = 0
//        let eventsNumber = 20
//        let contentId = "\(sportId)/\(dateRangeId)/\(pageIndex)/\(eventsNumber)/\(sortType)" // FBL/202210210000/202210212359/0/20/T: example content ID
//
//        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
//        var request = self.createSubscribeRequest(withHTTPBody: bodyData)
//        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            if let error = error {
//                print("URLSession shared dataTask error \(error)")
//                self.upcomingEventsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
//                return
//            }
//
//            guard
//                let httpResponse = response as? HTTPURLResponse,
//                (200...299).contains(httpResponse.statusCode)
//            else {
//                self.upcomingEventsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
//                return
//            }
//
//            print("eventListBySportTypeDate Upcoming - received")
//
//            self.upcomingEventsPublisher?.send(.connected)
//        }
//
//        self.connector.subscribe(self, forContentType: .eventListBySportTypeDate)
//
//        sessionDataTask.resume()
//
//        print("eventListBySportTypeDate Upcoming - requested")
//
//        return self.upcomingEventsPublisher?.eraseToAnyPublisher()
//    }
//
//    func unsubscribeUpcomingMatches() {
//        self.connector.unsubscribe(forContentType: .eventListBySportTypeDate)
//
//        if let upcomingEventsPublisher = self.upcomingEventsPublisher {
//            upcomingEventsPublisher.send(.disconnected)
//        }
//
//        self.upcomingEventsPublisher = nil
//    }
   
}

extension SportRadarEventsProvider: SportRadarConnectorSubscriber {

    func liveAdvancedListUpdated(forSportType sportType: SportType, withEvents events: [EventsGroup]) {
        if let liveEventsPublisher = self.liveEventsPublisher {
            liveEventsPublisher.send(.content(events))
        }
    }
    
    func inplaySportListUpdated(withSportTypesDetails sportTypesDetails: [SportTypeDetails]) {
        if let liveSportTypesPublisher = self.liveSportTypesPublisher {
            liveSportTypesPublisher.send(.content(sportTypesDetails))
        }
    }

    func eventListBySportTypeDate(forSportType sportType: SportType, withEvents events: [EventsGroup]) {
        if let preLiveEventsPublisher = self.preLiveEventsPublisher {
            preLiveEventsPublisher.send(.content(events))
        }
    }


    func sportTypeByDate(withSportTypes sportTypes: [SportType]) {
        if let allSportTypesPublisher = self.allSportTypesPublisher {
            allSportTypesPublisher.send(.content(sportTypes))
        }
    }

//    func popularEventListBySportTypeDate(forSportType sportType: SportType, withEvents events: [EventsGroup]) {
//        if let popularEventsByDatePublisher = self.popularEventsPublisher {
//            popularEventsByDatePublisher.send(.content(events))
//        }
//    }
//
//    func upcomingEventListBySportTypeDate(forSportType sportType: SportType, withEvents events: [EventsGroup]) {
//        if let upcomingEventsByDatePublisher = self.upcomingEventsPublisher {
//            upcomingEventsByDatePublisher.send(.content(events))
//        }
//    }
    
}


extension SportRadarEventsProvider {
    
    private func createPayloadData(with sessionAccessToken: SessionAccessToken, contentType: SportRadarModels.ContentType, contentId: String = "") -> Data {
        let bodyString =
        """
        {
            "subscriberId": "\(sessionAccessToken.hash)",
            "contentId": {
                "type": "\(contentType.rawValue)",
                "id": "\(contentId)"
            },
            "clientContext": {
                "language": "UK",
                "ipAddress": "127.0.0.1"
            }
        }
        """
        return bodyString.data(using: String.Encoding.utf8) ?? Data()
    }
    
    private func createSubscribeRequest(withHTTPBody body: Data? = nil) -> URLRequest {
        let url = URL(string: "https://www-sportbook-goma-int.optimahq.com/services/content/subscribe")!
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
