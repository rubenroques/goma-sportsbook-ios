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
    case getWageringTransactions(userId: String, startDate: String, endDate: String, pageNumber: Int?)
    case getBankingTransactions(userId: String, startDate: String, endDate: String, pageNumber: Int?)
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
        case .getWageringTransactions(let userId, _, _, _):
            return "/v1/player/\(userId)/transactions/wagering"
        case .getBankingTransactions(let userId, _, _, _):
            return "/v1/player/\(userId)/transactions/banking"
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .getWageringTransactions(_, let startDate, let endDate, let pageNumber):
            var queryItems = [
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate)
            ]
            if let pageNumber = pageNumber {
                queryItems.append(URLQueryItem(name: "page", value: String(pageNumber)))
            }
            return queryItems
        case .getBankingTransactions(_, let startDate, let endDate, let pageNumber):
            var queryItems = [
                URLQueryItem(name: "startDate", value: startDate),
                URLQueryItem(name: "endDate", value: endDate)
            ]
            if let pageNumber = pageNumber {
                queryItems.append(URLQueryItem(name: "page", value: String(pageNumber)))
            }
            return queryItems
        default:
            return nil
        }
    }
    
    var headers: HTTP.Headers? {

        switch self {
        case .getUserProfile, .getUserBalance, .getWageringTransactions, .getBankingTransactions:
            let headers = [
                "Content-Type": "application/json",
                "User-Agent": "GOMA/native-app/iOS",
                "X-Session-Type": "others",
                "Accept": "application/json"
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
        case .getWageringTransactions, .getBankingTransactions:
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
        case .getWageringTransactions, .getBankingTransactions:
            return true
        default:
            return false
        }

    }
    
    var comment: String? {
        return nil
    }

}
