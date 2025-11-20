//
//  Endpoint.swift
//
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation
import GomaPerformanceKit

enum AuthHeaderType {
    case sessionId
    case userId
}

protocol Endpoint {
    var url: String { get }
    var endpoint: String { get }
    var query: [URLQueryItem]? { get }
    var headers: HTTP.Headers? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var method: HTTP.Method { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
    var requireSessionKey: Bool { get }
    var comment: String? { get }
    
    func authHeaderKey(for type: AuthHeaderType) -> String?
}

extension Endpoint {
    // Default implementation - endpoints can override for specific auth headers
    func authHeaderKey(for type: AuthHeaderType) -> String? {
        return nil
    }
    
    func request(aditionalQueryItems: [URLQueryItem] = [],
                 aditionalHeaders: HTTP.Headers? = nil) -> URLRequest? {

        guard var urlComponents = URLComponents(string: self.url) else { return nil }
        urlComponents.path = self.endpoint
        
        var fullQuery = self.query ?? []
        fullQuery.append(contentsOf: aditionalQueryItems)
        urlComponents.queryItems = fullQuery

        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")
        
        guard let completedURL = urlComponents.url else { return nil }

        var request = URLRequest(url: completedURL)
        request.httpMethod = self.method.value()
        request.timeoutInterval = self.timeout
        request.httpBody = self.body
        
        if let headersValue = self.headers {
            for (key, value) in headersValue {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let aditionalHeadersValue = aditionalHeaders {
            for (key, value) in aditionalHeadersValue {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        print("[GOMAAPI][DEBUG] Endpoint request created: ",
              dump(request),
              " -- with body: ",
              String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "[no body]"
        )

        return request
    }

    /// Performance tracking feature for this endpoint
    /// Return nil for endpoints that shouldn't be tracked
    /// Override in specific API enums to declare tracking features
    var performanceFeature: PerformanceFeature? {
        return nil // Default: no tracking
    }

    /// Computed property for convenient path access
    var path: String {
        return endpoint
    }
}
