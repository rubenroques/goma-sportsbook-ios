//
//  File.swift
//
//
//  Created by Ruben Roques on 27/09/2023.
//

import Foundation

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

    /// Credentials for a specific provider
    public struct ProviderCredentials {
        let name: String
        let secret: String
    }
    
    private init(
        environment: Environment,
        deviceUUID: String?,
        providerMapping: [Domain: Provider],
        credentials: [Provider: ProviderCredentials]
    ) {
        self.environment = environment
        self.deviceUUID = deviceUUID
        self.providerMapping = providerMapping
        self.credentials = credentials
    }

    
    /// Builder class for creating Configuration instances
    public class Builder {
        private var environment: Environment = .production
        private var deviceUUID: String?
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
                providerMapping: providerMapping,
                credentials: credentials
            )
        }
    }
    
    /// Legacy initializer for backward compatibility
    public init(environment: Environment = .production, deviceUUID: String? = nil) {
        self.environment = environment
        self.deviceUUID = deviceUUID
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
