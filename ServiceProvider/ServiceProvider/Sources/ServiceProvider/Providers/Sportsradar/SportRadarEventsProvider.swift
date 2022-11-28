//
//  SportRadarEventsProvider.swift
//
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

class SportRadarEventsProvider: EventsProvider {

    private var connector: SportRadarSocketConnector
    private var networkManager: NetworkManager

    private var cancellables = Set<AnyCancellable>()

    required init(sessionCoordinator: SportRadarSessionCoordinator, connector: SportRadarSocketConnector = SportRadarSocketConnector()) {
        self.connector = connector
        self.networkManager = NetworkManager()

        self.connector.messageSubscriber = self
        self.connector.connect()
    }


    private var liveSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?
    private var liveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var allSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?

    private var eventDetailsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var sportTypesPublisher: CurrentValueSubject<[SportType], ServiceProviderError>?

    //
    // All the events publishers
    private var eventsPublishers: [TopicIdentifier: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>] = [:]

    //
    // Keep a reference for all the subscriptions. This allows the ServiceProvider to subscribe to the same content in two diferente places
    private var activeSubscriptions: NSMapTable<TopicIdentifier, Subscription> = .init(keyOptions: .strongMemory , valueOptions: .weakMemory)

    func subscribePreLiveMatches(forSportType sportType: SportType, pageIndex: Int, initialDate: Date? = nil, endDate: Date? = nil, eventCount: Int, sortType: EventListSort) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        // Get the session
        guard
            let sportId = sportType.alphaId,
            let sessionToken = connector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        // Create the contentIdentifier
        var dateRangeId = self.getDateRangeId()

        if let initialDate = initialDate,
        let endDate = endDate {
            dateRangeId = self.getDateRangeId(initialDate: initialDate, endDate: endDate)
        }

        let contentId = "\(sportId)/\(dateRangeId)/\(pageIndex)/\(eventCount)/\(sortType.rawValue)" // FBL/202210210000/202210212359/0/20/T: example content ID
        let contentType = SportRadarModels.ContentType.eventListBySportTypeDate

        let contentIdentifier = TopicIdentifier(contentType: contentType.rawValue, contentId: contentId)

        if let publisher = self.eventsPublishers[contentIdentifier], let subscription = self.activeSubscriptions.object(forKey: contentIdentifier) {
            // We already have a publisher for this events and a subscription object for the caller to store
            return publisher
                .prepend(.connected(subscription: subscription))
                .eraseToAnyPublisher()
        }
        else {
            // We have neither a publisher nor a subscription object
            let publisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
            let subscription = Subscription(contentType: contentType.rawValue, contentId: contentId, token: sessionToken.hash, unsubscriber: self)

            let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
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
            self.eventsPublishers[contentIdentifier] = publisher

            return publisher.eraseToAnyPublisher()
        }
    }

    func subscribeLiveMatches(forSportType sportType: SportType, pageIndex: Int) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError> {

        // Get the session
        guard
            //let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sportId = sportType.alphaId,
            let sessionToken = connector.token
        else {
            return Fail(error: ServiceProviderError.userSessionNotFound).eraseToAnyPublisher()
        }

        let contentType = SportRadarModels.ContentType.liveAdvancedList
        let contentId = "\(sportId)/\(pageIndex)" // FBL/0 -> /0 means page 0 of pagination

        let contentIdentifier = TopicIdentifier(contentType: contentType.rawValue, contentId: contentId)

        if let publisher = self.eventsPublishers[contentIdentifier], let subscription = self.activeSubscriptions.object(forKey: contentIdentifier) {
            // We already have a publisher for this events and a subscription object for the caller to store
            return publisher
                .prepend(.connected(subscription: subscription))
                .eraseToAnyPublisher()
        }
        else {
            // We have neither a publisher nor a subscription object
            let publisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
            let subscription = Subscription(contentType: contentType.rawValue, contentId: contentId, token: sessionToken.hash, unsubscriber: self)
            let bodyData = self.createPayloadData(with: sessionToken, contentType: contentType, contentId: contentId)
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
            self.eventsPublishers[contentIdentifier] = publisher

            return publisher.eraseToAnyPublisher()
        }
    }

    func subscribeLiveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
        if self.liveSportTypesPublisher == nil {
            self.liveSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
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
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            // TODO: send subscription
            // publisher.send(.connected)
        }

        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

    func subscribePreLiveSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError> {
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

            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            // TODO: send subscription
            // publisher.send(.connected)
        }

        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

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
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                publisher.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }
            // TODO: send subscription
            // publisher.send(.connected)
        }
        sessionDataTask.resume()
        return publisher.eraseToAnyPublisher()
    }

}

