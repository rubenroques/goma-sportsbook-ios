//
//  SportRadarEventsProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine
import OrderedCollections

class SportRadarEventsProvider: EventsProvider {

    var connector: SportRadarSocketConnector
    private var networkManager: NetworkManager

    private var cancellables = Set<AnyCancellable>()

    required init(connector: SportRadarSocketConnector) {
        self.connector = connector
        self.networkManager = NetworkManager()
    }
    
    private var liveSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?
    private var liveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var allSportTypesPublisher: CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>?
    private var preLiveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
//    private var popularEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
//    private var upcomingEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var eventDetailsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    private var sportTypesPublisher: CurrentValueSubject<[SportType], ServiceProviderError>?
    
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
            //let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sportId = sportType.alphaId,
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
    
    func liveSportTypes() -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>? {
        if self.liveSportTypesPublisher == nil {
            self.liveSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
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

    func allSportTypes(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<SubscribableContent<[SportType]>, ServiceProviderError>? {
        if self.allSportTypesPublisher == nil {
            self.allSportTypesPublisher = CurrentValueSubject<SubscribableContent<[SportType]>, ServiceProviderError>.init(.disconnected)
        }
        else {
            return self.allSportTypesPublisher?.eraseToAnyPublisher()
        }

        guard let sessionToken = connector.token else { return nil }

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

    func subscribePreLiveMatches(forSportType sportType: SportType, initialDate: Date? = nil, endDate: Date? = nil, sortType: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {

        self.preLiveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
//            let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType)?.id,
            let sportId = sportType.alphaId,
            let sessionToken = connector.token
        else {
            return nil
        }

        let contentType = SportRadarModels.ContentType.eventListBySportTypeDate
        let pageIndex = 0
        let eventsNumber = 20

        var dateRangeId = self.getDateRangeId()

        if let initialDate = initialDate,
        let endDate = endDate {
            dateRangeId = self.getDateRangeId(initialDate: initialDate, endDate: endDate)
        }

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

    func subscribeMatchDetails(matchId: String) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {

        self.eventDetailsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)

        guard
            let sessionToken = connector.token
        else {
            return nil
        }

        let contentType = SportRadarModels.ContentType.eventDetails

        let contentId = matchId

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
                self.eventDetailsPublisher?.send(completion: .failure(ServiceProviderError.onSubscribe))
                return
            }

            print("eventListBySportTypeDate Popular - received")

            self.eventDetailsPublisher?.send(.connected)
        }

        self.connector.subscribe(self, forContentType: .eventDetails)

        sessionDataTask.resume()

        print("eventDetails - requested")

        return self.eventDetailsPublisher?.eraseToAnyPublisher()
    }

    func getDateRangeId(initialDate: Date? = nil, endDate: Date? = nil) -> String {
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

    func mergeSports(numericSportArray: [SportType], alphaSportArray: [SportType]) -> [SportType] {

        var uniqueArray: [SportType] = []

        for numericSport in numericSportArray {

            let alphaFilter = alphaSportArray.filter({ $0.name.lowercased() == numericSport.name.lowercased() })

            if let alphaSport = alphaFilter.first {
                let mergedSport = SportType(name: numericSport.name,
                                              numericId: numericSport.numericId,
                                              alphaId: alphaSport.alphaId,
                                              iconId: numericSport.iconId,
                                              numberEvents: numericSport.numberEvents,
                                              numberOutrightEvents: numericSport.numberOutrightEvents,
                                              numberOutrightMarkets: numericSport.numberOutrightMarkets)

                uniqueArray.append(mergedSport)
            }
            else {
                uniqueArray.append(numericSport)
            }

        }

        for alphaSport in alphaSportArray {

            if !uniqueArray.contains(where: { $0.name.lowercased() == alphaSport.name.lowercased() }) {
                uniqueArray.append(alphaSport)
            }

        }

        // Check code id
        var uniqueSportsArray: [SportType] = []

        for uniqueSport in uniqueArray {

            let sportTypeFilter = SportTypeInfo.allCases.filter({
                $0.name.lowercased() == uniqueSport.name.lowercased()
            })

            // Check for unique sport
            if !uniqueSportsArray.contains(where: {
                $0.name == uniqueSport.name
            }) {
                if let sportType = sportTypeFilter.first {
                    let newSportUnique = SportType(name: uniqueSport.name, numericId: uniqueSport.numericId, alphaId: uniqueSport.alphaId, iconId: sportType.id, numberEvents: uniqueSport.numberEvents, numberOutrightEvents: uniqueSport.numberOutrightEvents, numberOutrightMarkets: uniqueSport.numberOutrightMarkets)

                    uniqueSportsArray.append(newSportUnique)
                }
                else {
                    uniqueSportsArray.append(uniqueSport)
                }
            }
        }

        // Merge Football and Soccer - TEMP
        if uniqueSportsArray.contains(where: { $0.name == "Soccer" }),
           let soccerSportType = uniqueSportsArray.filter({ $0.name == "Soccer" }).first,
           let footballIndex = uniqueSportsArray.firstIndex(where: { $0.name == "Football" }) {

            let newSport = SportType(name: uniqueSportsArray[footballIndex].name,
                                     numericId: uniqueSportsArray[footballIndex].numericId,
                                     alphaId: soccerSportType.alphaId,
                                     iconId: uniqueSportsArray[footballIndex].iconId,
                                     numberEvents: uniqueSportsArray[footballIndex].numberEvents,
                                     numberOutrightEvents: uniqueSportsArray[footballIndex].numberOutrightEvents,
                                     numberOutrightMarkets: uniqueSportsArray[footballIndex].numberOutrightMarkets)

            uniqueSportsArray[footballIndex] = newSport

            uniqueSportsArray.removeAll(where: {$0 == soccerSportType})
        }


        return uniqueSportsArray
    }

    private func processMarketFilters(marketFilter: MarketFilter, match: Event) -> [MarketGroup] {

        var eventMarkets: [EventMarket] = []
        var marketGroups: OrderedDictionary<String, MarketGroup> = [:]
        var availableMarkets: [String: [AvailableMarket]] = [:]

        var availableMarketGroups: [String: [AvailableMarket]] = [:]

        // All Market
        let allMarket = marketFilter.allMarkets
        let allEventMarket = EventMarket(id: "\(allMarket.displayOrder)", name: allMarket.translations?.english ?? "", marketIds: [])
        eventMarkets.append(allEventMarket)

        // Popular Market
        let popularMarket = marketFilter.popularMarkets
        var popularMarketIds: [String] = []
        if let popularMarketSportsIds = popularMarket.marketsSportType?.all {

            for marketId in popularMarketSportsIds {
                let marketSportId = marketId.ids[0]
                popularMarketIds.append(marketSportId)

            }
        }
        let popularEventMarket = EventMarket(id: "\(popularMarket.displayOrder)", name: popularMarket.translations?.english ?? "", marketIds: popularMarketIds)
        eventMarkets.append(popularEventMarket)

        // Total Market
        let totalMarket = marketFilter.totalMarkets
        var totalMarketIds: [String] = []
        if let totalMarketSportsIds = totalMarket.marketsSportType?.all {

            for marketId in totalMarketSportsIds {
                let marketSportId = marketId.ids[0]
                totalMarketIds.append(marketSportId)

            }
        }
        let totalEventMarket = EventMarket(id: "\(totalMarket.displayOrder)", name: totalMarket.translations?.english ?? "", marketIds: totalMarketIds)
        eventMarkets.append(totalEventMarket)

        // Total Market
        let goalMarket = marketFilter.goalMarkets
        var goalMarketIds: [String] = []
        if let goalMarketSportsIds = goalMarket.marketsSportType?.all {

            for marketId in goalMarketSportsIds {
                let marketSportId = marketId.ids[0]
                goalMarketIds.append(marketSportId)

            }
        }
        let goalEventMarket = EventMarket(id: "\(goalMarket.displayOrder)", name: goalMarket.translations?.english ?? "", marketIds: goalMarketIds)
        eventMarkets.append(goalEventMarket)

        // Handicap Market
        let handicapMarket = marketFilter.handicapMarkets
        var handicapMarketIds: [String] = []
        if let handicapMarketSportsIds = handicapMarket.marketsSportType?.all {

            for marketId in handicapMarketSportsIds {
                let marketSportId = marketId.ids[0]
                handicapMarketIds.append(marketSportId)

            }
        }
        let handicapEventMarket = EventMarket(id: "\(handicapMarket.displayOrder)", name: handicapMarket.translations?.english ?? "", marketIds: handicapMarketIds)
        eventMarkets.append(handicapEventMarket)

        // Other Market
        let otherMarket = marketFilter.otherMarkets
        var otherMarketIds: [String] = []
        if let otherMarketSportsIds = otherMarket.marketsSportType?.all {

            for marketId in otherMarketSportsIds {
                let marketSportId = marketId.ids[0]
                otherMarketIds.append(marketSportId)

            }
        }
        let otherEventMarket = EventMarket(id: "\(otherMarket.displayOrder)", name: otherMarket.translations?.english ?? "", marketIds: otherMarketIds)
        eventMarkets.append(otherEventMarket)

        //self.eventMarketsPublisher.send(self.eventMarkets)

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
            $0.id < $1.id
        })

        //self.marketGroupsPublisher.send(sortedMarketGroupsArray)
        return sortedMarketGroupsArray
    }

}

extension SportRadarEventsProvider: SportRadarConnectorSubscriber {

    func liveAdvancedListUpdated(forSportType sportType: SportType, withEvents events: [EventsGroup]) {
        if let liveEventsPublisher = self.liveEventsPublisher {
            liveEventsPublisher.send(.content(events))
        }
    }
    
    func inplaySportListUpdated(withSportTypes sportTypes: [SportType]) {
        if let liveSportTypesPublisher = self.liveSportTypesPublisher {
            liveSportTypesPublisher.send(.content(sportTypes))
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

    func eventDetails(events: [EventsGroup]) {
        if let eventDetailsPublisher = self.eventDetailsPublisher {
            eventDetailsPublisher.send(.content(events))
        }
    }
    
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
        //let url = URL(string: "https://www-sportbook-goma-int.optimahq.com/services/content/subscribe")!
        let url = URL(string: "https://www-sportsbook-uat.optimahq.com/services/content/subscribe")!

        var request = URLRequest(url: url)
        request.httpBody = body 
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

/* REST API Events
 */
extension SportRadarEventsProvider {

    func getMarketsFilter(event: Event) -> AnyPublisher<[MarketGroup], ServiceProviderError>? {

        let endpoint = SportRadarRestAPIClient.marketsFilter
        let requestPublisher: AnyPublisher<MarketFilter, ServiceProviderError> = self.networkManager.request(endpoint)


        return requestPublisher.flatMap({ marketFilters -> AnyPublisher<[MarketGroup], ServiceProviderError> in

            let marketGroups = self.processMarketFilters(marketFilter: marketFilters, match: event)

            return Just(marketGroups).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

        })
        .eraseToAnyPublisher()

    }

    func getFieldWidgetId(eventId: String) -> AnyPublisher<FieldWidget, ServiceProviderError> {

        let endpoint = SportRadarRestAPIClient.fieldWidgetId(eventId: eventId)
        let requestPublisher: AnyPublisher<FieldWidget, ServiceProviderError> = self.networkManager.request(endpoint)

        return requestPublisher

    }

    func getFieldWidget(eventId: String, isDarkTheme: Bool? = nil) -> AnyPublisher<FieldWidgetRenderData, ServiceProviderError> {

        var fieldWidgetFile = "field_widget_light.html"

        if isDarkTheme ?? true {
            fieldWidgetFile = "field_widget_dark.html"
        }

        return self.getFieldWidgetId(eventId: eventId).flatMap({ fieldWidget -> AnyPublisher<FieldWidgetRenderData, ServiceProviderError> in

            let fileStringSplit = fieldWidgetFile.components(separatedBy: ".")

            let bundleUrl = Bundle.main.url(forResource: fileStringSplit[0], withExtension: fileStringSplit[1])

            let filePath = Bundle.main.path(forResource: fileStringSplit[0], ofType: fileStringSplit[1])
            let contentData = FileManager.default.contents(atPath: filePath!)
            let emailTemplate = NSString(data: contentData!, encoding: String.Encoding.utf8.rawValue) as? String
            if let fieldWidgetId = fieldWidget.data,
               let replacedHtmlContent = emailTemplate?.replacingOccurrences(of: "@eventId", with: fieldWidgetId) {

                let fieldWidgetRenderData = FieldWidgetRenderData(url: bundleUrl, htmlString: replacedHtmlContent)

                return Just(fieldWidgetRenderData).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

            }

            return Fail(outputType: FieldWidgetRenderData.self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()

        })
        .eraseToAnyPublisher()


    }

    func getSportsList() -> AnyPublisher<SportRadarResponse<SportsList>, ServiceProviderError>? {

        let endpoint = SportRadarRestAPIClient.sportsList
        let requestPublisher: AnyPublisher<SportRadarResponse<SportsList>, ServiceProviderError> = self.networkManager.request(endpoint)

        return requestPublisher

    }

    func getAllSportsList(initialDate: Date? = nil, endDate: Date? = nil) -> AnyPublisher<[SportType], ServiceProviderError> {

        // Navigation Sports
        let sportsEndpoint = SportRadarRestAPIClient.sportsList
        let sportsRequestPublisher: AnyPublisher<SportRadarResponse<SportsList>, ServiceProviderError> = self.networkManager.request(sportsEndpoint)

        // Code Sports
        let dateRange = self.getDateRangeId()
        let codeSportsEndpoint = SportRadarRestAPIClient.scheduleSportsList(dateRange: dateRange)

        let codeSportsRequestPublisher: AnyPublisher<SportRadarResponse<[ScheduledSport]>, ServiceProviderError> = self.networkManager.request(codeSportsEndpoint)

        return Publishers.CombineLatest(sportsRequestPublisher, codeSportsRequestPublisher)
            .flatMap({ sportsList, codeSportsList -> AnyPublisher<[SportType], ServiceProviderError> in

                if let sports = sportsList.data?.sportNodes?.filter({
                    $0.numberEvents != "0"
                }),
                   let codeSports = codeSportsList.data {

                    let newSports = sports.map(SportRadarModelMapper.sportUnique(fromSportNode:)).compactMap({ $0 })

                    let newCodeSports = codeSports.map(SportRadarModelMapper.sportUnique(fromScheduledSport:)).compactMap({ $0 })

                    let unifiedSportsList = self.mergeSports(numericSportArray: newSports, alphaSportArray: newCodeSports)

                    return Just(unifiedSportsList).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()

                }
                return Fail(outputType: [SportType].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()


//        return codeSportsRequestPublisher.flatMap({ sportsListResponse -> AnyPublisher<[SportType], ServiceProviderError> in
//
//            if let mappedSportsTypes = sportsListResponse.map(SportRadarModelMapper.sportTypeDetails(fromInternalSportTypeDetails:)).compactMap({ $0 }) {
//
//                return Just(mappedSportsTypes).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher()
//
//            }
//
//
//            return Fail(outputType: [SportType].self, failure: ServiceProviderError.invalidResponse).eraseToAnyPublisher()
//        })

        //return codeSportsRequestPublisher

    }
}

public struct EventMarket {
    public var id: String
    public var name: String
    public var marketIds: [String]

}

public struct AvailableMarket {
    public var marketId: String
    public var marketGroupId: String
    public var market: Market
}

public struct MarketGroup {

    public var type: String
    public var id: String
    public var groupKey: String?
    public var translatedName: String?
    public var position: Int?
    public var isDefault: Bool?
    public var numberOfMarkets: Int?
    public var markets: [Market]?
}

public struct FieldWidgetRenderData {
    public var url: URL?
    public var htmlString: String?
}
