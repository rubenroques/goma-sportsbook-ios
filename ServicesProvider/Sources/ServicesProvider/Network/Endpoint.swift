//
//  Endpoint.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation

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
}

extension Endpoint {
    func request(aditionalQueryItems: [URLQueryItem] = [],
                 aditionalHeaders: HTTP.Headers? = nil) -> URLRequest? {

        guard var urlComponents = URLComponents(string: url) else { return nil }
        urlComponents.path = self.endpoint
        
        var fullQuery = self.query ?? []
        fullQuery.append(contentsOf: aditionalQueryItems)
        urlComponents.queryItems = fullQuery

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
