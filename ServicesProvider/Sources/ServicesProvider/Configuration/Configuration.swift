//
//  File.swift
//
//
//  Created by Ruben Roques on 27/09/2023.
//

import Foundation

/// Represents available features that can be enabled or disabled
public enum Feature: String, CaseIterable {
    /// Mix and match betting feature
    case mixMatch
    
    // Add more features as needed
}

public struct Configuration {
    
    public enum Environment {
        case production
        case staging
        case development
    }
    
    /// Provider mapping for each domain
    private(set) var providerMapping: [Domain: Provider]
    
    /// Credentials for each provider
    private(set) var credentials: [Provider: ProviderCredentials]
    
    /// Environment configuration
    private(set) var environment: Environment
    
    /// Device UUID for tracking and analytics
    private(set) var deviceUUID: String?
    
    /// Enabled features
    private(set) var enabledFeatures: Set<Feature>
    
    /// Credentials for a specific provider
    public struct ProviderCredentials {
        let name: String
        let secret: String
    }
    
    private init(
        environment: Environment,
        deviceUUID: String?,
        providerMapping: [Domain: Provider],
        credentials: [Provider: ProviderCredentials],
        enabledFeatures: Set<Feature>
    ) {
        self.environment = environment
        self.deviceUUID = deviceUUID
        self.providerMapping = providerMapping
        self.credentials = credentials
        self.enabledFeatures = enabledFeatures
    }
    
    /// Check if a feature is enabled
    public func isFeatureEnabled(_ feature: Feature) -> Bool {
        return enabledFeatures.contains(feature)
    }
    
    /// Builder class for creating Configuration instances
    public class Builder {
        private var environment: Environment = .production
        private var deviceUUID: String?
        private var providerMapping: [Domain: Provider] = [:]
        private var credentials: [Provider: ProviderCredentials] = [:]
        private var enabledFeatures: Set<Feature> = []
        
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
        
        /// Enables a specific feature
        @discardableResult
        public func enableFeature(_ feature: Feature) -> Builder {
            self.enabledFeatures.insert(feature)
            return self
        }
        
        /// Enables multiple features
        @discardableResult
        public func enableFeatures(_ features: [Feature]) -> Builder {
            for feature in features {
                self.enabledFeatures.insert(feature)
            }
            return self
        }
        
        /// Disables a specific feature
        @discardableResult
        public func disableFeature(_ feature: Feature) -> Builder {
            self.enabledFeatures.remove(feature)
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
                providerMapping: providerMapping,
                credentials: credentials,
                enabledFeatures: enabledFeatures
            )
        }
    }
    
    /// Legacy initializer for backward compatibility
    public init(environment: Environment = .production, deviceUUID: String? = nil) {
        self.environment = environment
        self.deviceUUID = deviceUUID
        self.providerMapping = [:]
        self.credentials = [:]
        self.enabledFeatures = []
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
