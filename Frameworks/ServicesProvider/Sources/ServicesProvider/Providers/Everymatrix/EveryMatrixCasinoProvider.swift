import Foundation
import Combine

class EveryMatrixCasinoProvider: CasinoProvider {
    
    private let connector: EveryMatrixCasinoConnector
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Connector Protocol
    
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return connector.connectionStatePublisher
    }
    
    init(connector: EveryMatrixCasinoConnector) {
        self.connector = connector
    }

    // MARK: - Private Helper Methods

    /// Maps CasinoLobbyType enum to the appropriate datasource string
    private func datasourceForLobbyType(_ lobbyType: CasinoLobbyType?) -> String {
        switch lobbyType {
        case .casino, nil:
            return EveryMatrixUnifiedConfiguration.shared.casinoDataSource
        case .virtuals:
            return EveryMatrixUnifiedConfiguration.shared.virtualsDataSource
        }
    }

    func getCasinoCategories(language: String?, platform: String?, lobbyType: CasinoLobbyType?) -> AnyPublisher<[CasinoCategory], ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()
        let finalDatasource = datasourceForLobbyType(lobbyType)
        
        let endpoint = EveryMatrixCasinoAPI.getCategories(
            datasource: finalDatasource,
            language: finalLanguage,
            platform: finalPlatform
        )
        
        let publisher: AnyPublisher<EveryMatrix.CasinoCategoriesResponse, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                let categories = response.items.compactMap(\.content).map { EveryMatrixModelMapper.casinoCategory(from: $0) }
                return categories
            }
            .eraseToAnyPublisher()
    }
    
    func getGamesByCategory(categoryId: String, language: String?, platform: String?, lobbyType: CasinoLobbyType?, pagination: CasinoPaginationParams) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()
        let finalDatasource = datasourceForLobbyType(lobbyType)
        
        // Category ID might already include datasource prefix, or we might need to add it
        let fullCategoryId = categoryId.contains("$") ? categoryId : "\(finalDatasource)$\(categoryId)"

        let endpoint = EveryMatrixCasinoAPI.getGamesByCategory(
            datasource: finalDatasource,
            categoryId: fullCategoryId,
            language: finalLanguage,
            platform: finalPlatform,
            offset: pagination.offset,
            limit: pagination.limit
        )
        
        let publisher: AnyPublisher<EveryMatrix.CasinoGroupResponse, ServiceProviderError> = connector.request(endpoint)

        return publisher
            .tryMap { response in
                guard let gamesData = response.games else {
                    throw ServiceProviderError.errorMessage(message: "No games data in response")
                }

                let games = gamesData.items.compactMap(\.content).map {
                    EveryMatrixModelMapper.casinoGame(from: $0)
                }
                return CasinoGamesResponse(
                    count: games.count,
                    total: gamesData.total,
                    games: games,
                    pagination: gamesData.pages.map {
                        EveryMatrixModelMapper.casinoPaginationInfo(from: $0)
                    }
                )
            }
            .mapError { error in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func getGameDetails(gameId: String, language: String?, platform: String?) -> AnyPublisher<CasinoGame, ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()

        let endpoint = EveryMatrixCasinoAPI.getGameDetails(
            gameId: gameId,
            language: finalLanguage,
            platform: finalPlatform
        )

        let publisher: AnyPublisher<EveryMatrix.CasinoGamesResponse, ServiceProviderError> = connector.request(endpoint)

        return publisher
            .tryMap { response -> CasinoGame in
                guard let firstGame = (response.items ?? []).compactMap(\.content).first else {
                    throw ServiceProviderError.resourceNotFound
                }
                return EveryMatrixModelMapper.casinoGame(from: firstGame)
            }
            .mapError { error in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
    
    func searchGames(language: String?, platform: String?, name: String) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultCasinoPlatform()

        let endpoint = EveryMatrixCasinoAPI.searchGames(
            language: finalLanguage,
            platform: finalPlatform,
            name: name
        )

        let publisher: AnyPublisher<EveryMatrix.CasinoGamesResponse, ServiceProviderError> = connector.request(endpoint)

        return publisher
            .map { response in
                let games = (response.items ?? []).compactMap(\.content).map {
                    EveryMatrixModelMapper.casinoGame(from: $0)
                }
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total,
                    games: games,
                    pagination: response.pages.map {
                        EveryMatrixModelMapper.casinoPaginationInfo(from: $0)
                    }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func getRecommendedGames(language: String?, platform: String?) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        
        guard connector.sessionToken != nil else {
            return Just(CasinoGamesResponse(
                count: 0,
                total: 0,
                games: [],
                pagination: nil
            ))
            .setFailureType(to: ServiceProviderError.self)
            .eraseToAnyPublisher()
        }
        
        let endpoint = EveryMatrixCasinoAPI.getRecommendedGames(
            language: language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            platform: platform ?? "iPhone"
        )

        let publisher: AnyPublisher<EveryMatrix.CasinoGamesResponse, ServiceProviderError> = connector.request(endpoint)

        return publisher
            .map { response in
                let games = (response.items ?? []).compactMap(\.content).map {
                    EveryMatrixModelMapper.casinoGame(from: $0)
                }
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total,
                    games: games,
                    pagination: response.pages.map {
                        EveryMatrixModelMapper.casinoPaginationInfo(from: $0)
                    }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func buildGameLaunchUrl(for game: CasinoGame, mode: CasinoGameMode, language: String?) -> String? {
        print("[GAME-LAUNCH] ═══════════════════════════════════════")
        print("[GAME-LAUNCH] Building URL for game: \(game.name)")
        print("[GAME-LAUNCH] Mode: \(mode)")

        // Start with the launchUrl from API response
        guard var urlComponents = URLComponents(string: game.launchUrl) else {
            print("[GAME-LAUNCH] ❌ ERROR: Invalid launchUrl from API: \(game.launchUrl)")
            return nil
        }

        // Prepare query parameters as [URLQueryItem] for proper encoding
        var queryItems: [URLQueryItem] = []

        // 1. Language parameter
        let finalLanguage = language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage
        queryItems.append(URLQueryItem(name: "language", value: finalLanguage))

        // 2. Mode-specific parameters
        let sessionId = self.connector.sessionToken

        switch mode {
        case .funGuest:
            // Guest mode - no session parameters needed
            print("[GAME-LAUNCH] Mode: funGuest - NO session params")

        case .funLoggedIn:
            // Fun mode for logged-in users
            print("[GAME-LAUNCH] Mode: funLoggedIn - adding funMode + _sid")
            guard let sessionIdValue = sessionId else {
                print("[GAME-LAUNCH] ❌ ERROR: funLoggedIn mode but NO sessionId!")
                return nil
            }
            queryItems.append(URLQueryItem(name: "funMode", value: "True"))
            queryItems.append(URLQueryItem(name: "_sid", value: sessionIdValue))

        case .realMoney:
            // Real money mode
            print("[GAME-LAUNCH] Mode: realMoney - adding _sid")
            guard let sessionIdValue = sessionId else {
                print("[GAME-LAUNCH] ❌ ERROR: realMoney mode but NO sessionId!")
                return nil
            }
            queryItems.append(URLQueryItem(name: "_sid", value: sessionIdValue))
        }

        // 3. Merge query items with existing parameters from API
        var allQueryItems = urlComponents.queryItems ?? []
        allQueryItems.append(contentsOf: queryItems)
        urlComponents.queryItems = allQueryItems

        // 4. Build final URL
        guard let finalUrl = urlComponents.url?.absoluteString else {
            print("[GAME-LAUNCH] ❌ ERROR: Failed to construct URL from components")
            return nil
        }

        print("[GAME-LAUNCH] Base launchUrl: \(game.launchUrl)")
        print("[GAME-LAUNCH] Final URL: \(finalUrl)")
        print("[GAME-LAUNCH] ═══════════════════════════════════════")

        return finalUrl
    }
    
    func getDefaultCategoryId() -> String {
        return "VIDEOSLOTS"
    }
    
    func getDefaultPlatform() -> String {
        return EveryMatrixUnifiedConfiguration.shared.defaultPlatform
    }
    
    func getDefaultLanguage() -> String {
        return EveryMatrixUnifiedConfiguration.shared.defaultLanguage
    }
    
    func getDefaultCasinoPlatform() -> String {
        return EveryMatrixUnifiedConfiguration.shared.defaultCasinoPlatform
    }
}
