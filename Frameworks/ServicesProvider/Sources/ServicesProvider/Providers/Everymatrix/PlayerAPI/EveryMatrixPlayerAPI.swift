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
    case registerStep(phoneText: String, password: String, mobilePrefix: String, registrationId: String)
    case register(registrationId: String)
    case getUserProfile(userId: String)
    case getUserBalance(userId: String)
    case getBankingWebView(userId: String, parameters: EveryMatrix.GetPaymentSessionRequest)
    case getRecentlyPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)
    case getMostPlayedGames(playerId: String, language: String, platform: String, offset: Int, limit: Int)
}

extension EveryMatrixPlayerAPI: Endpoint {
    var url: String {
        switch self {
        default:
            return EveryMatrixUnifiedConfiguration.shared.playerAPIBaseURL
        }
    }
    
    var endpoint: String {
        switch self {
        case .login:
            return "/v1/player/legislation/login"
        case .getRegistrationConfig:
            return "/v1/player/legislation/registration/config"
        case .registerStep:
            return "/v1/player/legislation/registration/step"
        case .register:
            return "/v1/player/legislation/register"
        case .getUserProfile(let userId):
            return "/v1/player/\(userId)/details"
        case .getUserBalance(let userId):
            return "/v2/player/\(userId)/balance"
        case .getBankingWebView(let userId, _):
            return "/v1/player/\(userId)/payment/GetPaymentSession"
        case .getRecentlyPlayedGames(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/games/last-played"
        case .getMostPlayedGames(let playerId, _, _, _, _):
            return "/v1/player/\(playerId)/games/most-played"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .getRecentlyPlayedGames(_, let language, let platform, let offset, let limit):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "period", value: "Last7Days"),
                URLQueryItem(name: "unique", value: "true"),
                URLQueryItem(name: "dataSources", value: "Lobby1"),
                URLQueryItem(name: "hasGameModel", value: "true"),
                URLQueryItem(name: "order", value: "DESCENDING")
            ]
        case .getMostPlayedGames(_, let language, let platform, let offset, let limit):
            return [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "platform", value: platform),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "period", value: "Last7Days"),
                URLQueryItem(name: "unique", value: "true"),
                URLQueryItem(name: "dataSources", value: "Lobby1"),
                URLQueryItem(name: "hasGameModel", value: "true"),
                URLQueryItem(name: "order", value: "DESCENDING")
            ]
        default:
            return nil
        }
    }
    
    var headers: HTTP.Headers? {
        
        switch self {
        case .getUserProfile, .getUserBalance:
            let headers = [
                "Content-Type": "application/json",
                "User-Agent": "GOMA/native-app/iOS",
                "X-Session-Type": "others",
            ]
            return headers
        case .getBankingWebView:
            return [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        default:
            let headers = EveryMatrixUnifiedConfiguration.shared.defaultHeaders
            return headers
        }
        
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        return EveryMatrixUnifiedConfiguration.shared.defaultCachePolicy
    }
    
    var method: HTTP.Method {
        switch self {
        case .login:
            return .post
        case .getRegistrationConfig:
            return .get
        case .registerStep:
            return .post
        case .register:
            return .put
        case .getUserProfile:
            return .get
        case .getUserBalance:
            return .get
        case .getBankingWebView:
            return .post
        case .getRecentlyPlayedGames:
            return .get
        case .getMostPlayedGames:
            return .get
        }
    }
    
    var body: Data? {
        switch self {
        case .login(let username, let password):
            let body = """
                       {
                        "username": "\(username)",
                        "password": "\(password)"
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .registerStep(let phoneText, let password, let mobilePrefix, let registrationId):
            let body = """
                       {
                        "Step": "Step1",
                        "RegistrationId": "\(registrationId)",
                        "RegisterUserDto": {
                            "Mobile": "\(phoneText)",
                            "MobilePrefix": "\(mobilePrefix)",
                            "Password": "\(password)",
                            "TermsAndConditions": true
                        }
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .register(let registrationId):
            let body = """
                       {
                        "registrationId": "\(registrationId)"
                       }
                       """
            
            let data = body.data(using: String.Encoding.utf8)!
            
            return data
        case .getBankingWebView(_, let parameters):
            return try? JSONEncoder().encode(parameters)
        default:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixUnifiedConfiguration.shared.defaultTimeout

    }
    
    var requireSessionKey: Bool {
        switch self {
        case .getUserProfile:
            return true
        case .getUserBalance:
            return true
        case .getBankingWebView:
            return true
        case .getRecentlyPlayedGames:
            return true
        default:
            return false
        }
        
    }
    
    var comment: String? {
        return nil
    }

}
