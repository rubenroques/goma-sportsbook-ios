//
//  SportRadarEventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

class SportRadarEventsProvider: EventsProvider {

    var connector: SportRadarSocketConnector
    private var networkManager: NetworkManager

    required init(sessionCoordinator: SportRadarSessionCoordinator, connector: SportRadarSocketConnector) {
        self.connector = connector
        self.networkManager = NetworkManager()
    }
    
    private var liveSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>?
    private var liveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var allSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?
    private var preLiveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var eventDetailsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    
    func unsubscribeLiveMatches(forSportType sportType: SportType) {
        if let liveEventsPublisher = self.liveEventsPublisher {
            liveEventsPublisher.send(.disconnected)
        }
        
        self.liveEventsPublisher = nil
    }
    
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        self.liveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
        
        guard
            let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sessionToken = connector.token,
            let publisher = self.liveEventsPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        
        let contentType = SportRadarModels.ContentType.liveAdvancedList
        let pageIndex = 0
        let contentId = "\(sportId)/\(pageIndex)" // FBL/0 -> /0 means page 0 of pagination
        
        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        var request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("URLSession shared dataTask error \(error)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            
            print("liveDataSummaryAdvancedListBySportType - recieved")
            
            publisher.send(.connected)
        }
        
        self.connector.subscribe(self, forContentType: .liveAdvancedList)
        
        sessionDataTask.resume()
        
        print("liveDataSummaryAdvancedListBySportType - requested")
        
        return publisher.eraseToAnyPublisher()
    }
    
    func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportTypeDetails]>, ServiceProviderError> {
        
        if self.liveSportTypesPublisher == nil {
            self.liveSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportTypeDetails]>, ServiceProviderError>.init(.disconnected)
        }
        
        guard
            let sessionToken = connector.token,
            let publisher = self.liveSportTypesPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        
        let contentType = SportRadarModels.ContentType.inplaySportList
        
        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType)
        let request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            publisher.send(.connected)
        }
        self.connector.subscribe(self, forContentType: .inplaySportList)
        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
        
    }

    func allSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        if self.allSportTypesPublisher == nil {
            self.allSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
        }
        
        guard
            let sessionToken = connector.token,
            let publisher = self.allSportTypesPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }
        
        let contentType = SportRadarModels.ContentType.sportTypeByDate

        // Today sports ID
        var contentId = self.getDateRangeId()

        if let initialDate = initialDate,
        let endDate = endDate {
            contentId = self.getDateRangeId(initialDate: initialDate, endDate: endDate)
        }

        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        let request = self.createSubscribeRequest(withHTTPBody: bodyData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            publisher.send(.connected)
        }
        self.connector.subscribe(self, forContentType: .sportTypeByDate)
        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
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

    func subscribePreLiveMatches(forSportType sportType: SportType, pageIndex: Int, initialDate: Date? = nil, endDate: Date? = nil, eventCount: Int, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        self.preLiveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
            let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sessionToken = connector.token,
            let publisher = self.preLiveEventsPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = SportRadarModels.ContentType.eventListBySportTypeDate
        let pageIndex = pageIndex
        let eventsNumber = eventCount

        var dateRangeId = self.getDateRangeId()

        if let initialDate = initialDate,
        let endDate = endDate {
            dateRangeId = self.getDateRangeId(initialDate: initialDate, endDate: endDate)
        }

        let contentId = "\(sportId)/\(dateRangeId)/\(pageIndex)/\(eventsNumber)/\(sortType.id)" // FBL/202210210000/202210212359/0/20/T: example content ID

        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        let request = self.createSubscribeRequest(withHTTPBody: bodyData)
        
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("URLSession shared dataTask error \(error)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            print("eventListBySportTypeDate Popular - received")

            publisher.send(.connected)
        }

        self.connector.subscribe(self, forContentType: .eventListBySportTypeDate)

        sessionDataTask.resume()

        print("eventListBySportTypeDate Popular - requested")

        return publisher.eraseToAnyPublisher()
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

    func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        self.eventDetailsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
            let sessionToken = connector.token,
            let publisher = self.eventDetailsPublisher
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = SportRadarModels.ContentType.eventDetails

        let contentId = matchId

        let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
        let request = self.createSubscribeRequest(withHTTPBody: bodyData)

        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("URLSession shared dataTask error \(error)")
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            print("eventListBySportTypeDate Popular - received")

            publisher.send(.connected)
        }

        self.connector.subscribe(self, forContentType: .eventDetails)

        sessionDataTask.resume()

        print("eventDetails - requested")

        return publisher.eraseToAnyPublisher()
    }

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

    func eventDetails(events: [EventsGroup]) {
        if let eventDetailsPublisher = self.eventDetailsPublisher {
            eventDetailsPublisher.send(.content(events))
        }
    }
    
}

