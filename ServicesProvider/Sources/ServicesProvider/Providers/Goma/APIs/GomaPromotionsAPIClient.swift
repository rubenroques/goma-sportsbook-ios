//
//  GomaPromotionsAPIClient.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

enum GomaPromotionsAPIClient {
    // Home Template
    case homeTemplate(platform: String, clientId: Int?, userType: String?)

    // Promotions
    case allPromotions(clientId: Int?, platform: String?, userType: String?)
    case alertBanner(clientId: Int?, platform: String?, userType: String?)
    case banners(clientId: Int?, platform: String?, userType: String?)
    case sportBanners(clientId: Int?, platform: String?, userType: String?)
    case boostedOddsBanners(clientId: Int?, platform: String?, userType: String?)
    case heroCards(clientId: Int?, platform: String?, userType: String?)
    case stories(clientId: Int?, platform: String?, userType: String?)
    case news(clientId: Int?, platform: String?, userType: String?, pageIndex: Int, pageSize: Int)
    case proChoices(clientId: Int?, platform: String?, userType: String?)
}

extension GomaPromotionsAPIClient: Endpoint {
    var url: String {
        return SportRadarConfiguration.shared.clientBaseUrl
    }

    var endpoint: String {
        switch self {
        case .homeTemplate:
            return "/api/home/v1/template"
        case .allPromotions:
            return "/api/promotions/v1"
        case .alertBanner:
            return "/api/promotions/v1/alert-banner"
        case .banners:
            return "/api/promotions/v1/banners"
        case .sportBanners:
            return "/api/promotions/v1/sport-banners"
        case .boostedOddsBanners:
            return "/api/promotions/v1/boosted-odds-banners"
        case .heroCards:
            return "/api/promotions/v1/hero-cards"
        case .stories:
            return "/api/promotions/v1/stories"
        case .news:
            return "/api/promotions/v1/news"
        case .proChoices:
            return "/api/promotions/v1/pro-choices"
        }
    }

    var query: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []

        switch self {
        case .homeTemplate(let platform, let clientId, let userType):
            queryItems.append(URLQueryItem(name: "platform", value: platform))

            if let clientId = clientId {
                queryItems.append(URLQueryItem(name: "client_id", value: "\(clientId)"))
            }

            if let userType = userType {
                queryItems.append(URLQueryItem(name: "user_type", value: userType))
            }

        case .allPromotions(let clientId, let platform, let userType),
             .alertBanner(let clientId, let platform, let userType),
             .banners(let clientId, let platform, let userType),
             .sportBanners(let clientId, let platform, let userType),
             .boostedOddsBanners(let clientId, let platform, let userType),
             .heroCards(let clientId, let platform, let userType),
             .stories(let clientId, let platform, let userType),
             .proChoices(let clientId, let platform, let userType):

            if let clientId = clientId {
                queryItems.append(URLQueryItem(name: "client_id", value: "\(clientId)"))
            }

            if let platform = platform {
                queryItems.append(URLQueryItem(name: "platform", value: platform))
            }

            if let userType = userType {
                queryItems.append(URLQueryItem(name: "user_type", value: userType))
            }

        case .news(let clientId, let platform, let userType, let pageIndex, let pageSize):
            if let clientId = clientId {
                queryItems.append(URLQueryItem(name: "client_id", value: "\(clientId)"))
            }

            if let platform = platform {
                queryItems.append(URLQueryItem(name: "platform", value: platform))
            }

            if let userType = userType {
                queryItems.append(URLQueryItem(name: "user_type", value: userType))
            }

            queryItems.append(URLQueryItem(name: "page", value: "\(pageIndex)"))
            queryItems.append(URLQueryItem(name: "page_size", value: "\(pageSize)"))
        }

        return queryItems.isEmpty ? nil : queryItems
    }

    var headers: HTTP.Headers? {
        // Common headers for all API requests
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var method: HTTP.Method {
        return .get // All endpoints use GET method
    }

    var body: Data? {
        return nil // None of these endpoints require a request body
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    var timeout: TimeInterval {
        switch self {
        case .homeTemplate:
            return 15.0
        case .allPromotions:
            return 30.0
        case .news:
            return 20.0
        default:
            return 10.0
        }
    }

    var requireSessionKey: Bool {
        return true // Require authentication for all endpoints
    }

    var comment: String? {
        switch self {
        case .homeTemplate:
            return "Get home template configuration"
        case .allPromotions:
            return "Get all promotional content"
        case .alertBanner:
            return "Get alert banner"
        case .banners:
            return "Get promotional banners"
        case .sportBanners:
            return "Get sport banners"
        case .boostedOddsBanners:
            return "Get boosted odds banners"
        case .heroCards:
            return "Get hero cards"
        case .stories:
            return "Get promotional stories"
        case .news:
            return "Get news articles"
        case .proChoices:
            return "Get pro betting choices"
        }
    }
}