//
//  GomaPromotionsAPIClient.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import GomaPerformanceKit

enum GomaDownloadableContentAPISchema {
    case downloadableContents
}

extension GomaDownloadableContentAPISchema: Endpoint {
    
    var url: String {
        return GomaAPIClientConfiguration.shared.apiHostname
    }

    var endpoint: String {
        switch self {
        case .downloadableContents:
            return "/api/cms/v1/downloadable-contents"
        }
    }

    var query: [URLQueryItem]? {
        var queryItems: [URLQueryItem] = []

        // Always add platform=ios for all endpoints
        queryItems.append(URLQueryItem(name: "platform", value: "ios"))

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
        return 5.0
    }

    var requireSessionKey: Bool {
        return true // Require authentication for all endpoints
    }

    var comment: String? {
        switch self {
        case .downloadableContents:
            return "Get downloadable contents"
        }
    }

    var performanceFeature: PerformanceFeature? {
        // Downloadable content is CMS content
        return .cms
    }
}
