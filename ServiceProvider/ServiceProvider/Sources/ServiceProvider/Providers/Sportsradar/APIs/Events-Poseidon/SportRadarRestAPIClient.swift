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
    case sportsBoNavigationList
    case sportsScheduledList(dateRange: String)
}

extension SportRadarRestAPIClient: Endpoint {

    var endpoint: String {
        switch self {
        case .marketsFilter:
            return "/sportradar/sportsbook/config/marketsFilter_v2.json"
        case .fieldWidgetId:
            return "/services/content/get"
        case .sportsBoNavigationList:
            return "/services/content/get"
        case .sportsScheduledList:
            return "/services/content/get"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .marketsFilter, .fieldWidgetId, .sportsBoNavigationList, .sportsScheduledList:
            return nil
        }
    }

    var method: HTTP.Method {
        switch self {
        case .marketsFilter:
            return .get
        case .fieldWidgetId, .sportsBoNavigationList, .sportsScheduledList:
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
        case .sportsBoNavigationList:
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
        case .sportsScheduledList(let dateRange):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "sportTypeByDate",
                                "id": "\(dateRange)"
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
    }

    var url: String {
        switch self {
        case .marketsFilter:
            return SportRadarConstants.sportRadarFrontEndURL
        case .fieldWidgetId:
            return SportRadarConstants.bettingHostname
        case .sportsBoNavigationList:
            return SportRadarConstants.bettingHostname
        case .sportsScheduledList:
            return SportRadarConstants.bettingHostname
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

// TODO: TASK André - Estes modelos estão no sitio errado
public struct FieldWidget: Codable {
    public var data: String?
    public var version: Int?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case version = "version"
    }
}

public struct SportRadarResponse<T: Codable>: Codable {

    let data: T?

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

public struct SportsList: Codable {
    public var sportNodes: [SportNode]?

    enum CodingKeys: String, CodingKey {
        case sportNodes = "bonavigationnodes"
    }
}

public struct SportNode: Codable {
    public var id: String
    public var name: String
    public var numberEvents: String
    public var numberOutrightEvents: String
    public var numberOutrightMarkets: String

    enum CodingKeys: String, CodingKey {
        case id = "idfwbonavigation"
        case name = "name"
        case numberEvents = "numevents"
        case numberOutrightEvents = "numoutrightevents"
        case numberOutrightMarkets = "numoutrightmarkets"
    }
}

public struct ScheduledSport: Codable {
    public var id: String
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id = "idfosporttype"
        case name = "name"
    }

}

public struct SportType: Codable, Hashable {
    public var name: String
    public var numericId: String?
    public var alphaId: String?
    public var iconId: String?
    public var numberEvents: String?
    public var numberOutrightEvents: String?
    public var numberOutrightMarkets: String?

    public init(name: String, numericId: String? = nil, alphaId: String? = nil, iconId: String? = nil, numberEvents: String? = nil, numberOutrightEvents: String? = nil, numberOutrightMarkets: String? = nil) {
        self.name = name
        self.numericId = numericId
        self.alphaId = alphaId
        self.iconId = iconId
        self.numberEvents = numberEvents
        self.numberOutrightEvents = numberOutrightEvents
        self.numberOutrightMarkets = numberOutrightMarkets
    }
}