extension SportRadarEventsProvider: SportRadarConnectorSubscriber {

    // Live events
    func liveAdvancedListUpdated(forTopicIdentifier identifier: TopicIdentifier, withEvents events: [EventsGroup]) {

        // Gravar na store do topic

        if let publisher = self.eventsPublishers[identifier] {
            publisher.send(.contentUpdate(content: events))
        }
    }

    // Prelive events
    func eventListBySportTypeDate(forTopicIdentifier identifier: TopicIdentifier, withEvents events: [EventsGroup]) {
        if let publisher = self.eventsPublishers[identifier] {
            publisher.send(.contentUpdate(content: events))
        }
    }

    func inplaySportListUpdated(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        if let liveSportTypesPublisher = self.liveSportTypesPublisher {
            let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
            liveSportTypesPublisher.send(.contentUpdate(content: sports))
        }
    }

    func sportTypeByDate(withSportTypes sportTypes: [SportRadarModels.SportType]) {
        if let allSportTypesPublisher = self.allSportTypesPublisher {
            let sports = sportTypes.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
            allSportTypesPublisher.send(.contentUpdate(content: sports))
        }
    }

    func eventDetails(events: [EventsGroup]) {
        if let eventDetailsPublisher = self.eventDetailsPublisher {
            eventDetailsPublisher.send(.contentUpdate(content: events))
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

    func getAvailableSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<[SportType], ServiceProviderError> {

        // Navigation Sports
        let sportsEndpoint = SportRadarRestAPIClient.sportsBoNavigationList
        let sportsRequestPublisher: AnyPublisher<SportRadarModels.RestResponse<SportRadarModels.SportsList>, ServiceProviderError> = self.networkManager.request(sportsEndpoint)

        // Code Sports
        let dateRange = self.getDateRangeId(initialDate: initialDate, endDate: endDate)
        let codeSportsEndpoint = SportRadarRestAPIClient.sportsScheduledList(dateRange: dateRange)

        let codeSportsRequestPublisher: AnyPublisher<SportRadarModels.RestResponse<[SportRadarModels.ScheduledSport]>, ServiceProviderError> = self.networkManager.request(codeSportsEndpoint)

        return Publishers.CombineLatest(sportsRequestPublisher, codeSportsRequestPublisher)
            .flatMap({ numericSportsList, alphaSportsList -> AnyPublisher<[SportType], ServiceProviderError> in
                if
                    let numericSports = numericSportsList.data?.sportNodes?.filter({
                        $0.numberEvents > 0 // || $0.numberOutrightEvents > 0 || $0.numberOutrightMarkets > 0
                    }),
                    let alphaSports = alphaSportsList.data
                {
                    let newNumericSports = numericSports.map(SportRadarModelMapper.sportType(fromSportNode:))
                    let newAlphaSports = alphaSports.map(SportRadarModelMapper.sportType(fromScheduledSport:))
                    let unifiedSportsList = self.mergeSports(numericSportArray: newNumericSports, alphaSportArray: newAlphaSports)
                    let sportTypes = unifiedSportsList.map(SportRadarModelMapper.sportType(fromSportRadarSportType:))
                    return Just(sportTypes).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
                }
                return Fail(outputType: [SportType].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

extension SportRadarEventsProvider: UnsubscriptionController {

    func unsubscribe(subscription: Subscription) {
        print("ServerProvider.Subscription.Debug unsubscribe \(subscription.id)")

        let request = self.createUnsubscribeRequest(withHTTPBody: subscription.unsubscriptionPayloadData)
        let sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                print("SportRadarEventsProvider unsubscribe failed")
                return
            }
        }
        sessionDataTask.resume()
    }

}

// Helpers
extension SportRadarEventsProvider {

    private func getDateRangeId(initialDate: Date? = nil, endDate: Date? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        let initialDateDefault: Date = initialDate ?? Date()
        let endDateDefault: Date = endDate ?? Calendar.current.date(byAdding: .day, value: 7, to: initialDateDefault) ?? Date()

        let initialDateId = dateFormatter.string(from: initialDateDefault)
        let endDateId = dateFormatter.string(from: endDateDefault)

        let dateRangeId = "\(initialDateId)0000/\(endDateId)2359"

        return dateRangeId
    }

}

extension SportRadarEventsProvider {

    private func mergeSports(numericSportArray: [SportRadarModels.SportType], alphaSportArray: [SportRadarModels.SportType]) -> [SportRadarModels.SportType] {

        var uniqueSportsArray: [SportRadarModels.SportType] = []

        for numericSport in numericSportArray {

            if numericSport.name.lowercased() == "top bets"
                || numericSport.name.lowercased() == "top bet"
                || numericSport.name.lowercased() == "outrights" {
                continue
            }

            let alphaFilter = alphaSportArray.filter({ $0.name.lowercased() == numericSport.name.lowercased() })

            if let alphaSport = alphaFilter.first {
                let mergedSport = SportRadarModels.SportType(name: numericSport.name,
                                                             numericId: numericSport.numericId,
                                                             alphaId: alphaSport.alphaId,
                                                             numberEvents: numericSport.numberEvents,
                                                             numberOutrightEvents: numericSport.numberOutrightEvents,
                                                             numberOutrightMarkets: numericSport.numberOutrightMarkets)
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

        // TODO: TASK André - Falar com o pedro sobre este merge
        // Merge Football and Soccer - TEMP
        if uniqueSportsArray.contains(where: { $0.name == "Soccer" }),
           let soccerSportType = uniqueSportsArray.filter({ $0.name == "Soccer" }).first,
           let footballIndex = uniqueSportsArray.firstIndex(where: { $0.name == "Football" }) {

            let newSport = SportRadarModels.SportType(name: uniqueSportsArray[footballIndex].name,
                                                      numericId: uniqueSportsArray[footballIndex].numericId,
                                                      alphaId: soccerSportType.alphaId,
                                                      numberEvents: uniqueSportsArray[footballIndex].numberEvents,
                                                      numberOutrightEvents: uniqueSportsArray[footballIndex].numberOutrightEvents,
                                                      numberOutrightMarkets: uniqueSportsArray[footballIndex].numberOutrightMarkets)

            uniqueSportsArray[footballIndex] = newSport
            uniqueSportsArray.removeAll(where: {$0 == soccerSportType})
        }
        return uniqueSportsArray
    }

}

extension SportRadarEventsProvider {

    private func createPayloadData(with sessionAccessToken: SportRadarSessionAccessToken,
                                   contentType: SportRadarModels.ContentType,
                                   contentId: String = "") -> Data {
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

    private func createUnsubscribeRequest(withHTTPBody body: Data? = nil) -> URLRequest {
        let hostname = SportRadarConstants.socketRestHostname
        let url = URL(string: "\(hostname)/services/content/unsubscribe")!
        var request = URLRequest(url: url)
        request.httpBody = body
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

}


