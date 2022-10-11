//
//  SportRadarProvider.swift
//  
//
//  Created by Ruben Roques on 29/09/2022.
//

import Foundation
import Combine

class SportRadarProvider: EventsProvider {
    
    var connector: SportRadarConnector
    
    required init(connector: SportRadarConnector) {
        self.connector = connector
    }
    
    private var liveEventsPublisher: CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>?
    
    func unsubscribeLiveMatches(forSportType sportType: SportType) {
        if let liveEventsPublisher = self.liveEventsPublisher {
            liveEventsPublisher.send(.disconnected)
        }
        
        self.liveEventsPublisher = nil
    }
    
    func subscribeLiveMatches(forSportType sportType: SportType) -> AnyPublisher<SubscribableContent<[EventsGroup]>, ServiceProviderError>? {
        
        if self.liveEventsPublisher == nil {
            self.liveEventsPublisher = CurrentValueSubject<SubscribableContent<[EventsGroup]>, ServiceProviderError>.init(.disconnected)
        }
        else {
            return self.liveEventsPublisher?.eraseToAnyPublisher()
        }
        
        let sessionHash = connector.token?.hash ?? ""
        let contentTypeIdentifier = "liveDataSummaryAdvancedListBySportType"
        let sportId = SportRadarModelMapper.internalSportType(fromSportType: sportType).id

        let bodyString =
        """
        {
            "subscriberId": "\(sessionHash)",
            "contentId": {
                "type": "\(contentTypeIdentifier)",
                "id": "\(sportId)"
            },
            "clientContext": {
                "language": "UK",
                "ipAddress": "85.138.7.73"
            }
        }
        """
        
        let data = bodyString.data(using: String.Encoding.utf8)!
        
        let url = URL(string: "https://www-sportbook-goma-int.optimahq.com/services/content/subscribe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Media-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = data
        
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
    
}

extension SportRadarProvider: SportRadarConnectorSubscriber {
    
    func liveAdvancedListUpdated(forSportType sportType: SportType, withEvents events: [EventsGroup]) {
        if let liveEventsPublisher = self.liveEventsPublisher {
            liveEventsPublisher.send(.content(events))
        }
    }
    
}

    /**
     
     
     {
       "version": 1,
       "data": [
         {
           "contentId": {
             "type": "liveDataSummaryAdvancedListBySportType",
             "id": "FBL/0"
           },
           "changeType": "refreshed",
           "change": [
           
           ],
           "version": 0
         }
       ],
       "notificationType": "CONTENT_CHANGES"
     }
     
     
     
     
     
     
     
     
     {
       "version": 1,
       "data": [
         {
           "contentId": {
             "type": "liveDataSummaryAdvancedListBySportType",
             "id": "FBL/0"
           },
           "changeType": "refreshed",
           "change": [
             {
               "idfoevent": "2794662.1",
               "name": "Wolves vs Tottenham",
               "tsstart": "2023-04-05T23:25:00.000+02:00",
               "idfosporttype": "FBL",
               "sporttypename": "Soccer",
               "idfosport": "FBLUOIR",
               "markets": [
                 {
                   "idfomarket": "34170551.1",
                   "name": "2nd Half - Away Clean Sheet (E-Venue)",
                   "istradable": true,
                   "istrapbettingoptionon": false,
                   "eachwayterms": [
                     {
                       "idfomarketewterms": "31375108.1",
                       "ewreduction": "1",
                       "ewplaceterms": "1",
                       "displayorder": "31375108.1",
                       "defaultOrder": 0
                     }
                   ],
                   "pricetypes": [
                     {
                       "idfopricetypeclass": "FIXED ODDS",
                       "value": "CP",
                       "defaultOrder": 18
                     }
                   ],
                   "selections": [
                     {
                       "idfoselection": "190965622.1",
                       "currentpricedown": "1",
                       "currentpriceup": "2",
                       "name": "Yes",
                       "selectionhashcode": "12393"
                     },
                     {
                       "idfoselection": "190965623.1",
                       "currentpricedown": "1",
                       "currentpriceup": "3",
                       "name": "No",
                       "selectionhashcode": "54258"
                     }
                   ],
                   "defaultOrder": 0,
                   "csvavailablebettypes": "A,C1,C10,C11,C12,C2,C3,C4,C5,C6,C7,C8,C9,D,G,H,L15,L31,L63,P,S,SH,T,TX,Y",
                   "idfoewoffertype": "NONE",
                   "internalOrder": 43535710,
                   "isunderover": false
                 }
               ],
               "numMarkets": 2,
               "displayOrder": 0,
               "mediacoveragetypes": [

               ],
               "participantname_away": "Tottenham Hotspur",
               "participantname_home": "Wolves FC",
               "idfotournament": "13295",
               "tournamentname": "1. Cfl - Montenegro",
               "idfotournamentcountry": "21",
               "tournamentcountryname": "Other"
             },
             {
               "idfoevent": "2794663.1",
               "name": "Chelsea vs Arsenal",
               "tsstart": "2023-04-05T23:25:00.000+02:00",
               "idfosporttype": "FBL",
               "sporttypename": "Soccer",
               "idfosport": "FBLUOIR",
               "markets": [
                 {
                   "idfomarket": "34170557.1",
                   "name": "2nd Half - Away Clean Sheet (E-Venue)",
                   "istradable": true,
                   "istrapbettingoptionon": false,
                   "eachwayterms": [
                     {
                       "idfomarketewterms": "31375114.1",
                       "ewreduction": "1",
                       "ewplaceterms": "1",
                       "displayorder": "31375114.1",
                       "defaultOrder": 0
                     }
                   ],
                   "pricetypes": [
                     {
                       "idfopricetypeclass": "FIXED ODDS",
                       "value": "CP",
                       "defaultOrder": 18
                     }
                   ],
                   "selections": [
                     {
                       "idfoselection": "190965637.1",
                       "currentpricedown": "1",
                       "currentpriceup": "2",
                       "name": "Yes",
                       "selectionhashcode": "12393"
                     },
                     {
                       "idfoselection": "190965638.1",
                       "currentpricedown": "1",
                       "currentpriceup": "3",
                       "name": "No",
                       "selectionhashcode": "54258"
                     }
                   ],
                   "defaultOrder": 0,
                   "csvavailablebettypes": "A,C1,C10,C11,C12,C2,C3,C4,C5,C6,C7,C8,C9,D,G,H,L15,L31,L63,P,S,SH,T,TX,Y",
                   "idfoewoffertype": "NONE",
                   "internalOrder": 43535710,
                   "isunderover": false
                 }
               ],
               "numMarkets": 2,
               "displayOrder": 1,
               "mediacoveragetypes": [

               ],
               "participantname_away": "Arsenal FC",
               "participantname_home": "Chelsea FC",
               "idfotournament": "13295",
               "tournamentname": "1. Cfl - Montenegro",
               "idfotournamentcountry": "21",
               "tournamentcountryname": "Other"
             },
             {
               "idfoevent": "2794664.1",
               "name": "Liverpool vs Barnsley",
               "tsstart": "2023-04-05T23:25:00.000+02:00",
               "idfosporttype": "FBL",
               "sporttypename": "Soccer",
               "idfosport": "FBLUOIR",
               "markets": [
                 {
                   "idfomarket": "34170562.1",
                   "name": "2nd Half - Home Clean Sheet (E-Venue)",
                   "istradable": true,
                   "istrapbettingoptionon": false,
                   "eachwayterms": [
                     {
                       "idfomarketewterms": "31375119.1",
                       "ewreduction": "1",
                       "ewplaceterms": "1",
                       "displayorder": "31375119.1",
                       "defaultOrder": 0
                     }
                   ],
                   "pricetypes": [
                     {
                       "idfopricetypeclass": "FIXED ODDS",
                       "value": "CP",
                       "defaultOrder": 18
                     }
                   ],
                   "selections": [
                     {
                       "idfoselection": "190965650.1",
                       "currentpricedown": "1",
                       "currentpriceup": "2",
                       "name": "Yes",
                       "selectionhashcode": "12393"
                     },
                     {
                       "idfoselection": "190965651.1",
                       "currentpricedown": "1",
                       "currentpriceup": "3",
                       "name": "No",
                       "selectionhashcode": "54258"
                     }
                   ],
                   "defaultOrder": 0,
                   "csvavailablebettypes": "A,C1,C10,C11,C12,C2,C3,C4,C5,C6,C7,C8,C9,D,G,H,L15,L31,L63,P,S,SH,T,TX,Y",
                   "idfoewoffertype": "NONE",
                   "internalOrder": 43535610,
                   "isunderover": false
                 }
               ],
               "numMarkets": 3,
               "displayOrder": 2,
               "mediacoveragetypes": [

               ],
               "participantname_away": "Barnsley FC",
               "participantname_home": "Liverpool FC",
               "idfotournament": "13295",
               "tournamentname": "1. Cfl - Montenegro",
               "idfotournamentcountry": "21",
               "tournamentcountryname": "Other"
             }
           ],
           "version": 0
         }
       ],
       "notificationType": "CONTENT_CHANGES"
     }
     */
    
    //    func call<T: Decodable>(decodingType: T.Type) {
    //
    //        let subject = PassthroughSubject<SubscribableContent<T>, EveryMatrix.APIError>()
    //
    //        guard
    //            let swampSession = self.swampSession,
    //            swampSession.isConnected()
    //        else {
    //            subject.send(completion: .failure(.notConnected))
    //            return subject.eraseToAnyPublisher()
    //        }
    //
    //
    //        let args: [String: Any] = endpoint.kwargs ?? [:]
    //
    //        Logger.log("TSManager subscribeEndpoint - url:\(endpoint.procedure), args:\(args)")
    //
    //        swampSession.subscribe(endpoint.procedure, options: args,
    //        onSuccess: { (subscription: Subscription) in
    //            subject.send(SubscribableContent.connect(subscriptionIdentifier: subscription))
    //
    //            if let initialDumpEndpoint = endpoint.intiailDumpRequest {
    //                self.getModel(router: initialDumpEndpoint, decodingType: decodingType)
    //                    .sink { completion in
    //                        if case .failure(let error) = completion {
    //                            subject.send(SubscribableContent.disconnect)
    //                            subject.send(completion: .failure(error))
    //
    //                        }
    //                    } receiveValue: { decoded in
    //                        subject.send(.initialContent(decoded))
    //                    }
    //                    .store(in: &self.globalCancellable)
    //            }
    //        },
    //        onError: { (details: [String: Any], errorStr: String) in
    //            subject.send(SubscribableContent.disconnect)
    //            subject.send(completion: .failure(.requestError(value: errorStr)))
    //        },
    //        onEvent: { (details: [String: Any], results: [Any]?, kwResults: [String: Any]?) in
    //            do {
    //                if kwResults != nil {
    //                    let decoder = DictionaryDecoder()
    //                    decoder.dateDecodingStrategy = .iso8601
    //                    let decoded = try decoder.decode(decodingType, from: kwResults!)
    //                    subject.send(.updatedContent(decoded))
    //                }
    //                else {
    //                    subject.send(completion: .failure(.noResultsReceived))
    //                }
    //            }
    //            catch {
    //                // print("TSManager Decoding Error: \(error)")
    //                subject.send(completion: .failure(.decodingError(value: error.localizedDescription)))
    //            }
    //        })
    //
    //        return subject.handleEvents(receiveOutput: { content in
    //
    //        }, receiveCompletion: { completion in
    //            print("completion \(completion)")
    //        }, receiveCancel: {
    //
    //        }).eraseToAnyPublisher()
    //
    //
    //    }
    
// }

//extension SportsradarProvider: PrivilegedAccessManager {
//
//}
//
//extension SportsradarProvider: BettingProvider {
//
//}
//
