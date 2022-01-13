//
//  GomaGamingService.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

enum GomaGamingService {
    case test
    case log(type: String, message: String)
    case geolocation(latitude: String, longitude: String)
    case settings
    case simpleRegister(username: String, email: String, phone: String, birthDate: String, userProviderId: String, deviceToken: String)
    case modalPopUpDetails
    case login(username: String, password: String, deviceToken: String)
    case suggestedBets
    case favorites(favorites: String)
    // case getActivateUserEmailCode(userEmail: String, activationCode: String) //example of request with params
}

extension GomaGamingService: Endpoint {

    var url: String {
        return TargetVariables.gomaGamingHost
    }

    var endpoint: String {

        let apiVersion = "v1"

        switch self {
        case .test:
            return "/api/\(apiVersion)/me"
        case .log:
            return "/log/api/\(apiVersion)"
        case .geolocation:
            return "/api/settings/\(apiVersion)/geolocation"
        case .settings:
            return "/api/\(apiVersion)/modules"
        case .simpleRegister:
            return "/api/users/\(apiVersion)/register"
        case .modalPopUpDetails:
            return "/api/settings/\(apiVersion)/info-popup"
        case .login:
            return "/api/auth/\(apiVersion)/login"
        case .suggestedBets:
            return "/api/betting/\(apiVersion)/betslip/suggestions"
        case .favorites:
            return "/api/favorites/\(apiVersion)"
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .log, .test:
            return nil
        case .geolocation(let latitude, let longitude):
            return [URLQueryItem(name: "lat", value: latitude),
                    URLQueryItem(name: "lng", value: longitude)]
        case .settings, .simpleRegister, .modalPopUpDetails, .login, .suggestedBets, .favorites:
            return nil
        }
    }

    var headers: HTTP.Headers? {
        let defaultHeaders = [
            "Accept-Encoding": "gzip, deflate",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json"
        ]
        return defaultHeaders
    }

    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalCacheData
    }

    var timeout: TimeInterval {
        return TimeInterval(20)
    }

    var method: HTTP.Method {
        switch self {
        case .test:
            return .get
        case .geolocation, .settings, .modalPopUpDetails, .suggestedBets:
            return .get
        case .log, .simpleRegister, .login, .favorites:
            return .post
        }
    }

    var body: Data? {

        switch self {
        case .log(let type, let message):
            let body = """
                       {"type": "\(type)","text": "\(message)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .simpleRegister(let username, let email, let phone, let birthDate, let userProviderId, let deviceToken):
            let body = """
                       {"type": "small_register",
                        "email": "\(email)",
                        "username": "\(username)",
                        "phone_number": "\(phone)",
                        "birthdate": "\(birthDate)",
                        "user_provider_id": "\(userProviderId)",
                        "device_token": "\(deviceToken)"
                       }
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .login(let username, let password, let deviceToken):
            let body = """
                       {"username": "\(username)",
                        "password": "\(password)",
                        "device_token": "\(deviceToken)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        case .favorites(let favorites):
            let body = """
                    {"favorites":
                    [
                    \(favorites)
                    ]
                    }
                    """
            let data = body.data(using: String.Encoding.utf8)!
            return data
        default:
            return nil
        }

    }

}
