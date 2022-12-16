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
    case subscribe(sessionToken: String, contentIdentifier: ContentIdentifier)
    case unsubscribe(sessionToken: String, contentIdentifier: ContentIdentifier)
    case marketsFilter
    case fieldWidgetId(eventId: String)
    case sportsBoNavigationList
    case sportsScheduledList(dateRange: String)
    case sportRegionsNavigationList(sportId: String)
    case regionCompetitions(regionId: String)
    case competitionMarketGroups(competitionId: String)
    case search(query: String, resultLimit: String, page: String)
}

extension SportRadarRestAPIClient: Endpoint {

    var endpoint: String {
        switch self {

        case .subscribe:
            return "/services/content/subscribe" 
        case .unsubscribe:
            return "/services/content/unsubscribe"

        case .marketsFilter:
            return "/sportradar/sportsbook/config/marketsFilter_v2.json"
        case .fieldWidgetId:
            return "/services/content/get"
        case .sportsBoNavigationList:
            return "/services/content/get"
        case .sportsScheduledList:
            return "/services/content/get"
        case .sportRegionsNavigationList:
            return "/services/content/get"
        case .regionCompetitions:
            return "/services/content/get"
        case .competitionMarketGroups:
            return "/services/content/get"
        case .search:
            return "/services/content/get"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .subscribe: return nil
        case .unsubscribe: return nil
        case .marketsFilter: return nil
        case .fieldWidgetId: return nil
        case .sportsBoNavigationList: return nil
        case .sportsScheduledList: return nil
        case .sportRegionsNavigationList: return nil 
        case .regionCompetitions: return nil
        case .competitionMarketGroups: return nil
        case .search: return nil
        }
    }

    var method: HTTP.Method {
        switch self {
        case .subscribe: return .post
        case .unsubscribe: return .post
        case .marketsFilter: return .get
        case .fieldWidgetId: return .post
        case .sportsBoNavigationList: return .post
        case .sportsScheduledList: return .post
        case .sportRegionsNavigationList: return .post 
        case .regionCompetitions: return .post
        case .competitionMarketGroups: return .post
        case .search: return .post
        }
    }

    var body: Data? {
        switch self {
        case .subscribe(let sessionToken, let contentIdentifier):
            return Self.createPayloadData(with: sessionToken, contentIdentifier: contentIdentifier)
        case .unsubscribe(let sessionToken, let contentIdentifier):
            return Self.createPayloadData(with: sessionToken, contentIdentifier: contentIdentifier)
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
        case .sportRegionsNavigationList(let sportId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "boNavigationList",
                                "id": "1355/\(sportId)"
                            },
                            "clientContext": {
                                "language": "UK",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .regionCompetitions(let regionId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "boNavigationList",
                                "id": "1355/\(regionId)"
                            },
                            "clientContext": {
                                "language": "UK",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .competitionMarketGroups(let competitionId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "boNavigationList",
                                "id": "1355/\(competitionId)"
                            },
                            "clientContext": {
                                "language": "UK",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .search(let query, let resultLimit, let page):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "eventSearch",
                                "id": "\(query)/\(resultLimit)/\(page)"
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

        case .subscribe:
            return SportRadarConstants.socketRestHostname
        case .unsubscribe:
            return SportRadarConstants.socketRestHostname

        case .marketsFilter:
            return SportRadarConstants.sportRadarFrontEndURL
        case .fieldWidgetId:
            return SportRadarConstants.bettingHostname
        case .sportsBoNavigationList:
            return SportRadarConstants.bettingHostname
        case .sportsScheduledList:
            return SportRadarConstants.bettingHostname
        case .sportRegionsNavigationList:
            return SportRadarConstants.bettingHostname
        case .regionCompetitions:
            return SportRadarConstants.bettingHostname
        case .competitionMarketGroups:
            return SportRadarConstants.bettingHostname
        case .search:
            return SportRadarConstants.bettingHostname
        }
    }

    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Media-Type": "application/json",
            "Accept": "application/json"
        ]
        switch self {
        case .subscribe(_, _):
            return ["Content-Type": "application/json",
                    "Media-Type": "application/json"]
        case .unsubscribe(_ ,_):
            return ["Content-Type": "application/json",
                    "Media-Type": "application/json"]
        case .marketsFilter:
            return defaultHeaders
        case .fieldWidgetId(_):
            return defaultHeaders
        case .sportsBoNavigationList:
            return defaultHeaders
        case .sportsScheduledList(_):
            return defaultHeaders
        case .sportRegionsNavigationList:
            return defaultHeaders
        case .regionCompetitions:
            return defaultHeaders
        case .competitionMarketGroups:
            return defaultHeaders
        case .search:
            return defaultHeaders
        }
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

extension SportRadarRestAPIClient {

    private static func createPayloadData(with sessionToken: String?,
                                          contentIdentifier: ContentIdentifier) -> Data {
        if let sessionToken = sessionToken {
            let bodyString =
                """
                {
                    "subscriberId": "\(sessionToken)",
                    "contentId": {
                        "type": "\(contentIdentifier.contentType.rawValue)",
                        "id": "\(contentIdentifier.contentRoute.fullRoute)"
                    },
                    "clientContext": {
                        "language": "\(SportRadarConstants.socketLanguageCode)",
                        "ipAddress": "127.0.0.1"
                    }
                }
                """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        }
        else {
            let bodyString =
                """
                {
                    "contentId": {
                        "type": "\(contentIdentifier.contentType.rawValue)",
                        "id": "\(contentIdentifier.contentRoute.fullRoute)"
                    },
                    "clientContext": {
                        "language": "\(SportRadarConstants.socketLanguageCode)",
                        "ipAddress": "127.0.0.1"
                    }
                }
                """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        }
    }

}
