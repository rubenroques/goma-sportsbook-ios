//
//  ServiceProviderModelMapper+Casino.swift
//  BetssonCameroonApp
//
//  Created by Claude on 01/08/2025.
//

import Foundation
import ServicesProvider
import GomaUI

extension ServiceProviderModelMapper {
    
    // MARK: - CasinoGame Mapping
    
    /// Convert ServicesProvider CasinoGame to GomaUI CasinoGameCardData
    static func casinoGameCardData(fromCasinoGame casinoGame: CasinoGame) -> CasinoGameCardData {
        return CasinoGameCardData(
            id: casinoGame.id,
            name: casinoGame.name,
            gameURL: casinoGame.launchUrl,
            imageURL: bestImageURL(from: casinoGame),
            rating: bestRating(from: casinoGame),
            provider: casinoGame.vendor.displayName,
            minStake: "-" // As specified: set to "-" when not available
        )
    }
    
    // MARK: - CasinoCategory Mapping
    
    /// Convert ServicesProvider CasinoCategory to GomaUI CasinoCategorySectionData
    static func casinoCategorySectionData(
        fromCasinoCategory casinoCategory: CasinoCategory,
        games: [CasinoGameCardData]
    ) -> CasinoCategorySectionData {
        return CasinoCategorySectionData(
            id: casinoCategory.id,
            categoryTitle: casinoCategory.name,
            categoryButtonText: "All \(casinoCategory.gamesTotal)",
            games: games
        )
    }
    
    // MARK: - "See More" Card Creation
    
    /// Create a special "See More" card for categories with additional games
    static func seeMoreCard(
        categoryId: String,
        remainingGamesCount: Int
    ) -> CasinoGameCardData {
        return CasinoGameCardData(
            id: "\(categoryId)-see-more",
            name: "See More",
            gameURL: "", // Empty - this will trigger navigation instead of game launch
            imageURL: nil, // Use default "see more" placeholder
            rating: 0.0,
            provider: "See \(remainingGamesCount) more games",
            minStake: ""
        )
    }
    
    // MARK: - Private Helper Methods
    
    /// Get best available image URL with priority: thumbnail > backgroundImageUrl > icons["88"]
    private static func bestImageURL(from casinoGame: CasinoGame) -> String? {
        if !casinoGame.thumbnail.isEmpty {
            return "https:" + casinoGame.thumbnail
        }
        if !casinoGame.backgroundImageUrl.isEmpty {
            return "https:" + casinoGame.backgroundImageUrl
        }
        return nil
    }
    
    /// Get best available rating using popularity field or default to 0
    private static func bestRating(from casinoGame: CasinoGame) -> Double {
        return casinoGame.popularity ?? 0.0
    }
}
