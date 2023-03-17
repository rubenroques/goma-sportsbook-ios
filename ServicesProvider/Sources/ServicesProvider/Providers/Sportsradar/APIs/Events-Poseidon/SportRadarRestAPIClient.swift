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
    case banners
    case getEventSummary(eventId: String)
    case favoritesList
    case addFavoriteList(name: String)
    case addFavoriteToList(listId: Int, eventId: String)
    case getFavoritesFromList(listId: Int)
    case deleteFavoriteList(listId: Int)
    case deleteFavoriteFromList(eventId: Int)
}

extension SportRadarRestAPIClient: Endpoint {

    var endpoint: String {
        switch self {
        //
        case .subscribe:
            return "/services/content/subscribe" 
        case .unsubscribe:
            return "/services/content/unsubscribe"
        //
        case .marketsFilter:
            return "/sportradar/sportsbook/config/marketsFilter_v2.json" // new: "/sportsbook/config/marketsFilter_v2.json"

        //
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
        case .banners:
            return "/services/content/get"
        case .getEventSummary:
            return "/services/content/get"

        //
        case .favoritesList:
            return "/api/favourites/fw/getAccountFavouriteCoupon"
        case .addFavoriteList:
            return "/api/favourites/fw/addAccountFavouriteCoupon"
        case .addFavoriteToList:
            return "/api/favourites/fw/addAccountFavourite"
        case .getFavoritesFromList:
            return "/api/favourites/fw/getFavouritesForCustomer"
        case .deleteFavoriteList:
            return "/api/favourites/fw/deleteAccountFavouriteCoupon"
        case .deleteFavoriteFromList:
            return "/api/favourites/fw/deleteAccountFavourites"
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
        case .banners: return nil
        case .getEventSummary: return nil
        case .favoritesList: return nil
        case .addFavoriteList: return nil
        case .addFavoriteToList: return nil
        case .getFavoritesFromList: return nil
        case .deleteFavoriteList: return nil
        case .deleteFavoriteFromList: return nil
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
        case .banners: return .post
        case .getEventSummary: return .post
        case .favoritesList: return .get
        case .addFavoriteList: return .post
        case .addFavoriteToList: return .post
        case .getFavoritesFromList: return .post
        case .deleteFavoriteList: return .delete
        case .deleteFavoriteFromList: return .delete
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
                    "language": "\(SportRadarConstants.socketLanguageCode)",
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
                                "language": "\(SportRadarConstants.socketLanguageCode)",
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
                                "language": "\(SportRadarConstants.socketLanguageCode)",
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
                                "language": "\(SportRadarConstants.socketLanguageCode)",
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
                                "language": "\(SportRadarConstants.socketLanguageCode)",
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
                                "language": "\(SportRadarConstants.socketLanguageCode)",
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
                                "language": "\(SportRadarConstants.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .banners:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "headline",
                                "id": "1355/20/HomepageSliders"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConstants.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .getEventSummary(let eventId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "eventSummary",
                                "id": "\(eventId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConstants.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .addFavoriteList(let name):
            let bodyString =
                        """
                        {
                            "name": "\(name)"
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .addFavoriteToList(let listId, let eventId):
            let bodyString =
                        """
                        {
                            "idfwAccountFavouriteCoupon": \(listId),
                            "niddcUserReq": null,
                            "nidmmCustomer":  null,
                            "sfavouriteContent": ["\(eventId)"],
                            "sfavouriteID": "\(eventId)",
                            "sidfwFavouriteType": "N"
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .getFavoritesFromList(let listId):
            let bodyString =
                        """
                        {
                            "idfwAccountFavouriteCoupon": \(listId)
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .deleteFavoriteList(let listId):
            let bodyString =
                        """
                        {
                            "idfwAccountFavouriteCoupon": "\(listId)"
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .deleteFavoriteFromList(let eventId):
            let bodyString =
                        """
                        {
                            "nidfwAccountFavourites": \(eventId)
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
            return SportRadarConstants.servicesRestHostname
        case .unsubscribe:
            return SportRadarConstants.servicesRestHostname

        case .marketsFilter:
            return SportRadarConstants.sportRadarLegacyFrontEndURL
//            return SportRadarConstants.sportRadarFrontEndURL
            
        case .fieldWidgetId:
            return SportRadarConstants.servicesRestHostname
        case .sportsBoNavigationList:
            return SportRadarConstants.servicesRestHostname
        case .sportsScheduledList:
            return SportRadarConstants.servicesRestHostname
        case .sportRegionsNavigationList:
            return SportRadarConstants.servicesRestHostname
        case .regionCompetitions:
            return SportRadarConstants.servicesRestHostname
        case .competitionMarketGroups:
            return SportRadarConstants.servicesRestHostname
        case .search:
            return SportRadarConstants.servicesRestHostname
        case .banners:
            return SportRadarConstants.servicesRestHostname
        case .getEventSummary:
            return SportRadarConstants.servicesRestHostname

        case .favoritesList:
            return SportRadarConstants.apiRestHostname
        case .addFavoriteList:
            return SportRadarConstants.apiRestHostname
        case .addFavoriteToList:
            return SportRadarConstants.apiRestHostname
        case .getFavoritesFromList:
            return SportRadarConstants.apiRestHostname
        case .deleteFavoriteList:
            return SportRadarConstants.apiRestHostname
        case .deleteFavoriteFromList:
            return SportRadarConstants.apiRestHostname
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
        case .banners:
            return defaultHeaders
        case .getEventSummary:
            return defaultHeaders
        case .favoritesList, .addFavoriteList, .addFavoriteToList, .getFavoritesFromList, .deleteFavoriteList, .deleteFavoriteFromList:
            return [
                "Accept-Encoding": "gzip, deflate, br",
                "Content-Type": "application/json; charset=UTF-8",
                "Media-Type": "application/json",
                "Accept": "application/json",
                "X-MGS-BusinessUnit": "3",
                "X-MGS-Location": "UK",
            ]
        }
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        return TimeInterval(20)
    }

    var requireSessionKey: Bool {
        switch self {
        case .favoritesList:
            return true
        case .addFavoriteList:
            return true
        case .addFavoriteToList:
            return true
        case .deleteFavoriteList:
            return true
        case .getFavoritesFromList:
            return true
        case .deleteFavoriteFromList:
            return true
        default:
            return false
        }
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
