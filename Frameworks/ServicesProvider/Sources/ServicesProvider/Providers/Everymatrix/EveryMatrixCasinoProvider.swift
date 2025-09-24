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
        
        let publisher: AnyPublisher<EveryMatrix.CasinoCategoriesResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
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
        
        let publisher: AnyPublisher<EveryMatrix.CasinoGroupResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                // Note: games are now under response.games.items
                let games = response.games.items.compactMap(\.content).map { 
                    EveryMatrixModelMapper.casinoGame(from: $0)
                }
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.games.total,
                    games: games,
                    pagination: response.games.pages.map { 
                        EveryMatrixModelMapper.casinoPaginationInfo(from: $0) 
                    }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func getGameDetails(gameId: String, language: String?, platform: String?) -> AnyPublisher<CasinoGame?, ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()
        
        let endpoint = EveryMatrixCasinoAPI.getGameDetails(
            gameId: gameId,
            language: finalLanguage,
            platform: finalPlatform
        )
        
        let publisher: AnyPublisher<EveryMatrix.CasinoGamesResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                guard let firstGame = response.items.compactMap(\.content).first else { return nil }
                return EveryMatrixModelMapper.casinoGame(from: firstGame)
            }
            .eraseToAnyPublisher()
    }
    
    func getRecentlyPlayedGames(playerId: String, language: String?, platform: String?, pagination: CasinoPaginationParams) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        
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
        
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()
        
        let endpoint = EveryMatrixCasinoAPI.getRecentlyPlayedGames(
            playerId: playerId,
            language: finalLanguage,
            platform: finalPlatform,
            offset: pagination.offset,
            limit: pagination.limit
        )
        
        let publisher: AnyPublisher<EveryMatrix.CasinoRecentlyPlayedResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                let games = response.items.compactMap(\.content).compactMap { item in
                    item.gameModel?.content.map { EveryMatrixModelMapper.casinoGame(from: $0) }
                }
                
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total,
                    games: games,
                    pagination: response.pages.map { EveryMatrixModelMapper.casinoPaginationInfo(from: $0) }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func buildGameLaunchUrl(for game: CasinoGame, mode: CasinoGameMode, sessionId: String?, language: String?) -> String? {

        let gameLaunchBaseURL = EveryMatrixUnifiedConfiguration.shared.gameLaunchBaseURL
        
        var urlString = "\(gameLaunchBaseURL)/Loader/Start/\(EveryMatrixUnifiedConfiguration.shared.domainId)/\(game.slug)"
        
        var queryParams: [String] = []
        
        let finalLanguage = language ?? EveryMatrixUnifiedConfiguration.shared.defaultLanguage
        queryParams.append("language=\(finalLanguage)")
        
        switch mode {
        case .funGuest:
            queryParams.append("fun=true")
            queryParams.append("authenticated=false")
            
        case .funLoggedIn:
            guard let sessionId = sessionId else { return nil }
            queryParams.append("fun=true")
            queryParams.append("authenticated=true")
            queryParams.append("sessionId=\(sessionId)")
            
        case .realMoney:
            guard let sessionId = sessionId else { return nil }
            queryParams.append("fun=false")
            queryParams.append("authenticated=true")
            queryParams.append("sessionId=\(sessionId)")
        }
        
        if !queryParams.isEmpty {
            urlString += "?" + queryParams.joined(separator: "&")
        }
        
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
}
