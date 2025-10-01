
import Foundation

extension EveryMatrixModelMapper {
    
    // MARK: - Casino Category Mapping
    
    /// Maps EveryMatrix casino categories response to public model
    static func casinoCategories(from dto: EveryMatrix.CasinoCategoriesResponseDTO) -> CasinoCategoriesResponse {
        let categories = dto.items.compactMap { failableCategoryDTO in
            failableCategoryDTO.content.map { categoryDTO in
                casinoCategory(from: categoryDTO)
            }
        }
        
        let pagination = dto.pages.map { pagesDTO in
            casinoPaginationInfo(from: pagesDTO)
        }
        
        return CasinoCategoriesResponse(
            count: categories.count,
            total: dto.total,
            items: categories,
            pagination: pagination
        )
    }
    
    /// Maps EveryMatrix casino category DTO to public model
    static func casinoCategory(from dto: EveryMatrix.CasinoCategoryDTO) -> CasinoCategory {
        return CasinoCategory(
            id: dto.id,
            name: dto.name,
            href: "", // v2 API doesn't provide href anymore
            gamesTotal: dto.games.total
        )
    }
    
    // MARK: - Casino Game Mapping
    
    /// Maps EveryMatrix casino games response to public model
    static func casinoGames(from dto: EveryMatrix.CasinoGamesResponseDTO) -> CasinoGamesResponse {
        let games = dto.items.compactMap { failableGameDTO in
            failableGameDTO.content.map { gameDTO in
                casinoGame(from: gameDTO)
            }
        }
        
        let pagination = dto.pages.map { pagesDTO in
            casinoPaginationInfo(from: pagesDTO)
        }
        
        return CasinoGamesResponse(
            count: games.count,
            total: dto.total,
            games: games,
            pagination: pagination
        )
    }
    
    /// Maps EveryMatrix casino game DTO to public model
    static func casinoGame(from dto: EveryMatrix.CasinoGameDTO) -> CasinoGame {
        // Vendor is not displayed in UI anymore, set to nil
        let vendor: CasinoGameVendor? = nil
        
        // Extract tags from complex tags structure
        let tags = dto.tags?.items.compactMap { failableTagItem in
            failableTagItem.content.flatMap { tagItem in
                extractTagNameFromHref(tagItem.href)
            }
        }
        
        // Map real mode information
        let realMode = dto.realMode.map { realModeDTO in
            CasinoGameRealMode(
                fun: realModeDTO.fun ?? false,
                anonymity: realModeDTO.anonymity ?? false,
                realMoney: realModeDTO.realMoney ?? false
            )
        }
        
        // Map bet restrictions
        let betRestriction = dto.maxBetRestriction.map { betDTO in
            CasinoGameBetRestriction(
                defaultMaxBet: betDTO.defaultMaxBet,
                defaultMaxWin: betDTO.defaultMaxWin,
                defaultMaxMultiplier: betDTO.defaultMaxMultiplier
            )
        }
        
        return CasinoGame(
            id: dto.id,
            name: dto.name,
            launchUrl: dto.launchUrl,
            thumbnail: dto.thumbnail ?? dto.defaultThumbnail ?? "",
            backgroundImageUrl: dto.backgroundImageUrl ?? "",
            vendor: vendor,
            subVendor: dto.subVendor,
            description: dto.description ?? "",
            slug: dto.slug ?? "",
            hasFunMode: dto.hasFunMode ?? false,
            hasAnonymousFunMode: dto.hasAnonymousFunMode ?? false,
            platforms: dto.platform?.compactMap({ $0.content }) ?? [],
            popularity: dto.popularity,
            isNew: dto.isNew ?? false,
            width: dto.width,
            height: dto.height,
            theoreticalPayOut: dto.theoreticalPayOut,
            realMode: realMode,
            icons: dto.icons,
            tags: tags,
            maxBetRestriction: betRestriction
        )
    }
    
    /// Maps EveryMatrix casino game vendor DTO to public model
    // Vendor mapping removed - not needed since vendor is not displayed in UI
    
    // MARK: - Recently Played Mapping
    
    /// Maps EveryMatrix recently played response to public model
    static func casinoRecentlyPlayed(from dto: EveryMatrix.CasinoRecentlyPlayedResponseDTO) -> CasinoGamesResponse {
        let games = dto.items.compactMap { failableItem in
            // Extract game from nested FailableDecodable structure
            failableItem.content?.gameModel?.content.map { gameDTO in
                casinoGame(from: gameDTO)
            }
        }
        
        let pagination = dto.pages.map { pagesDTO in
            casinoPaginationInfo(from: pagesDTO)
        }
        
        return CasinoGamesResponse(
            count: games.count,
            total: dto.total ?? 0,
            games: games,
            pagination: pagination
        )
    }
    
    // MARK: - Pagination Mapping
    
    /// Maps EveryMatrix pages DTO to public pagination model
    static func casinoPaginationInfo(from dto: EveryMatrix.CasinoPagesDTO) -> CasinoPaginationInfo {
        return CasinoPaginationInfo(
            first: dto.first,
            next: dto.next,
            previous: dto.previous,
            last: dto.last
        )
    }
    
    // MARK: - Helper Methods
    
    /// Extracts tag name from href URL
    /// Example: "https://betsson-api.stage.norway.everymatrix.com/v1/casino/tags/Free%20Spins" -> "Free Spins"
    private static func extractTagNameFromHref(_ href: String) -> String? {
        guard let url = URL(string: href),
              let lastComponent = url.pathComponents.last else {
            return nil
        }
        
        // URL decode the tag name
        return lastComponent.removingPercentEncoding
    }
}
