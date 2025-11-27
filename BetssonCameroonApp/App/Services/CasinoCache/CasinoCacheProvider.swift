//
//  CasinoCacheProvider.swift
//  BetssonCameroonApp
//
//  Created by Claude Code on 25/11/2025.
//

import Foundation
import Combine
import ServicesProvider

/// Decorator that wraps CasinoProvider with caching capabilities
/// Uses 3-tier fallback: Fresh cache → Stale cache → Bundled data → API call
final class CasinoCacheProvider {

    // MARK: - Properties

    /// The underlying services provider client
    private let servicesProvider: ServicesProvider.Client

    /// Cache store for persisting casino data
    private let cacheStore: CasinoCacheStore

    /// Configuration for cache behavior
    private let configuration: CasinoCacheConfiguration

    /// Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Silent Update Publishers

    /// Publisher for background category updates
    private let categoriesUpdateSubject = PassthroughSubject<[CasinoCategory], Never>()

    /// Publisher for background game list updates (with category context)
    private let gamesUpdateSubject = PassthroughSubject<(categoryId: String, offset: Int, response: CasinoGamesResponse), Never>()

    /// Public publisher for ViewModels to subscribe to category updates
    var categoriesUpdatePublisher: AnyPublisher<[CasinoCategory], Never> {
        categoriesUpdateSubject.eraseToAnyPublisher()
    }

    /// Public publisher for ViewModels to subscribe to game list updates
    var gamesUpdatePublisher: AnyPublisher<(categoryId: String, offset: Int, response: CasinoGamesResponse), Never> {
        gamesUpdateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(
        servicesProvider: ServicesProvider.Client,
        cacheStore: CasinoCacheStore,
        configuration: CasinoCacheConfiguration
    ) {
        self.servicesProvider = servicesProvider
        self.cacheStore = cacheStore
        self.configuration = configuration
    }

    // MARK: - Connector Protocol

    func connect() {
        servicesProvider.connect()
    }

    func disconnect() {
        servicesProvider.disconnect()
    }

    // MARK: - CasinoProvider Protocol - Cached Methods

    /// Get casino categories with caching support
    /// Returns cached data immediately if available, triggers background refresh for stale data
    func getCasinoCategories(
        language: String?,
        platform: String?,
        lobbyType: ServicesProvider.CasinoLobbyType?
    ) -> AnyPublisher<[CasinoCategory], ServiceProviderError> {

        let lobbyTypeKey = lobbyType?.displayName ?? "casino"
        let cacheResult = cacheStore.getCachedCategories(lobbyType: lobbyTypeKey)

        switch cacheResult {
        case .fresh(let categories):
            // Cache is fresh, return immediately without network call
            return Just(categories)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()

        case .stale(let categories), .bundled(let categories):
            // Cache exists but stale, or using bundled data
            // Return cached data immediately AND trigger background refresh
            triggerBackgroundCategoriesRefresh(language: language, platform: platform, lobbyType: lobbyType)

            return Just(categories)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()

        case .miss:
            // No cache available, fetch from network
            return fetchAndCacheCategories(language: language, platform: platform, lobbyType: lobbyType)
        }
    }

    /// Get games by category with caching support
    /// Returns cached data immediately if available, triggers background refresh for stale data
    func getGamesByCategory(
        categoryId: String,
        language: String?,
        platform: String?,
        lobbyType: ServicesProvider.CasinoLobbyType?,
        pagination: CasinoPaginationParams
    ) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {

        let lobbyTypeKey = lobbyType?.displayName ?? "casino"
        let cacheResult = cacheStore.getCachedGameList(categoryId: categoryId, offset: pagination.offset, lobbyType: lobbyTypeKey)

        switch cacheResult {
        case .fresh(let gamesResponse):
            // Cache is fresh, return immediately without network call
            return Just(gamesResponse)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()

        case .stale(let gamesResponse), .bundled(let gamesResponse):
            // Cache exists but stale, or using bundled data
            // Return cached data immediately AND trigger background refresh
            triggerBackgroundGamesRefresh(
                categoryId: categoryId,
                language: language,
                platform: platform,
                lobbyType: lobbyType,
                pagination: pagination
            )

            return Just(gamesResponse)
                .setFailureType(to: ServiceProviderError.self)
                .eraseToAnyPublisher()

        case .miss:
            // No cache available, fetch from network
            return fetchAndCacheGameList(
                categoryId: categoryId,
                language: language,
                platform: platform,
                lobbyType: lobbyType,
                pagination: pagination
            )
        }
    }

    // MARK: - CasinoProvider Protocol - Non-Cached Methods (Passthrough)

    /// Get game details - NOT cached (changes frequently with promotions)
    func getGameDetails(
        gameId: String,
        language: String?,
        platform: String?
    ) -> AnyPublisher<CasinoGame, ServiceProviderError> {
        return servicesProvider.getGameDetails(gameId: gameId, language: language, platform: platform)
    }

    /// Search games - NOT cached (query-dependent)
    func searchGames(
        language: String?,
        platform: String?,
        name: String
    ) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        return servicesProvider.searchGames(language: language, platform: platform, name: name)
    }

