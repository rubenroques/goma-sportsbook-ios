//
//  APIError.swift
//  TSSampleApp
//
//  Created by Andrei Marinescu on 09.07.2021.
//

import Foundation

enum APIError: Error {
    case decodingError
    case httpError(Int)
    case unknown
    case missingTransportSessionID
    case notConnected
    case noResultsReceived
    case requestError(value: String)
}