/* REST API Events
 */
extension SportRadarEventsProvider {

    func getMarketsFilter() -> AnyPublisher<MarketFilter, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.marketsFilter
        let requestPublisher: AnyPublisher<MarketFilter, ServiceProviderError> = self.networkManager.request(endpoint)
        return requestPublisher
    }

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError> {
        let endpoint = SportRadarRestAPIClient.fieldWidgetId(eventId: eventId)
        let requestPublisher: AnyPublisher<FieldWidget, ServiceProviderError> = self.networkManager.request(endpoint)
        return requestPublisher
    }

    func getFieldWidgetURLRequest(urlString: String?, widgetFile: String?) -> URLRequest? {

        if let urlString = urlString {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                return request
            }
        }

        if let widgetFile = widgetFile {
            let fileStringSplit = widgetFile.components(separatedBy: ".")
            if let url = Bundle.main.url(forResource: fileStringSplit[0], withExtension: fileStringSplit[1]) {

                let request = URLRequest(url: url)
                return request
            }
        }

        return nil
    }

    func getFieldWidgetHtml(widgetFile: String, eventId: String, providerId: String?) -> String? {

        let fileStringSplit = widgetFile.components(separatedBy: ".")

        let filePath = Bundle.main.path(forResource: fileStringSplit[0], ofType: fileStringSplit[1])
        let contentData = FileManager.default.contents(atPath: filePath!)
        let emailTemplate = NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String
        if let replacedHtmlContent = emailTemplate?.replacingOccurrences(of: "@eventId", with: eventId) {
            return replacedHtmlContent
        }

        return nil
    }
}

// Helpers
extension SportRadarEventsProvider {
    
    private func getDateRangeId(initialDate: Date? = nil, endDate: Date? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        var initialDateDefault = Date()
        if let initialDate = initialDate {
            initialDateDefault = initialDate
        }

        var endDateDefault = Calendar.current.date(byAdding: .day, value: 7, to: initialDateDefault) ?? Date()
        if let endDate = endDate {
            endDateDefault = endDate
        }

        let initialDateId = dateFormatter.string(from: initialDateDefault)
        let endDateId = dateFormatter.string(from: endDateDefault)


        let dateRangeId = "\(initialDateId)0000/\(endDateId)2359"

        return dateRangeId
    }
    
}

extension SportRadarEventsProvider {
    
    private func createPayloadData(with sessionAccessToken: SportRadarSessionAccessToken,
                                   contentType: SportRadarModels.ContentType, contentId: String = "") -> Data {
        let bodyString =
        """
        {
            "subscriberId": "\(sessionAccessToken.hash)",
            "contentId": {
                "type": "\(contentType.rawValue)",
                "id": "\(contentId)"
            },
            "clientContext": {
                "language": "\(SportRadarConstants.socketLanguageCode)",
                "ipAddress": "127.0.0.1"
            }
        }
        """
        return bodyString.data(using: String.Encoding.utf8) ?? Data()
    }
    
    private func createSubscribeRequest(withHTTPBody body: Data? = nil) -> URLRequest {
        let hostname = SportRadarConstants.socketRestHostname
        let url = URL(string: "\(hostname)/services/content/subscribe")!
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