    /// Get recommended games - NOT cached (personalized, will need per-user cache in future)
    func getRecommendedGames(
        language: String?,
        platform: String?
    ) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        return servicesProvider.getRecommendedGames(language: language, platform: platform)
    }

    /// Build game launch URL - Passthrough (no caching needed)
    func buildGameLaunchUrl(
        for game: CasinoGame,
        mode: CasinoGameMode,
        language: String?
    ) -> String? {
        return servicesProvider.buildCasinoGameLaunchUrl(for: game, mode: mode, language: language)
    }

    // MARK: - Private Methods - Fetch and Cache

    /// Fetch categories from API and cache the result
    private func fetchAndCacheCategories(
        language: String?,
        platform: String?,
        lobbyType: ServicesProvider.CasinoLobbyType?
    ) -> AnyPublisher<[CasinoCategory], ServiceProviderError> {

        let lobbyTypeKey = lobbyType?.displayName ?? "casino"

        return servicesProvider.getCasinoCategories(language: language, platform: platform, lobbyType: lobbyType)
            .handleEvents(
                receiveOutput: { [weak self] categories in
                    // Save to cache when API returns successfully
                    self?.cacheStore.saveCachedCategories(categories, lobbyType: lobbyTypeKey)
                }
            )
            .eraseToAnyPublisher()
    }

    /// Fetch game list from API and cache the result
    private func fetchAndCacheGameList(
        categoryId: String,
        language: String?,
        platform: String?,
        lobbyType: ServicesProvider.CasinoLobbyType?,
        pagination: CasinoPaginationParams
    ) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {

        let lobbyTypeKey = lobbyType?.displayName ?? "casino"

        return servicesProvider.getGamesByCategory(
            categoryId: categoryId,
            language: language,
            platform: platform,
            lobbyType: lobbyType,
            pagination: pagination
        )
        .handleEvents(
            receiveOutput: { [weak self] gamesResponse in
                // Save to cache when API returns successfully
                self?.cacheStore.saveCachedGameList(gamesResponse, categoryId: categoryId, offset: pagination.offset, lobbyType: lobbyTypeKey)
            }
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Private Methods - Background Refresh

    /// Trigger background refresh for categories (non-blocking)
    private func triggerBackgroundCategoriesRefresh(
        language: String?,
        platform: String?,
        lobbyType: ServicesProvider.CasinoLobbyType?
    ) {
        fetchAndCacheCategories(language: language, platform: platform, lobbyType: lobbyType)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("⚠️ CasinoCacheProvider: Background categories refresh failed: \(error)")
                        // Don't throw - background refresh failure is non-fatal
                    }
                },
                receiveValue: { [weak self] categories in
                    // Publish silent update for UI to refresh
                    self?.categoriesUpdateSubject.send(categories)
                }
            )
            .store(in: &cancellables)
    }

    /// Trigger background refresh for game list (non-blocking)
    private func triggerBackgroundGamesRefresh(
        categoryId: String,
        language: String?,
        platform: String?,
        lobbyType: ServicesProvider.CasinoLobbyType?,
        pagination: CasinoPaginationParams
    ) {
        fetchAndCacheGameList(
            categoryId: categoryId,
            language: language,
            platform: platform,
            lobbyType: lobbyType,
            pagination: pagination
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("⚠️ CasinoCacheProvider: Background games refresh failed for \(categoryId): \(error)")
                    // Don't throw - background refresh failure is non-fatal
                }
            },
            receiveValue: { [weak self] gamesResponse in
                // Publish silent update for UI to refresh
                self?.gamesUpdateSubject.send((categoryId: categoryId, offset: pagination.offset, response: gamesResponse))
            }
        )
        .store(in: &cancellables)
    }

    // MARK: - Public Methods - Cache Management

    /// Clear all cached data
    func clearCache() {
        cacheStore.clearCache()
    }
}
