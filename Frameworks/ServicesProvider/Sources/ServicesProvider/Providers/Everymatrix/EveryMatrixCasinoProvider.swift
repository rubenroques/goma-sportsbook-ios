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


        // If sessionId not provided, fetch from connector
        let sessionId = self.connector.sessionToken

        let gameLaunchBaseURL = EveryMatrixUnifiedConfiguration.shared.gameLaunchBaseURL

        var urlString = "\(gameLaunchBaseURL)/Loader/Start/\(EveryMatrixUnifiedConfiguration.shared.operatorId)/\(game.slug)"

        var queryParams: [String] = []

        let finalLanguage = language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage
        queryParams.append("language=\(finalLanguage)")

        switch mode {
        case .funGuest:
            print("[GAME-LAUNCH] Mode: funGuest - NO session params")
            // Guest mode - no session parameters
            break

        case .funLoggedIn:
            print("[GAME-LAUNCH] Mode: funLoggedIn - adding funMode + _sid")
            guard let sessionIdValue = sessionId else {
                print("[GAME-LAUNCH] ❌ ERROR: funLoggedIn mode but NO sessionId!")
                return nil
            }
            queryParams.append("funMode=True")
            queryParams.append("_sid=\(sessionIdValue)")

        case .realMoney:
            print("[GAME-LAUNCH] Mode: realMoney - adding _sid")
            guard let sessionIdValue = sessionId else {
                print("[GAME-LAUNCH] ❌ ERROR: realMoney mode but NO sessionId!")
                return nil
            }
            queryParams.append("_sid=\(sessionIdValue)")
        }

        if !queryParams.isEmpty {
            urlString += "?" + queryParams.joined(separator: "&")
        }

        print("[GAME-LAUNCH] Final URL: \(urlString)")
        print("[GAME-LAUNCH] ═══════════════════════════════════════")

        return urlString
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
