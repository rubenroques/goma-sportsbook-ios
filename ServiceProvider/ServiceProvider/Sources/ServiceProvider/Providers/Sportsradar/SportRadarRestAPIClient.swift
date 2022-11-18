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
    case fieldWidgetId(eventId: String)
    case sportsList
}

extension SportRadarRestAPIClient: Endpoint {

    var endpoint: String {
        switch self {
        case .marketsFilter:
            return "/sportradar/sportsbook/config/marketsFilter_v2.json"
        case .fieldWidgetId, .sportsList:
            return "/services/content/get"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .marketsFilter, .fieldWidgetId, .sportsList:
            return nil
        }
    }

    var method: HTTP.Method {
        switch self {
        case .marketsFilter:
            return .get
        case .fieldWidgetId, .sportsList:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .fieldWidgetId(let eventId):
            let bodyString =
            """
            {
                "contentId": {
                    "type": "eventExternalId",
                    "id": "\(eventId)/SportRadarWidget"
                },
                "clientContext": {
                    "language": "UK",
                    "ipAddress": "127.0.0.1"
                }
            }
            """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .sportsList:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "boNavigationList",
                                "id": "1355/top"
                            },
                            "clientContext": {
                                "language": "UK",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        default:
            return nil
        }

        /**
         let body = """
         {"type": "\(type)","text": "\(message)"}
         """
         let data = body.data(using: String.Encoding.utf8)!
         return data
         */
    }

    var url: String {
        switch self {
        case .fieldWidgetId:
            return "https://www-sportbook-goma-int.optimahq.com/"
        default:
            return "https://cdn1.optimahq.com"
        }
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

    var requireSessionKey: Bool {
        return false
    }

}

public struct FieldWidget: Codable {
    public var data: String?
    public var version: Int?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case version = "version"
    }
}

public struct SportsListResponse: Codable {
    public var data: SportsList?

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

public struct SportsList: Codable {
    public var sportNodes: [SportNode]

    enum CodingKeys: String, CodingKey {
        case sportNodes: "bonavigationnodes"
    }
}

public struct SportNode: Codable {
    public var id: String
    public var name: String
    public var numberMarkets: Int
    public var numberEvents: Int
    public var defaultOrder: Int

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case numberMarkets = "nummarkets"
        case numberEvents = "numevents"
        case defaultOrder = "defaultOrder"
    }
}
