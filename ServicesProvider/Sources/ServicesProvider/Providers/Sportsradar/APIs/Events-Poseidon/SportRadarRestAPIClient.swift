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
    case get(contentIdentifier: ContentIdentifier)
    case subscribe(sessionToken: String, contentIdentifier: ContentIdentifier)
    case unsubscribe(sessionToken: String, contentIdentifier: ContentIdentifier)
    case marketsFilter
    case fieldWidgetId(eventId: String)
    case sportsBoNavigationList
    case sportsScheduledList(dateRange: String)
    case sportRegionsNavigationList(sportId: String)
    case regionCompetitions(regionId: String)
    case competitionMarketGroups(competitionId: String)
    case search(query: String, resultLimit: String, page: String, isLive: Bool)
    //case banners
    case getEventSummary(eventId: String)
    case getMarketInfo(marketId: String)

    case getEventDetails(eventId: String)

    case getEventsForMarketGroup(marketGroupId: String)
    case getEventForMarket(marketId: String)

    case homeSliders
    
    case promotionalTopBanners
    case promotionalTopEvents
    case promotionalTopStories
    case highlightsBoostedOddsEvents
    case highlightsImageVisualEvents

    case promotedSports

    case favoritesList
    case addFavoriteList(name: String)
    case addFavoriteToList(listId: Int, eventId: String)
    case getFavoritesFromList(listId: Int)
    case deleteFavoriteList(listId: Int)
    case deleteFavoriteFromList(eventId: Int)

    case getCashbackSuccessBanner
    case getTopCompetitions
    case getTopCompetitionCountry(competitionId: String)
}

extension SportRadarRestAPIClient: Endpoint {

    var endpoint: String {
        switch self {
        //
        case .get:
            return "/services/content/get"
        case .subscribe:
            return "/services/content/subscribe" 
        case .unsubscribe:
            return "/services/content/unsubscribe"
        //
        case .marketsFilter:
            //return "/sportradar/sportsbook/config/marketsFilter_v2.json" // new: "/sportsbook/config/marketsFilter_v2.json"
            return "/sportsbook/config/marketsFilter_v2.json"
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
        case .getEventSummary:
            return "/services/content/get"
        case .getMarketInfo:
            return "/services/content/get"
        case .getEventDetails:
            return "/services/content/get"

        case .getEventsForMarketGroup:
            return "/services/content/get"
        case .getEventForMarket:
            return "/services/content/get"

        //
        case .homeSliders:
            return "/services/content/get"
        case .promotionalTopBanners:
            return "/services/content/get"

        case .promotionalTopEvents:
            return "/services/content/get"
        case .promotionalTopStories:
            return "/services/content/get"

        case .highlightsBoostedOddsEvents:
            return "/services/content/get"
        case .highlightsImageVisualEvents:
            return "/services/content/get"

        case .promotedSports:
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

        case .getCashbackSuccessBanner:
            return "/services/content/get"

        case .getTopCompetitions:
            return "/services/content/get"

        case .getTopCompetitionCountry:
            return "/services/content/get"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .get: return nil
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
        case .getEventSummary: return nil
        case .getMarketInfo: return nil
        case .getEventDetails:  return nil

        case .getEventsForMarketGroup: return nil
        case .getEventForMarket: return nil

        case .homeSliders: return nil
        case .promotionalTopBanners: return nil
        case .promotionalTopEvents: return nil
        case .promotionalTopStories: return nil

        case .highlightsBoostedOddsEvents: return nil
        case .highlightsImageVisualEvents: return nil

        case .promotedSports: return nil

        case .favoritesList: return nil
        case .addFavoriteList: return nil
        case .addFavoriteToList: return nil
        case .getFavoritesFromList: return nil
        case .deleteFavoriteList: return nil
        case .deleteFavoriteFromList: return nil

        case .getCashbackSuccessBanner: return nil
        case .getTopCompetitions: return nil
        case .getTopCompetitionCountry: return nil
        }
    }

    var method: HTTP.Method {
        switch self {
        case .get: return .post
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

        case .getEventSummary: return .post
        case .getMarketInfo: return .post
        case .getEventDetails:  return .post

        case .getEventsForMarketGroup: return .post
        case .getEventForMarket: return .post

        case .homeSliders: return .post
        case .promotionalTopBanners: return .post
        case .promotionalTopEvents: return .post
        case .promotionalTopStories: return .post

        case .highlightsBoostedOddsEvents: return .post
        case .highlightsImageVisualEvents: return .post

        case .promotedSports: return .post

        case .favoritesList: return .get
        case .addFavoriteList: return .post
        case .addFavoriteToList: return .post
        case .getFavoritesFromList: return .post
        case .deleteFavoriteList: return .delete
        case .deleteFavoriteFromList: return .delete

        case .getCashbackSuccessBanner: return .post
        case .getTopCompetitions: return .post
        case .getTopCompetitionCountry: return .post
        }
    }

