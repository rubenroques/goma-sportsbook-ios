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

    // MARK: - Client Overrides (set at app startup for multi-client support)

    /// Override operatorId for different clients (e.g., BetAtHome)
    public var clientOperatorId: String?

    /// Override WebSocket URL for different clients
    public var clientWebSocketURL: String?

    /// Override WebSocket origin for different clients
    public var clientWebSocketOrigin: String?

    /// Override WebSocket realm for different clients
    public var clientWebSocketRealm: String?

    /// Override WebSocket version for different clients
    public var clientWebSocketVersion: String?
    
    /// Initialize with environment
    init(environment: Environment) {
        self.environment = environment
    }
    
    // MARK: - Player API Configuration

    /// Base URL for Player API
    public var playerAPIBaseURL: String {
        switch environment {
        case .production:
            return "https://betsson.nwacdn.com"  // Updated from betsson-api.norway.everymatrix.com
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

    /// WebSocket URL for OddsMatrix WAMP protocol
    /// Uses clientWebSocketURL if set, otherwise falls back to environment defaults
    public var oddsMatrixWebSocketURL: String {
        if let override = clientWebSocketURL {
            return override
        }
        switch environment {
        case .production:
            return "wss://sportsapi.betssonem.com"
        case .staging, .development:
            return "wss://sportsapi-betsson-stage.everymatrix.com"
        }
    }

    /// WebSocket Version for OddsMatrix WAMP protocol
    /// Uses clientWebSocketVersion if set, otherwise falls back to environment defaults
    public var oddsMatrixWebSocketVersion: String {
        if let override = clientWebSocketVersion {
            return override
        }
        switch environment {
        case .production:
            return "v2"
        case .staging, .development:
            return "v2"
        }
    }

    /// WebSocket realm - uses clientWebSocketRealm if set, otherwise defaults to Betsson Cameroon
    public var oddsMatrixWebSocketRealm: String {
        return clientWebSocketRealm ?? "www.betsson.cm"
    }

    /// WebSocket origin for connection headers
    /// Uses clientWebSocketOrigin if set, otherwise falls back to environment defaults
    public var oddsMatrixWebSocketOrigin: String {
        if let override = clientWebSocketOrigin {
            return override
        }
        switch environment {
        case .production:
            return "https://www.betssonem.com/"
        case .staging, .development:
            return "https://sportsbook-stage.gomagaming.com"
        }
    }
    
    // MARK: - Casino API Configuration

    /// Base URL for Casino API (uses same backend as PlayerAPI)
    public var casinoAPIBaseURL: String {
        switch environment {
        case .production:
            return "https://betsson.nwacdn.com"  // Updated from betsson-api.norway.everymatrix.com
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
    
    // Casino datasource for v2 API endpoints
    public var casinoDataSource: String {
        switch environment {
        case .production:
            return "Lobby1"
        case .staging, .development:
            return "Lobby1"
        }
    }
    
    /// Base URL for Recsys API
    public var recsysAPIBaseURL: String {
        switch environment {
        case .production:
            return "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev"
        case .staging, .development:
            return "https://recsys-api-gateway-test-bshwjrve.ew.gateway.dev"
        }
    }
    
    public var recsysComboAPIBaseURL: String {
        switch environment {
        case .production:
            return "https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev"
        case .staging, .development:
            return "https://recsys-combo-api-gateway-test-bshwjrve.nw.gateway.dev"
        }
    }
    
    public var recsysAPIKey: String {
        return "AIzaSyBE-HDs6eqAkiNXtfN1sZGHRaGppjLfCho"

    }
    
    public var recsysComboAPIKey: String {
        return "AIzaSyAQog-N-vXGDNWldHPfM9qzR5vOMeJDspE"

    }

    // Virtual lobby (used in casino request to get virtual games)
    public var virtualsDataSource: String {
        switch environment {
        case .production:
            return "Virtual-Lobby"
        case .staging, .development:
            return "Virtual-Lobby"
        }
    }
    
    // MARK: - Shared Configuration

    /// Operator ID (some APIs call it Domain ID) for all APIs
    /// Uses clientOperatorId if set, otherwise falls back to environment defaults
    public var operatorId: String {
        if let override = clientOperatorId {
            return override
        }
        switch environment {
        case .production:
            return "4374"
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
    
    /// Default language for APIs (configurable, defaults to "en")
    public var defaultLanguage: String = "en"
    
    /// Default platform identifier
    public var defaultPlatform: String {
        return "iPhone"
    }

    public var defaultCasinoPlatform: String {
        return "iPhone"
    }

    // MARK: - Widget Cashier Configuration

    /// Base URL for Widget Cashier (hosted cashier page)
    public var widgetCashierBaseURL: String {
        switch environment {
        case .production:
            return "https://www.betssonem.com"
        case .staging, .development:
            return "https://sportsbook-stage.gomagaming.com"
        }
    }

    /// API endpoint URL passed to Widget Cashier (for its internal API calls)
    public var widgetCashierAPIEndpoint: String {
        switch environment {
        case .production:
            return "https://betsson.nwacdn.com"
        case .staging, .development:
            return "https://betsson-api.stage.norway.everymatrix.com"
        }
    }

}
