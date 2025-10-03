//
//  EveryMatrixRecsysAPI.swift
//
//  Endpoints for the Bet Recommendation (RecSys) API, following the PlayerAPI style.
//

import Foundation

enum EveryMatrixRecsysAPI {
    case recommendations(userId: String, isLive: Bool, terminalType: Int)
    case comboRecommendations(userId: String, isLive: Bool, terminalType: Int)

}

extension EveryMatrixRecsysAPI: Endpoint {
    var url: String {
        switch self {
        case .comboRecommendations:
            return EveryMatrixUnifiedConfiguration.shared.recsysComboAPIBaseURL
        default:
            return EveryMatrixUnifiedConfiguration.shared.recsysAPIBaseURL
        }
    }
    
    var endpoint: String {
        switch self {
        case .recommendations:
            return "/recommendations"
        case .comboRecommendations:
            return "/recommendations"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .recommendations(let userId, let isLive, let terminalType):
            return [
                URLQueryItem(name: "domain_id", value: EveryMatrixUnifiedConfiguration.shared.domainId),
                URLQueryItem(name: "user_id", value: userId),
                URLQueryItem(name: "is_live", value: isLive ? "true" : "false"),
                URLQueryItem(name: "terminal_type", value: String(terminalType)),
                URLQueryItem(name: "key", value: EveryMatrixUnifiedConfiguration.shared.recsysAPIKey)
            ]
        case .comboRecommendations(let userId, let isLive, let terminalType):
            return [
                URLQueryItem(name: "domain_id", value: EveryMatrixUnifiedConfiguration.shared.domainId),
                URLQueryItem(name: "user_id", value: userId),
                URLQueryItem(name: "is_live", value: isLive ? "true" : "false"),
                URLQueryItem(name: "terminal_type", value: String(terminalType)),
                URLQueryItem(name: "key", value: EveryMatrixUnifiedConfiguration.shared.recsysComboAPIKey)
            ]
        }
    }
    
    var headers: HTTP.Headers? {
        return [
            "Accept": "application/json"
        ]
    }
    
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
    var method: HTTP.Method { .get }
    var body: Data? { nil }
    var timeout: TimeInterval { 15 }
    var requireSessionKey: Bool { false }
    var comment: String? {
        switch self {
        case .recommendations:
            return "RecSys Single Bets recommendations"
        case .comboRecommendations:
            return "RecSys Combo Bets recommendations"
        }
        
    }
}


