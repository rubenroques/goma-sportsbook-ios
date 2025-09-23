//
//  RecommendationEndpoint.swift
//  ServicesProvider
//
//  Created for handling recommendation API endpoints
//

import Foundation

/// Endpoint for the recommendation API
struct RecommendationEndpoint: Endpoint {
    let url: String
    let endpoint: String
    let query: [URLQueryItem]?
    let headers: HTTP.Headers?
    let cachePolicy: URLRequest.CachePolicy
    let method: HTTP.Method
    let body: Data?
    let timeout: TimeInterval
    let requireSessionKey: Bool
    let comment: String?
    
    init(domainId: Int, userId: String, isLive: Bool, terminalType: Int, apiKey: String) {
        self.url = "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev"
        self.endpoint = "/recommendations"
        self.query = [
            URLQueryItem(name: "domain_id", value: String(domainId)),
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "is_live", value: String(isLive)),
            URLQueryItem(name: "terminal_type", value: String(terminalType)),
            URLQueryItem(name: "key", value: apiKey)
        ]
        self.headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        self.cachePolicy = .useProtocolCachePolicy
        self.method = .get
        self.body = nil
        self.timeout = 30.0
        self.requireSessionKey = false
        self.comment = "Get recommended matches for user"
    }
}
