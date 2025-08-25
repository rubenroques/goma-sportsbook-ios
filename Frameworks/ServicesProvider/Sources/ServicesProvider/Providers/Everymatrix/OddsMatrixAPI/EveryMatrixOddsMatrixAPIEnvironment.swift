//
//  EveryMatrixOddsMatrixAPIEnvironment.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation

/// Environment configuration for EveryMatrix OddsMatrix API
public enum EveryMatrixOddsMatrixAPIEnvironment {
    /// Production environment
    case production
    /// Staging environment
    case staging
    /// Custom environment with specific URL
    case custom(baseURL: String)

    /// Base URL for the environment
    var baseURL: String {
        switch self {
        case .production:
            return "https://sports-api.everymatrix.com"
        case .staging:
            return "https://sports-api-stage.everymatrix.com"
        case .custom(let url):
            return url
        }
    }
    
    // Domain code
    var domainId: String {
        switch self {
        case .staging:
            return "4093"
        case .production:
            return "4093"
        case .custom(baseURL: let baseURL):
            return "4093"
        }
    }
}

/// Configuration for EveryMatrix OddsMatrix API client
public final class EveryMatrixOddsMatrixConfiguration {
    /// Current environment
    public let environment: EveryMatrixOddsMatrixAPIEnvironment

    /// Default timeout interval for requests
    public let defaultTimeout: TimeInterval

    /// Default cache policy for requests
    public let defaultCachePolicy: URLRequest.CachePolicy

    /// Default headers to include in all requests
    public let defaultHeaders: [String: String]

    /// Shared instance with default configuration
    public static let `default` = EveryMatrixOddsMatrixConfiguration(
        environment: .staging,
        defaultTimeout: 30,
        defaultCachePolicy: .reloadIgnoringLocalCacheData,
        defaultHeaders: [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "GOMA/native-app/iOS"
        ]
    )

    /// Initialize a new configuration
    /// - Parameters:
    ///   - environment: The API environment to use
    ///   - defaultTimeout: Default timeout for requests in seconds
    ///   - defaultCachePolicy: Default cache policy for requests
    ///   - defaultHeaders: Default headers to include in all requests
    public init(
        environment: EveryMatrixOddsMatrixAPIEnvironment,
        defaultTimeout: TimeInterval = 30,
        defaultCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData,
        defaultHeaders: [String: String] = [:]
    ) {
        self.environment = environment
        self.defaultTimeout = defaultTimeout
        self.defaultCachePolicy = defaultCachePolicy
        self.defaultHeaders = defaultHeaders
    }
} 
