//
//  File.swift
//  
//
//  Created by Ruben Roques on 07/05/2024.
//

import Foundation

enum VaixAPIClient {
    case popularEvents(eventsCount: Int, userId: String?)
    case analyticsTrackEvent(event: VaixAnalyticsEvent, userId: String)
    case promotedBetslips(userId: String?)
}

extension VaixAPIClient: Endpoint {
    var url: String {
        return SportRadarConfiguration.shared.vaixHostname
    }
    
    var endpoint: String {
        switch self {
        case .popularEvents:
            return "/api/sports/events/popular"
        case .analyticsTrackEvent:
            return "/api/tracker/events"
        case .promotedBetslips:
            return "/api/batch"
        }
    }
    
    var query: [URLQueryItem]? {
        var query: [URLQueryItem] = []
        switch self {
        case .popularEvents(let eventsCount, let userId):
            if let userId {
                let userIdFormat = "om\(userId)-eur"
                query.append(URLQueryItem(name:"user", value:userIdFormat))
            }
            else {
                query.append(URLQueryItem(name:"user", value:"0"))
            }
            
            query.append(URLQueryItem(name:"from_offset", value:"-5h"))
            query.append(URLQueryItem(name:"filters", value:"status:eq:live"))
            query.append(URLQueryItem(name:"count", value:"\(eventsCount)"))
            query.append(URLQueryItem(name:"order_by", value:"-event_confidence,+begin"))
            query.append(URLQueryItem(name:"format", value:"orako"))
            query.append(URLQueryItem(name:"location", value:"liveevent-popular"))
        case .analyticsTrackEvent:
            break
        case .promotedBetslips:
            break
        }
        return query
    }
    
    var headers: HTTP.Headers? {
        switch self {
        case .popularEvents:
            return [ "Authorization": "Bearer \(SportRadarConfiguration.shared.vaixAuthTokenValue)",
                     "origin": "null",
                     "x-vaix-client-id": "betsson_france"]
        case .analyticsTrackEvent:
            return ["Authorization": "Bearer \(SportRadarConfiguration.shared.vaixAuthTokenValue)",
                    "origin": "null",
                    "x-vaix-client-id": "betsson_france",
                    "Content-Type": "application/json"]
        case .promotedBetslips:
            return ["Authorization": "Bearer \(SportRadarConfiguration.shared.vaixAuthTokenValue)",
                    "origin": "null",
                    "x-vaix-client-id": "betsson_france",
                    "Content-Type": "application/json"]
        }
    }
    
    var method: HTTP.Method {
        switch self {
        case .popularEvents: return .get
        case .analyticsTrackEvent: return .post
        case .promotedBetslips: return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .popularEvents:
            return nil
        case .analyticsTrackEvent(let event, let userId):
            
            
            if let data = event.data,
               let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
               let dataString = String(data: jsonData, encoding: .utf8) {
                
                let body = """
                            {
                                "event_type": "\(event.type)",
                                "user_id": \(userId),
                                "data": \(dataString)
                            }
                            """
                
                let data = body.data(using: String.Encoding.utf8)!
                return data
            }
            else {
                return nil
            }
        case .promotedBetslips(let userId):
            let userIdFormat = userId != nil ? "om\(userId!)-eur" : "0"
            let body = """
                        {
                          "requests": [
                            {
                              "operation_id": "get_popular_betslips",
                              "name": "multigame_acca_1",
                              "params": {
                                "format": "orako",
                                "location": "multigame_acca_1",
                                "user": "\(userIdFormat)"
                              }
                            },
                            {
                              "operation_id": "get_popular_betslips",
                              "name": "multigame_acca_2",
                              "params": {
                                "format": "orako",
                                "location": "multigame_acca_2",
                                "user": "\(userIdFormat)"
                              }
                            },
                            {
                              "operation_id": "get_popular_betslips",
                              "name": "multigame_acca_3",
                              "params": {
                                "format": "orako",
                                "location": "multigame_acca_3",
                                "user": "\(userIdFormat)"
                              }
                            }
                          ]
                        }
                        """
            
            let data = body.data(using: String.Encoding.utf8)!
            return data
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        switch self {
        case .popularEvents: return TimeInterval(20)
        case .analyticsTrackEvent: return TimeInterval(5)
        case .promotedBetslips: return TimeInterval(60)
        }
    }
    
    var requireSessionKey: Bool {
        return false
    }
    
    var comment: String? {
        switch self {
        case .popularEvents: return "Vaix popularEvents"
        case .analyticsTrackEvent: return "Vaix Track Event analytics"
        case .promotedBetslips: return "Vaix Track Popular Bets (aka Suggested Bets)"
        }
    }
    
    
}
