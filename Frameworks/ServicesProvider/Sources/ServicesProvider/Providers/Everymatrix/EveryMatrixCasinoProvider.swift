import Foundation
import Combine

class EveryMatrixCasinoProvider: CasinoProvider {
    
    private let connector: EveryMatrixCasinoConnector
    private let environment: EveryMatrixCasinoAPIEnvironment
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Connector Protocol
    
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return connector.connectionStatePublisher
    }
    
    init(connector: EveryMatrixCasinoConnector, environment: EveryMatrixCasinoAPIEnvironment = .staging) {
        self.connector = connector
        self.environment = environment
    }
    
    func getCasinoCategories(language: String?, platform: String?) -> AnyPublisher<[CasinoCategory], ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()
        
        let endpoint = EveryMatrixCasinoAPI.getCategories(
            language: finalLanguage,
            platform: finalPlatform
        )
        
        let publisher: AnyPublisher<CasinoCategoriesResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                let categories = response.items?.map { EveryMatrixModelMapper.casinoCategory(from: $0) } ?? []
                return self.filterCategoriesWithGames(categories)
            }
            .eraseToAnyPublisher()
    }
    
    func getGamesByCategory(categoryId: String, language: String?, platform: String?, pagination: CasinoPaginationParams) -> AnyPublisher<CasinoGamesResponse, ServiceProviderError> {
        let finalLanguage = language ?? getDefaultLanguage()
        let finalPlatform = platform ?? getDefaultPlatform()
        
        let endpoint = EveryMatrixCasinoAPI.getGamesByCategory(
            categoryId: categoryId,
            language: finalLanguage,
            platform: finalPlatform,
            offset: pagination.offset,
            limit: pagination.limit
        )
        
        let publisher: AnyPublisher<CasinoGamesResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                let games = response.items?.map { EveryMatrixModelMapper.casinoGame(from: $0) } ?? []
                
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total ?? 0,
                    games: games,
                    pagination: response.pages.map { EveryMatrixModelMapper.casinoPaginationInfo(from: $0) }
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
        
        let publisher: AnyPublisher<CasinoGamesResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                guard let firstGame = response.items?.first else { return nil }
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
        
        let publisher: AnyPublisher<CasinoRecentlyPlayedResponseDTO, ServiceProviderError> = connector.request(endpoint)
        
        return publisher
            .map { response in
                let games = response.items?.compactMap { item in
                    item.gameModel.map { EveryMatrixModelMapper.casinoGame(from: $0) }
                } ?? []
                
                return CasinoGamesResponse(
                    count: games.count,
                    total: response.total ?? 0,
                    games: games,
                    pagination: response.pages.map { EveryMatrixModelMapper.casinoPaginationInfo(from: $0) }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func buildGameLaunchUrl(for game: CasinoGame, mode: CasinoGameMode, sessionId: String?, language: String?) -> String? {
        
        guard supportsGameMode(game: game, mode: mode) else {
            return nil
        }
        
        let gameLaunchBaseURL: String
        switch environment {
        case .staging:
            gameLaunchBaseURL = "https://gamelaunch-stage.everymatrix.com"
        case .production:
            gameLaunchBaseURL = "https://gamelaunch.everymatrix.com"
        }
        
        var urlString = "\(gameLaunchBaseURL)/Loader/Start/\(environment.domainId)/\(game.slug)"
        
        var queryParams: [String] = []
        
        let finalLanguage = language ?? environment.defaultLanguage
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
        return environment.defaultPlatform
    }
    
    func getDefaultLanguage() -> String {
        return environment.defaultLanguage
    }
}