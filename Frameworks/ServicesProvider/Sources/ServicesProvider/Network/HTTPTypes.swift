//
//  HTTP.swift
//  
//
//  Created by Ruben Roques on 24/10/2022.
//

import Foundation

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
