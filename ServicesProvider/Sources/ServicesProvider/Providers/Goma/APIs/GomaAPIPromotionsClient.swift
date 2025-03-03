//
//  GomaAPIPromotionsClient.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

class GomaAPIPromotionsCache {
    private let queue = DispatchQueue(label: "com.goma.promotions.cache", attributes: .concurrent)
    private let cacheExpirationInterval: TimeInterval

    private struct CacheEntry<T> {
        let value: T
        let timestamp: Date
        let expirationInterval: TimeInterval

        var isExpired: Bool {
            return Date().timeIntervalSince(timestamp) > expirationInterval
        }
    }

    private var homeTemplateCache: CacheEntry<GomaModels.HomeTemplate>?
    private var initialDumpCache: CacheEntry<GomaModels.InitialDump>?

    init(expirationInterval: TimeInterval = 5 * 60) {
        self.cacheExpirationInterval = expirationInterval
    }

    // MARK: - Public Methods

    func cacheInitialDump(_ dump: GomaModels.InitialDump) {
        queue.async(flags: .barrier) {
            self.initialDumpCache = CacheEntry(value: dump, timestamp: Date(), expirationInterval: self.cacheExpirationInterval)
            // Also cache the home template since it's part of the initial dump
            self.homeTemplateCache = CacheEntry(value: dump.homeTemplate, timestamp: Date(), expirationInterval: self.cacheExpirationInterval)
        }
    }

    func getCachedInitialDump() -> GomaModels.InitialDump? {
        var result: GomaModels.InitialDump?
        queue.sync {
            guard let cache = initialDumpCache, !cache.isExpired else { return }
            result = cache.value
        }
        return result
    }

    func getCachedHomeTemplate() -> GomaModels.HomeTemplate? {
        var result: GomaModels.HomeTemplate?
        queue.sync {
            guard let cache = homeTemplateCache, !cache.isExpired else { return }
            result = cache.value
        }
        return result
    }

    func clearCache() {
        queue.async(flags: .barrier) {
            self.homeTemplateCache = nil
            self.initialDumpCache = nil
        }
    }
}

/// Client for interacting with the Goma Promotions API
class GomaAPIPromotionsClient {

    // MARK: - Properties

    /// The connector for handling authenticated requests
    private let connector: GomaConnector
    private let cache: GomaAPIPromotionsCache
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    /// Initialize the client with a connector for request handling and cache
    /// - Parameters:
    ///   - connector: The GomaConnector to use for authenticated requests
    ///   - cache: The cache instance to use for storing promotional content
    init(connector: GomaConnector, cache: GomaAPIPromotionsCache) {
        self.connector = connector
        self.cache = cache
    }

    func clearCache() {
        self.cache.clearCache()
    }

    /// Prefetches and caches the home content for faster access
    /// - Returns: A publisher that emits the initial dump data (either from cache or fresh fetch)
    func preFetchHomeContent() -> AnyPublisher<GomaModels.InitialDump, ServiceProviderError> {
        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump() {
            return Just(cachedData)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // Call initialDump and store the response, it should contain all the data required to build the home template sections

        let endpoint = GomaAPIPromotionsSchema.initialDump
        let publisher = self.connector.request(endpoint)
            .handleEvents(receiveOutput: { [weak self] (initialDump: GomaModels.InitialDump) in
                // Store the initialDump response in the cache
                self?.cache.cacheInitialDump(initialDump)
            })
            .eraseToAnyPublisher()

        return publisher
    }

    /// For testing purposes - get the URLRequest for an endpoint without executing it
    /// - Parameter endpoint: The endpoint to create a request for
    /// - Returns: The URLRequest that would be used for the endpoint
    func requestFor(_ endpoint: Endpoint) -> URLRequest? {
        return endpoint.request()
    }
    
    func requestPublisher<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        return self.connector.request(endpoint)
    }

    // MARK: - API Methods

    /// Get the home template configuration
    /// - Returns: A publisher with the decoded response or error
    func homeTemplate() -> AnyPublisher<GomaModels.HomeTemplate, ServiceProviderError> {
        
        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump() {
            return Just(cachedData.homeTemplate)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
        
        let endpoint = GomaAPIPromotionsSchema.homeTemplate
        return self.connector.request(endpoint)
    }

    /// Get alert banner
    /// - Returns: A publisher with the decoded response or error
    func alertBanner() -> AnyPublisher<GomaModels.AlertBanner, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.alertBanner
        return self.connector.request(endpoint)
    }

    /// Get promotional banners
    /// - Returns: A publisher with the decoded response or error
    func banners() -> AnyPublisher<GomaModels.Banners, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.banners
        return self.connector.request(endpoint)
    }

    /// Get carousel events (formerly sport banners)
    /// - Returns: A publisher with the decoded response or error
    func carouselEvents() -> AnyPublisher<GomaModels.CarouselEvents, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.sportBanners
        return self.connector.request(endpoint)
    }

    /// Get boosted odds banners
    /// - Returns: A publisher with the decoded response or error
    func boostedOddsBanners() -> AnyPublisher<GomaModels.BoostedOddsBanners, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.boostedOddsBanners
        return self.connector.request(endpoint)
    }

    /// Get hero cards
    /// - Returns: A publisher with the decoded response or error
    func heroCards() -> AnyPublisher<GomaModels.HeroCardPointers, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.heroCards
        return self.connector.request(endpoint)
    }

    /// Get promotional stories
    /// - Returns: A publisher with the decoded response or error
    func stories() -> AnyPublisher<GomaModels.Stories, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.stories
        return self.connector.request(endpoint)
    }

    /// Get news articles
    /// - Parameters:
    ///   - pageIndex: The page index for pagination
    ///   - pageSize: The page size for pagination
    /// - Returns: A publisher with the decoded response or error
    func newsItems(pageIndex: Int = 0, pageSize: Int = 10) -> AnyPublisher<GomaModels.NewsItems, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.news(pageIndex: pageIndex, pageSize: pageSize)
        return self.connector.request(endpoint)
    }

    /// Get pro betting choices
    /// - Returns: A publisher with the decoded response or error
    func proChoices() -> AnyPublisher<GomaModels.ProChoiceItems, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.proChoices
        return self.connector.request(endpoint)
    }

    /// Get initial data dump including sports, competitions, and events
    /// - Returns: A publisher with the decoded response or error
    func initialDump() -> AnyPublisher<GomaModels.InitialDump, ServiceProviderError> {
        let endpoint = GomaAPIPromotionsSchema.initialDump
        return self.connector.request(endpoint)
    }

}
