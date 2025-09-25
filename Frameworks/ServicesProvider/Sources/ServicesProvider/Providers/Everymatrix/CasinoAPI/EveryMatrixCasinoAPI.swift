import Foundation

enum EveryMatrixCasinoAPI {
    case getCategories(datasource: String, language: String, platform: String)
    case getGamesByCategory(datasource: String, categoryId: String, language: String, platform: String, offset: Int, limit: Int)
    case getGameDetails(gameId: String, language: String, platform: String)
    case getRecentlyPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)
}

extension EveryMatrixCasinoAPI: Endpoint {
    var url: String {
        return EveryMatrixUnifiedConfiguration.shared.casinoAPIBaseURL
    }
    
    var endpoint: String {
        switch self {
        case .getCategories(let datasource, _, _):
            return "/v2/casino/groups/\(datasource)"
        case .getGamesByCategory(let datasource, let categoryId, _, _, _, _):
            return "/v2/casino/groups/\(datasource)/\(categoryId)"
        case .getGameDetails:
            return "/v1/casino/games"
        case .getRecentlyPlayedGames(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/games/last-played"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .getCategories(_, let language, let platform):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "pagination", value: "games(offset=0,limit=1)"),
                URLQueryItem(name: "fields", value: "id,name,games")
            ]
            
        case .getGamesByCategory(_, _, let language, let platform, let offset, let limit):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "pagination", value: "offset=\(offset),limit=\(limit)"),
                URLQueryItem(name: "expand", value: "games"),
                URLQueryItem(name: "fields", value: "id,name,games"),
                URLQueryItem(name: "sortedField", value: "popularity")
            ]
            
        case .getGameDetails(let gameId, let language, let platform):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "expand", value: "vendor"),
                URLQueryItem(name: "filter", value: "id=\(gameId)")
            ]
            
        case .getRecentlyPlayedGames(_, let language, let platform, let offset, let limit):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "unique", value: "true"),
                URLQueryItem(name: "hasGameModel", value: "true"),
                URLQueryItem(name: "order", value: "ASCENDING")
            ]
        }
    }
    
    var headers: HTTP.Headers? {
        var headers = EveryMatrixUnifiedConfiguration.shared.defaultHeaders
        headers["X-Session-Type"] = "others"
        return headers
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixUnifiedConfiguration.shared.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        return .get
    }
    
    var body: Data? {
        return nil
    }
    
    var timeout: TimeInterval {
        return EveryMatrixUnifiedConfiguration.shared.defaultTimeout
    }
    
    var requireSessionKey: Bool {
        switch self {
        case .getRecentlyPlayedGames:
            return true
        default:
            return false
        }
    }
    
    var comment: String? {
        switch self {
        case .getCategories:
            return "Fetch casino game categories"
        case .getGamesByCategory:
            return "Fetch games for a specific category with pagination"
        case .getGameDetails:
            return "Fetch details for a specific game"
        case .getRecentlyPlayedGames:
            return "Fetch recently played games for authenticated user"
        }
    }
}
