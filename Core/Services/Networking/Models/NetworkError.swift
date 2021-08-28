//
//  NetworkErrorResponse.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

enum NetworkErrorCode: String, Decodable, Error {
    case invalidToken = "invalid_token"
    case invalidRequest = "invalid_request"
    case invalidResponse = "invalid_response"
    case unauthorized = "unauthorized"
    case forbidden = "forbidden"
    case unknown = "unknown"
}

struct NetworkError: Decodable, Error {
    let errors: [NetworkErrorCode]
}
