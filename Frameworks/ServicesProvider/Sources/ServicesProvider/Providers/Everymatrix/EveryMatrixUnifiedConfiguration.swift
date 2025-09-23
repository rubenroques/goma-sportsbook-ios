//
//  EveryMatrixUnifiedConfiguration.swift
//  ServicesProvider
//
//  Unified configuration for all EveryMatrix APIs
//  Following the same pattern as SportRadarConfiguration
//

import Foundation

/// Unified configuration for all EveryMatrix APIs
public final class EveryMatrixUnifiedConfiguration {
    
    public static let cacheCIDKey: String = "wamp.session.cid"
    
    /// Environment options matching Client.Configuration.Environment
    public enum Environment {
        case production
        case staging
        case development
    }
    
    /// Current environment - mutable to allow runtime configuration
    public var environment: Environment
    
    /// Shared instance - mutable like SportRadarConfiguration
    public static var shared = EveryMatrixUnifiedConfiguration(environment: .staging)
    
    /// Initialize with environment
    init(environment: Environment) {
        self.environment = environment
    }
    
    // MARK: - Player API Configuration
    
    /// Base URL for Player API
    public var playerAPIBaseURL: String {
        switch environment {
        case .production:
            return "https://betsson-api.everymatrix.com"
        case .staging, .development:
            return "https://betsson-api.stage.norway.everymatrix.com"
        }
    }
    
    // MARK: - OddsMatrix API Configuration
    
    /// Base URL for OddsMatrix API (Sports/Betting)
    public var oddsMatrixBaseURL: String {
        switch environment {
        case .production:
            return "https://sports-api.everymatrix.com"
        case .staging, .development:
            return "https://sports-api-stage.everymatrix.com"
        }
    }
    
    // MARK: - Casino API Configuration
    
    /// Base URL for Casino API
    public var casinoAPIBaseURL: String {
        switch environment {
        case .production:
            return "https://betsson-api.norway.everymatrix.com"
        case .staging, .development:
            return "https://betsson-api.stage.norway.everymatrix.com"
        }
    }
    
    /// Game launch URL for casino games
    public var gameLaunchBaseURL: String {
        switch environment {
        case .production:
            return "https://gamelaunch.everymatrix.com"
        case .staging, .development:
            return "https://gamelaunch-stage.everymatrix.com"
        }
    }
    
    /// Casino datasource for v2 API endpoints
    public var casinoDataSource: String {
        switch environment {
        case .production:
            return "Lobby1" // TODO: Verify production datasource
        case .staging, .development:
            return "Lobby1"
        }
    }
    
    // MARK: - Shared Configuration
    
    /// Domain ID for all APIs
    public var domainId: String {
        switch environment {
        case .production:
            return "4093" // TODO: Verify production domain ID
        case .staging, .development:
            return "4093"
        }
    }
    
    /// Default timeout for requests
    public var defaultTimeout: TimeInterval = 30
    
    /// Default cache policy for requests
    public var defaultCachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    
    /// Default headers for all requests
    public var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "GOMA/native-app/iOS"
        ]
    }
    
    /// Default language for APIs
    public var defaultLanguage: String {
        return "en"
    }
    
    /// Default platform identifier
    public var defaultPlatform: String {
        return "iOS"
    }
    
    public var defaultCasinoPlatform: String {
        return "iPhone"
    }
    
}
