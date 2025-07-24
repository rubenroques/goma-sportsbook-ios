//
//  GomaPromotionsAPIClient.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

enum GomaPromotionalCampaignsAPISchema {

    // Promotions
    case allPromotions
    case promotionDetails(promotionSlug: String, staticPageSlug: String)
}

extension GomaPromotionalCampaignsAPISchema: Endpoint {
    var url: String {
        return GomaAPIClientConfiguration.shared.apiHostname
    }

    var endpoint: String {
        switch self {

        case .allPromotions:
            return "/api/promotions/v1"
        case .promotionDetails(let promotionSlug, let staticPageSlug):
            return "/api/promotions/v1/\(promotionSlug)/\(staticPageSlug)"
        }
    }

    var query: [URLQueryItem]? {
        return nil
    }

    var headers: HTTP.Headers? {
        // Common headers for all API requests
        return [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "App-Origin": "ios"
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
        case .allPromotions:
            return 30.0
        default:
            return 10.0
        }
    }

    var requireSessionKey: Bool {
        return true // Require anon authentication
    }

    var comment: String? {
        switch self {
        case .allPromotions:
            return "Get all promotional content"
        case .promotionDetails:
            return "Get promotion details content"
        }
    }
}
