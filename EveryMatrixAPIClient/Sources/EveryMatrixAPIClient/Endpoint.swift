//
//  Endpoint.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation

/// Protocol defining an API endpoint
public protocol Endpoint {
    /// Base URL for the API
    var url: String { get }
    
    /// Path component of the endpoint
    var endpoint: String { get }
    
    /// HTTP method for the endpoint
    var method: HTTP.Method { get }
    
    /// Query parameters for the endpoint
    var query: [URLQueryItem]? { get }
    
    /// HTTP headers for the endpoint
    var headers: HTTP.Headers? { get }
    
    /// Request body for the endpoint
    var body: Data? { get }
    
    /// Cache policy for the request
    var cachePolicy: URLRequest.CachePolicy { get }
    
    /// Timeout interval for the request
    var timeout: TimeInterval { get }
    
    /// Whether the request requires a session key
    var requireSessionKey: Bool { get }
    
    /// Optional comment for the endpoint
    var comment: String? { get }
}

extension Endpoint {
    func request(aditionalQueryItems: [URLQueryItem] = [],
                 aditionalHeaders: HTTP.Headers? = nil) -> URLRequest? {

        guard var urlComponents = URLComponents(string: url) else { return nil }
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

        return request
    }
}

public struct HTTP {
    public enum Method {
        case get
        case post
        case delete
        case put

        public func value() -> String {
            switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .delete:
                return "DELETE"
            case .put:
                return "PUT"
            }
        }
    }

    public typealias Headers = [String: String]

    public typealias Parameters = [String: String]
}
