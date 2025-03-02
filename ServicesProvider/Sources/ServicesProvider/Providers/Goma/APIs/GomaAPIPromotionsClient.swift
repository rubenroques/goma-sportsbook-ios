//
//  GomaAPIPromotionsClient.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

/// Client for interacting with the Goma Promotions API
class GomaAPIPromotionsClient {

    // MARK: - Properties
    
    /// The connector for handling authenticated requests
    private let connector: GomaConnector
    
    // MARK: - Initialization
    
    /// Initialize the client with a connector for request handling
    /// - Parameter connector: The GomaConnector to use for authenticated requests
    init(connector: GomaConnector) {
        self.connector = connector
    }
    
    // MARK: - Helper Methods
    
    /// For testing purposes - get the URLRequest for an endpoint without executing it
    /// - Parameter endpoint: The endpoint to create a request for
    /// - Returns: The URLRequest that would be used for the endpoint
    func requestFor(_ endpoint: GomaAPIPromotionsSchema) -> URLRequest? {
        return endpoint.request()
    }
    
    // MARK: - API Methods
    
    /// Get the home template configuration
    /// - Returns: A publisher with the decoded response or error
    func homeTemplate<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.homeTemplate
        return self.connector.request(endpoint)
    }
    
    /// Get all promotions
    /// - Returns: A publisher with the decoded response or error
    func allPromotions<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.allPromotions
        return self.connector.request(endpoint)
    }
    
    /// Get alert banner
    /// - Returns: A publisher with the decoded response or error
    func alertBanner<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.alertBanner
        return self.connector.request(endpoint)
    }
    
    /// Get promotional banners
    /// - Returns: A publisher with the decoded response or error
    func banners<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.banners
        return self.connector.request(endpoint)
    }
    
    /// Get carousel events (formerly sport banners)
    /// - Returns: A publisher with the decoded response or error
    func carouselEvents<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.sportBanners
        return self.connector.request(endpoint)
    }
    
    /// Get boosted odds banners
    /// - Returns: A publisher with the decoded response or error
    func boostedOddsBanners<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.boostedOddsBanners
        return self.connector.request(endpoint)
    }
    
    /// Get hero cards
    /// - Returns: A publisher with the decoded response or error
    func heroCards<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.heroCards
        return self.connector.request(endpoint)
    }
    
    /// Get promotional stories
    /// - Returns: A publisher with the decoded response or error
    func stories<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.stories
        return self.connector.request(endpoint)
    }
    
    /// Get news articles
    /// - Parameters:
    ///   - pageIndex: The page index for pagination
    ///   - pageSize: The page size for pagination
    /// - Returns: A publisher with the decoded response or error
    func news<T: Codable>(pageIndex: Int = 0, pageSize: Int = 10) -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.news(pageIndex: pageIndex, pageSize: pageSize)
        return self.connector.request(endpoint)
    }
    
    /// Get pro betting choices
    /// - Returns: A publisher with the decoded response or error
    func proChoices<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.proChoices
        return self.connector.request(endpoint)
    }
    
    /// Get initial data dump including sports, competitions, and events
    /// - Returns: A publisher with the decoded response or error
    func initialDump<T: Codable>() -> AnyPublisher<T, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.initialDump
        return self.connector.request(endpoint)
    }
} 
