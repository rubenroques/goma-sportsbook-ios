//
//  NetworkErrorResponse.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

enum NetworkErrorMessage: String, Decodable, Error {
    case invalidToken = "invalid_token"
    case invalidRequest = "invalid_request"
    case invalidResponse = "invalid_response"
    case unauthorized = "unauthorized"
    case unknown = "unknown"
}

struct NetworkErrorResponse: Decodable, Error {
    let errors: [NetworkErrorMessage]
}
