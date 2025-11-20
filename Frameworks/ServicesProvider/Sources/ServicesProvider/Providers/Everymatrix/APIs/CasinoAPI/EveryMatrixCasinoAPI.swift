import Foundation
import GomaPerformanceKit

enum EveryMatrixCasinoAPI {
    case getCategories(datasource: String, language: String, platform: String)
    case getGamesByCategory(datasource: String, categoryId: String, language: String, platform: String, offset: Int, limit: Int)
    case getGameDetails(gameId: String, language: String, platform: String)
    case searchGames(language: String, platform: String, name: String)
    case getRecommendedGames(language: String, platform: String)
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
        case .searchGames:
            return "/v1/casino/games"
        case .getRecommendedGames:
            return "/v1/casino/recommendedGames"
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
            
        case .searchGames(let language, let platform, let name):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "filter", value: "name=\(name)")
            ]
            
        case .getRecommendedGames(let language, let platform):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
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
        case .getRecommendedGames:
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
        case .searchGames:
            return "Fetch searched games"
        case .getRecommendedGames:
            return "Fetch recommended games"
        }
    }

    var performanceFeature: PerformanceFeature? {
        switch self {
        case .getCategories, .getGamesByCategory:
            return .casinoHome
        case .getGameDetails, .searchGames, .getRecommendedGames:
            return nil  // Don't track these
        }
    }
}
