
import Foundation

public struct Configuration {

    public enum Environment {
        case production
        case staging
        case development
    }

    public enum ClientBusinessUnit {
        case betssonFrance
        case betssonCameroon
        case gomaDemo
    }
    
    /// Provider mapping for each domain
    private(set) var providerMapping: [Domain: Provider]
    
    /// Credentials for each provider
    private(set) var credentials: [Provider: ProviderCredentials]
    
    /// Environment configuration
    private(set) var environment: Environment
    
    /// Device UUID for tracking and analytics
    private(set) var deviceUUID: String?

    /// Client business unit identifier for CMS configuration
    private(set) var clientBusinessUnit: ClientBusinessUnit?

    /// Language code for API requests (e.g., "en", "fr")
    private(set) var language: String

    /// Operator ID override for EveryMatrix (nil = use default for environment)
    private(set) var operatorId: String?

    /// WebSocket configuration for EveryMatrix WAMP connection (nil = use defaults)
    private(set) var socketConfiguration: SocketConfiguration?

    /// WebSocket configuration for EveryMatrix WAMP connection
    public struct SocketConfiguration {
        public let url: String      // e.g., "wss://sportsapi.bet-at-home.de"
        public let origin: String   // e.g., "https://sports2.bet-at-home.de"
        public let realm: String    // e.g., "www.bet-at-home.de"
        public let version: String  // e.g., "v2"

        public init(url: String, origin: String, realm: String, version: String = "v2") {
            self.url = url
            self.origin = origin
            self.realm = realm
            self.version = version
        }
    }

    /// Credentials for a specific provider
    public struct ProviderCredentials {
        let name: String
        let secret: String
    }
    
    private init(
        environment: Environment,
        deviceUUID: String?,
        clientBusinessUnit: ClientBusinessUnit?,
        language: String,
        operatorId: String?,
        socketConfiguration: SocketConfiguration?,
        providerMapping: [Domain: Provider],
        credentials: [Provider: ProviderCredentials]
    ) {
        self.environment = environment
        self.deviceUUID = deviceUUID
        self.clientBusinessUnit = clientBusinessUnit
        self.language = language
        self.operatorId = operatorId
        self.socketConfiguration = socketConfiguration
        self.providerMapping = providerMapping
        self.credentials = credentials
    }

    
    /// Builder class for creating Configuration instances
    public class Builder {
        private var environment: Environment = .production
        private var deviceUUID: String?
        private var clientBusinessUnit: ClientBusinessUnit?
        private var language: String = "en"
        private var operatorId: String?
        private var socketConfiguration: SocketConfiguration?
        private var providerMapping: [Domain: Provider] = [:]
        private var credentials: [Provider: ProviderCredentials] = [:]

        public init() {}
        
        /// Sets the environment
        @discardableResult
        public func withEnvironment(_ environment: Environment) -> Builder {
            self.environment = environment
            return self
        }
        
        /// Sets the device UUID
        @discardableResult
        public func withDeviceUUID(_ uuid: String?) -> Builder {
            self.deviceUUID = uuid
            return self
        }

        /// Sets the client business unit for CMS configuration
        @discardableResult
        public func withClientBusinessUnit(_ businessUnit: ClientBusinessUnit?) -> Builder {
            self.clientBusinessUnit = businessUnit
            return self
        }

        /// Sets the language code for API requests
        @discardableResult
        public func withLanguage(_ language: String) -> Builder {
            self.language = language
            return self
        }

        /// Sets the operator ID for EveryMatrix APIs
        @discardableResult
        public func withOperatorId(_ operatorId: String) -> Builder {
            self.operatorId = operatorId
            return self
        }

        /// Sets the WebSocket configuration for EveryMatrix WAMP connection
        @discardableResult
        public func withSocketConfiguration(_ config: SocketConfiguration) -> Builder {
            self.socketConfiguration = config
            return self
        }

        /// Assigns a provider for a specific domain
        @discardableResult
        public func useProvider(_ provider: Provider, forDomain domain: Domain) -> Builder {
            guard provider.isSupported else {
                print("Warning: Attempting to use unsupported provider: \(provider)")
                return self
            }
            self.providerMapping[domain] = provider
            return self
        }
        
        /// Sets credentials for a specific provider
        @discardableResult
        public func withCredentials(_ provider: Provider, credential: ProviderCredentials) -> Builder {
            self.credentials[provider] = credential
            return self
        }

        /// Builds and validates the configuration
        public func build() throws -> Configuration {
            // Validate that all providers have credentials
            let providersNeedingCredentials = Set(providerMapping.values)
            let providersWithCredentials = Set(credentials.keys)
            
            let missingCredentials = providersNeedingCredentials.subtracting(providersWithCredentials)
            if !missingCredentials.isEmpty {
                throw ConfigurationError.missingCredentials(providers: Array(missingCredentials))
            }
            
            return Configuration(
                environment: environment,
                deviceUUID: deviceUUID,
                clientBusinessUnit: clientBusinessUnit,
                language: language,
                operatorId: operatorId,
                socketConfiguration: socketConfiguration,
                providerMapping: providerMapping,
                credentials: credentials
            )
        }
    }
    
    /// Legacy initializer for backward compatibility
    public init(environment: Environment = .production, deviceUUID: String? = nil) {
        self.environment = environment
        self.deviceUUID = deviceUUID
        self.clientBusinessUnit = nil
        self.language = "en"
        self.operatorId = nil
        self.socketConfiguration = nil
        self.providerMapping = [:]
        self.credentials = [:]
    }
}

/// Configuration-related errors
public enum ConfigurationError: Error {
    case missingCredentials(providers: [Provider])
    
    public var localizedDescription: String {
        switch self {
        case .missingCredentials(let providers):
            return "Missing credentials for providers: \(providers.map { $0.displayName }.joined(separator: ", "))"
        }
    }
}
