//
//  SportRadarRestAPIClient.swift
//  
//
//  Created by André Lascas on 02/11/2022.
//

import Foundation

/* https://cdn1.optimahq.com/sportradar/sportsbook/config/marketsFilter_v2.json
 */

enum SportRadarRestAPIClient {
    case marketsFilter
}

extension SportRadarRestAPIClient: Endpoint {
    var endpoint: String {
        switch self {
        case .marketsFilter:
            return "/sportradar/sportsbook/config/marketsFilter_v2.json"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .marketsFilter:
            return nil
        }
    }

    var method: HTTP.Method {
        switch self {
        case .marketsFilter: return .get
        }
    }

    var body: Data? {
        return nil

        /**
         let body = """
         {"type": "\(type)","text": "\(message)"}
         """
         let data = body.data(using: String.Encoding.utf8)!
         return data
         */
    }

    var url: String {
        return "https://cdn1.optimahq.com"
    }

    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json"
        ]
        return defaultHeaders
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        return TimeInterval(20)
    }

}
