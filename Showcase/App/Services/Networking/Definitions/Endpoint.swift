//
//  Endpoint.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/08/2021.
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
}

extension Endpoint {
    func request() -> URLRequest? {

        guard var urlComponents = URLComponents(string: url) else { return nil }
        urlComponents.path = endpoint
        urlComponents.queryItems = query

        guard let completedURL = urlComponents.url else { return nil }

        var request = URLRequest(url: completedURL)
        request.httpMethod = self.method.value()
        request.timeoutInterval = timeout
        request.httpBody = body
        if let headersValue = headers {
            for (key, value) in headersValue {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
}

struct HTTP {
    enum Method {
        case get
        case post
        case delete
        case put

        func value() -> String {
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

    typealias Headers = [String: String]

    typealias Parameters = [String: String]
}
