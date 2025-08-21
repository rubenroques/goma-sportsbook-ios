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
        }
    }
    
    var query: [URLQueryItem]? {
        return nil
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
        default:
            let headers = EveryMatrixConfiguration.default.defaultHeaders
            return headers
        }
        
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
        case .registerStep:
            return .post
        case .register:
            return .put
        case .getUserProfile:
            return .get
        case .getUserBalance:
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
        default:
            return nil
        }
    }
    
    var timeout: TimeInterval {
        return EveryMatrixConfiguration.default.defaultTimeout

    }
    
    var requireSessionKey: Bool {
        switch self {
        case .getUserProfile:
            return true
        case .getUserBalance:
            return true
        default:
            return false
        }
        
    }
    
    var comment: String? {
        return nil
    }

}