    var body: Data? {
        switch self {
        case .get(let contentIdentifier):
            return Self.createPayloadData(with: nil, contentIdentifier: contentIdentifier)
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
                    "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/top"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/\(sportId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/\(regionId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/\(competitionId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .search(let query, let resultLimit, let page, let isLive):

            let type = isLive ? "Inplay" : "Prematch"

            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "eventSearch",
                                "id": "\(query)/\(resultLimit)/\(page)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .getEventDetails(let eventId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "event",
                                "id": "\(eventId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
            
        case .homeSliders:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "headline",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/20/HomepageSliders"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .promotionalTopBanners: // TODO: use correct language
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "bannerCategoryList",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/Homepage"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .promotionalTopEvents:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "headline",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/20/slidingEvent"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .promotionalTopStories:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "headline",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/20/InstaCard"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .highlightsBoostedOddsEvents:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "headline",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/20/boostedOddCard"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .highlightsImageVisualEvents:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "headline",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/20/eventCard"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
        case .getMarketInfo(let marketId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "market",
                                "id": "\(marketId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .getEventsForMarketGroup(let marketGroupId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "eventGroup",
                                "id": "\(marketGroupId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .getEventForMarket(let marketId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "market",
                                "id": "\(marketId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .promotedSports:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "boNavigationList",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/top"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .getCashbackSuccessBanner:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "bannerCategoryList",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/cashbackSuccessBanner"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        case .getTopCompetitions:
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "bannerCategoryList",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/QuickLinks"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                                "ipAddress": "127.0.0.1"
                            }
                        }
                        """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()

        case .getTopCompetitionCountry(let competitionId):
            let bodyString =
                        """
                        {
                            "contentId": {
                                "type": "boNavigationList",
                                "id": "\(SportRadarConfiguration.shared.frontEndCode)/\(competitionId)"
                            },
                            "clientContext": {
                                "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
        case .get:
            // https://www-bson-ssb-ua.betsson.fr/services/content/get
            return SportRadarConfiguration.shared.servicesRestHostname
        case .subscribe:
            // https://velsv-bson-ssb-ua.betsson.fr/services/content/subscribe
            return SportRadarConfiguration.shared.servicesSubscribeRestHostname
        case .unsubscribe:
            // https://velsv-bson-ssb-ua.betsson.fr/services/content/unsubscribe
            return SportRadarConfiguration.shared.servicesSubscribeRestHostname

        case .marketsFilter:
            return SportRadarConfiguration.shared.sportRadarFrontEndURL
            
        case .fieldWidgetId:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .sportsBoNavigationList:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .sportsScheduledList:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .sportRegionsNavigationList:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .regionCompetitions:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .competitionMarketGroups:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .search:
            return SportRadarConfiguration.shared.servicesRestHostname

        case .getEventSummary:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .getMarketInfo:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .getEventDetails:
            return SportRadarConfiguration.shared.servicesRestHostname

        case .getEventsForMarketGroup:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .getEventForMarket:
            return SportRadarConfiguration.shared.servicesRestHostname

        case .homeSliders:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .promotionalTopBanners:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .promotionalTopEvents:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .promotionalTopStories:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .highlightsBoostedOddsEvents:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .highlightsImageVisualEvents:
            return SportRadarConfiguration.shared.servicesRestHostname

        case .promotedSports:
            return SportRadarConfiguration.shared.servicesRestHostname

        case .favoritesList:
            return SportRadarConfiguration.shared.apiRestHostname
        case .addFavoriteList:
            return SportRadarConfiguration.shared.apiRestHostname
        case .addFavoriteToList:
            return SportRadarConfiguration.shared.apiRestHostname
        case .getFavoritesFromList:
            return SportRadarConfiguration.shared.apiRestHostname
        case .deleteFavoriteList:
            return SportRadarConfiguration.shared.apiRestHostname
        case .deleteFavoriteFromList:
            return SportRadarConfiguration.shared.apiRestHostname

        case .getCashbackSuccessBanner:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .getTopCompetitions:
            return SportRadarConfiguration.shared.servicesRestHostname
        case .getTopCompetitionCountry:
            return SportRadarConfiguration.shared.servicesRestHostname
        }
    }

    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Media-Type": "application/json",
            "app-origin": "ios",
            "Accept": "application/json"
        ]

        switch self {
        case .get:
            return defaultHeaders
        case .subscribe:
            return ["Content-Type": "application/json",
                    "app-origin": "ios",
                    "Media-Type": "application/json"]
        case .unsubscribe:
            return ["Content-Type": "application/json",
                    "app-origin": "ios",
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

        case .getEventSummary:
            return defaultHeaders
        case .getMarketInfo:
            return defaultHeaders
        case .getEventDetails:
            return defaultHeaders

        case .getEventsForMarketGroup:
            return defaultHeaders
        case .getEventForMarket:
            return defaultHeaders
            
        case .highlightsBoostedOddsEvents:
            return defaultHeaders
        case .highlightsImageVisualEvents:
            return defaultHeaders

        case .promotedSports:
            return defaultHeaders
            
        case .homeSliders:
            return defaultHeaders
        case .promotionalTopBanners:
            return defaultHeaders
        case .promotionalTopEvents:
            return defaultHeaders
        case .promotionalTopStories:
            return defaultHeaders
        case .getCashbackSuccessBanner:
            return defaultHeaders
        case .getTopCompetitions:
            return defaultHeaders
        case .getTopCompetitionCountry:
            return defaultHeaders
            
        case .favoritesList, .addFavoriteList, .addFavoriteToList, .getFavoritesFromList, .deleteFavoriteList, .deleteFavoriteFromList:
            return [
                "Accept-Encoding": "gzip, deflate, br",
                "Content-Type": "application/json; charset=UTF-8",
                "Media-Type": "application/json",
                "Accept": "application/json",
                "X-MGS-BusinessUnit": "3",
                "app-origin": "ios",
                "Accept-Languag": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                "X-MGS-Location": "\(SportRadarConfiguration.shared.socketLanguageCode)",
            ]

        }
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        switch self {
        case .subscribe: return TimeInterval(60)
        case .unsubscribe: return TimeInterval(20)
        default: return TimeInterval(120)
        }
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

    var comment: String? {
        switch self {
        case .get(let contentIdentifier):
            return "get-\(contentIdentifier.contentType)"
        case .subscribe(_, let contentIdentifier):
            return "subscribe-\(contentIdentifier.contentType)"
        case .unsubscribe(_, let contentIdentifier):
            return "unsubscribe-\(contentIdentifier.contentType)"
        case .marketsFilter: return "marketsFilter"
        case .fieldWidgetId: return "fieldWidgetId"
        case .sportsBoNavigationList: return "sportsBoNavigationList"
        case .sportsScheduledList: return "sportsScheduledList"
        case .sportRegionsNavigationList: return "sportRegionsNavigationList"
        case .regionCompetitions: return "regionCompetitions"
        case .competitionMarketGroups(let competitionId): return "competitionMarketGroups \(competitionId)"
        case .search: return "search"
        case .getEventSummary(let eventId): return "getEventSummary \(eventId)"
        case .getMarketInfo: return "getMarketInfo"
        case .getEventDetails(let eventId): return "getEventDetails \(eventId)"
        case .getEventsForMarketGroup(let marketGroupId): return "getEventsForMarketGroup \(marketGroupId)"
        case .getEventForMarket(let marketId): return "getEventForMarket \(marketId)"
        case .homeSliders: return "homeSliders"
        case .promotionalTopBanners: return "promotionalTopBanners"
        case .promotionalTopEvents: return "promotionalTopEvents"
        case .promotionalTopStories: return "promotionalTopStories"
        case .highlightsBoostedOddsEvents: return "highlightsBoostedOddsEvents"
        case .highlightsImageVisualEvents: return "highlightsImageVisualEvents"
        case .promotedSports: return "promotedSports"
        case .favoritesList: return "favoritesList"
        case .addFavoriteList: return "addFavoriteList"
        case .addFavoriteToList: return "addFavoriteToList"
        case .getFavoritesFromList: return "getFavoritesFromList"
        case .deleteFavoriteList: return "deleteFavoriteList"
        case .deleteFavoriteFromList: return "deleteFavoriteFromList"
        case .getCashbackSuccessBanner: return "getCashbackSuccessBanner"
        case .getTopCompetitions: return "getTopCompetitions PointersOnly"
        case .getTopCompetitionCountry(let competitionId): return "getTopCompetitionCountry \(competitionId)"
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
                        "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
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
                        "language": "\(SportRadarConfiguration.shared.socketLanguageCode)",
                        "ipAddress": "127.0.0.1"
                    }
                }
                """
            return bodyString.data(using: String.Encoding.utf8) ?? Data()
        }
    }

}
