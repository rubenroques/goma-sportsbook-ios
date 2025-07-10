//
//  EveryMatrixAPI.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation

enum EveryMatrixPlayerAPI {
    case login(username: String, password: String)
    case getRegistrationConfig

}

extension EveryMatrixPlayerAPI: Endpoint {
    var url: String {
        switch self {
        default:
            return EveryMatrixConfiguration.default.environment.baseURL
        }
    }
    
    var endpoint: String {
        switch self {
        case .login:
            return "/v1/player/login/player"
        case .getRegistrationConfig:
            return "/v1/player/legislation/registration/config"
        }
    }
    
    var query: [URLQueryItem]? {
        return nil
    }
    
    var headers: HTTP.Headers? {
        var headers = EveryMatrixConfiguration.default.defaultHeaders
        
        return headers
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixConfiguration.default.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .login:
            return .post
        case .getRegistrationConfig:
            return .get
        }
    }
    
    var body: Data? {
        switch self {
            
        default:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixConfiguration.default.defaultTimeout

    }
    
    var requireSessionKey: Bool {
        return false
    }
    
    var comment: String? {
        return nil
    }

}
