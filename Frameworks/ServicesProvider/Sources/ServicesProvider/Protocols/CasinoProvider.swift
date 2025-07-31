//
//  CasinoProvider.swift
//  ServicesProvider
//
//  Created by Claude on 29/01/2025.
//

import Foundation
import Combine

/// Protocol for providing casino functionality including game categories, games, and launch capabilities
public protocol CasinoProvider: Connector {
    
    // MARK: - Core API Methods
    
    /// Retrieve all available casino game categories
    /// - Parameters:
    ///   - language: Language code (e.g., "en", "fr") - optional, provider will use default
    ///   - platform: Platform identifier (e.g., "iOS", "PC") - optional, provider will use default
    /// - Returns: Publisher with array of casino categories
    func getCasinoCategories(language: String?, platform: String?) -> AnyPublisher<[CasinoCategory], ServiceProviderError>
    
    /// Retrieve games for a specific category with pagination
    /// - Parameters:
    ///   - categoryId: Category identifier (e.g., "VIDEOSLOTS")
    ///   - language: Language code - optional, provider will use default
    ///   - platform: Platform identifier - optional, provider will use default
    ///   - pagination: Pagination parameters
    /// - Returns: Publisher with paginated games response
    func getGamesByCategory(
        categoryId: String,
        language: String?,
        platform: String?,
        pagination: CasinoPaginationParams
    ) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError>
    
    /// Retrieve detailed information for a specific game
    /// - Parameters:
    ///   - gameId: Game identifier
    ///   - language: Language code - optional, provider will use default
    ///   - platform: Platform identifier - optional, provider will use default
    /// - Returns: Publisher with game details (nil if game not found)
    func getGameDetails(
        gameId: String,
        language: String?,
        platform: String?
    ) -> AnyPublisher<CasinoGame?, ServiceProviderError>
    
    /// Retrieve recently played games for a user (requires authentication)
    /// - Parameters:
    ///   - playerId: Player identifier
    ///   - language: Language code - optional, provider will use default
    ///   - platform: Platform identifier - optional, provider will use default
    ///   - pagination: Pagination parameters
    /// - Returns: Publisher with paginated recently played games
    func getRecentlyPlayedGames(
        playerId: String,
        language: String?,
        platform: String?,
        pagination: CasinoPaginationParams
    ) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError>
    
    // MARK: - Game Launch Methods
    
    /// Build game launch URL with appropriate parameters for the specified mode
    /// - Parameters:
    ///   - game: Casino game to launch
    ///   - mode: Game launch mode (guest, logged in, real money)
    ///   - sessionId: User session ID (required for authenticated modes)
    ///   - language: Language code for game localization
    /// - Returns: Complete launch URL or nil if cannot be constructed
    func buildGameLaunchUrl(
        for game: CasinoGame,
        mode: CasinoGameMode,
        sessionId: String?,
        language: String?
    ) -> String?
    
    /// Check if a game supports the specified launch mode
    /// - Parameters:
    ///   - game: Casino game to check
    ///   - mode: Game launch mode to verify
    /// - Returns: True if the mode is supported
    func supportsGameMode(game: CasinoGame, mode: CasinoGameMode) -> Bool
    
    // MARK: - Helper Methods
    
    /// Filter categories to only include those with available games
    /// - Parameter categories: Array of categories to filter
    /// - Returns: Filtered array with only categories that have games
    func filterCategoriesWithGames(_ categories: [CasinoCategory]) -> [CasinoCategory]
}


