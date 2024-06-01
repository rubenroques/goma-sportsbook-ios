//
//  File.swift
//  
//
//  Created by Ruben Roques on 07/05/2024.
//

import Foundation

enum VaixAPIClient {
    case popularEvents(eventsCount: Int)
    case analyticsTrackEvent(event: VaixAnalyticsEvent, userId: String)
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
        }
    }
    
    var query: [URLQueryItem]? {
        var query: [URLQueryItem] = []
        switch self {
        case .popularEvents(let eventsCount):
            query.append(URLQueryItem(name:"user", value:"0"))
            query.append(URLQueryItem(name:"from_offset", value:"-5h"))
            query.append(URLQueryItem(name:"filters", value:"status:eq:live"))
            query.append(URLQueryItem(name:"count", value:"\(eventsCount)"))
            query.append(URLQueryItem(name:"order_by", value:"-event_confidence,+begin"))
            query.append(URLQueryItem(name:"format", value:"orako"))
            query.append(URLQueryItem(name:"location", value:"liveevent-popular"))
        case .analyticsTrackEvent:
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
        }
    }
    
    var method: HTTP.Method {
        switch self {
        case .popularEvents: return .get
        case .analyticsTrackEvent: return .post
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
        }
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        switch self {
        case .popularEvents: return TimeInterval(20)
        case .analyticsTrackEvent: return TimeInterval(5)
        }
    }
    
    var requireSessionKey: Bool {
        return false
    }
    
    var comment: String? {
        switch self {
        case .popularEvents: return "Vaix popularEvents"
        case .analyticsTrackEvent: return "Vaix Track Event analytics"
        }
    }
    
    
}
