//
//  GomaHomeContentAPIClient.swift
//
//
//  Created on: May 15, 2024
//

import Foundation
import Combine

/// Client for interacting with the Goma Promotions API
class GomaHomeContentAPIClient {

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

    /// Prefetches and caches the home content for faster access
    /// - Returns: A publisher that emits the initial dump data (either from cache or fresh fetch)
    func preFetchHomeContent() -> AnyPublisher<GomaModels.InitialDump, ServiceProviderError> {
        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump() {
            return Just(cachedData)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        let endpoint = GomaHomeContentAPISchema.initialDump
        let publisher = self.connector.request(endpoint)
            .handleEvents(receiveOutput: { [weak self] (initialDump: GomaModels.InitialDump) in
                // Store the initialDump response in the cache
                self?.cache.cacheInitialDump(initialDump)
            })
            .eraseToAnyPublisher()
        return publisher
    }

    /// Get the home template configuration
    /// - Returns: A publisher with the decoded response or error
    func homeTemplate() -> AnyPublisher<GomaModels.HomeTemplate, ServiceProviderError> {

        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump() {
            return Just(cachedData.homeTemplate)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        let endpoint = GomaHomeContentAPISchema.homeTemplate
        return self.connector.request(endpoint)
    }

    /// Get alert banner
    /// - Returns: A publisher with the decoded response or error
    func alertBanner() -> AnyPublisher<GomaModels.AlertBanner, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.alertBanner
        if let cachedData = self.cache.getCachedInitialDump(), let alertBanner = cachedData.getAlertBanner() {
            return Just(alertBanner)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
        
        return self.connector.request(endpoint)
    }

    /// Get promotional banners
    /// - Returns: A publisher with the decoded response or error
    func banners() -> AnyPublisher<GomaModels.Banners, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.banners
        if let cachedData = self.cache.getCachedInitialDump(), let banners = cachedData.getBanners() {
            return Just(banners)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
        
        return self.connector.request(endpoint)
    }

    /// Get carousel events (formerly sport banners)
    /// - Returns: A publisher with the decoded response or error
    func carouselEventPointers() -> AnyPublisher<GomaModels.CarouselEventPointers, ServiceProviderError> {
        // Check cache first (keep existing behavior)
        if let cachedData = self.cache.getCachedInitialDump(), let carouselEvents = cachedData.homeWidgetPointers?.carouselEventPointers {
            return Just(carouselEvents)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        // TEMPORARY: Hardcoded fallback data while CMS is not returning events
        let hardcodedPointers: GomaModels.CarouselEventPointers = [
            GomaModels.CarouselEventPointer(
                id: 1,
                eventId: "281662226139582464",
                eventMarketId: "1",
                ctaUrl: nil,
                imageUrl: "https://placehold.co/600x300/orange/white?text=Match+1"
            ),
            GomaModels.CarouselEventPointer(
                id: 2,
                eventId: "281274207591075840",
                eventMarketId: "1",
                ctaUrl: nil,
                imageUrl: "https://placehold.co/600x300/blue/white?text=Match+2"
            )
        ]

        return Just(hardcodedPointers)
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()

        // Original code (commented out until CMS returns data):
        // let endpoint = GomaHomeContentAPISchema.sportBanners
        // return self.connector.request(endpoint)
    }
    
    func carouselEvents() -> AnyPublisher<GomaModels.HeroCardEvents, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.sportBanners
        return self.connector.request(endpoint)
    }

    /// Get casino carousel banners
    /// - Returns: A publisher with the decoded response or error
    func casinoCarouselPointers() -> AnyPublisher<GomaModels.CasinoCarouselPointers, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.casinoCarouselBanners
        return self.connector.request(endpoint)
    }

    /// Get boosted odds banners
    /// - Returns: A publisher with the decoded response or error
    func boostedOddsPointers() -> AnyPublisher<GomaModels.BoostedOddsPointers, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.boostedOdds
        return self.connector.request(endpoint)
    }
    
    func boostedOddsEvents() -> AnyPublisher<GomaModels.BoostedOddsEvents, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.boostedOdds
        return self.connector.request(endpoint)
    }
    
    /// Get Top Image events
    ///
    func topImageCardPointers() -> AnyPublisher<GomaModels.TopImageCardPointers, ServiceProviderError> {
        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump(), let topImageCardPointers = cachedData.homeWidgetPointers?.topImageCardPointers {
            return Just(topImageCardPointers)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        let endpoint = GomaHomeContentAPISchema.topImageCards
        return self.connector.request(endpoint)
    }
    
    func topImageEvents() -> AnyPublisher<GomaModels.Events, ServiceProviderError> {
        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump(), let topImageEvents = cachedData.homeWidgetContent?.topImageEvents {
            return Just(topImageEvents)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        let endpoint = GomaHomeContentAPISchema.topImageCards
        return self.connector.request(endpoint)
    }

    /// Get hero cards
    /// - Returns: A publisher with the decoded response or error
    func heroCardPointers() -> AnyPublisher<GomaModels.HeroCardPointers, ServiceProviderError> {
        // First check if we have a valid cached version
        if let cachedData = self.cache.getCachedInitialDump(), let heroCardPointers = cachedData.homeWidgetPointers?.heroCardPointers {
            return Just(heroCardPointers)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }

        let endpoint = GomaHomeContentAPISchema.heroCards
        return self.connector.request(endpoint)
    }
    
    func heroCardEvents() -> AnyPublisher<GomaModels.HeroCardEvents, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.heroCards
        return self.connector.request(endpoint)
    }

    /// Get promotional stories
    /// - Returns: A publisher with the decoded response or error
    func stories() -> AnyPublisher<GomaModels.Stories, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.stories
        return self.connector.request(endpoint)
    }

    /// Get news articles
    /// - Parameters:
    ///   - pageIndex: The page index for pagination
    ///   - pageSize: The page size for pagination
    /// - Returns: A publisher with the decoded response or error
    func newsItems(pageIndex: Int = 0, pageSize: Int = 10) -> AnyPublisher<GomaModels.NewsItems, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.news(pageIndex: pageIndex, pageSize: pageSize)
        return self.connector.request(endpoint)
    }

    /// Get pro betting choices
    /// - Returns: A publisher with the decoded response or error
    func proChoicePointers() -> AnyPublisher<GomaModels.ProChoiceCardPointers, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.proChoices
        if let cachedData = self.cache.getCachedInitialDump(), let proChoiceCardPointers = cachedData.homeWidgetPointers?.proChoiceCardPointers {
            return Just(proChoiceCardPointers)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()
        }
        
        return self.connector.request(endpoint)
    }
    
    /// Get pro betting choices
    /// - Returns: A publisher with the decoded response or error
    func proChoices() -> AnyPublisher<GomaModels.Events, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.proChoices
        return self.connector.request(endpoint)
    }

    /// Get top competitions
    /// - Returns: A publisher with the decoded response or error
    func topCompetitionPointers() -> AnyPublisher<GomaModels.TopCompetitionPointers, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.topCompetitions
        return self.connector.request(endpoint)
    }
    
    /// Get top competitions
    /// - Returns: A publisher with the decoded response or error
    func topCompetitions() -> AnyPublisher<GomaModels.Competitions, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.topCompetitions
        return self.connector.request(endpoint)
    }

    /// Get initial data dump including sports, competitions, and events
    /// - Returns: A publisher with the decoded response or error
    func initialDump() -> AnyPublisher<GomaModels.InitialDump, ServiceProviderError> {
        let endpoint = GomaHomeContentAPISchema.initialDump
        return self.connector.request(endpoint)
    }

}


