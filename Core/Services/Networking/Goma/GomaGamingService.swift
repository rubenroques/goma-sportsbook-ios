//
//  GomaGamingService.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

enum GomaGamingService {
    case test
    case geolocation(latitude: String, longitude: String)
    case settings
    case simpleRegister(username: String, email: String, phone: String, birthDate: String, userProviderId: String, deviceToken: String)
    case modalPopUpDetails
    case login(username: String, password: String, deviceToken: String)
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
//        case .xpto, .foo:
//            return "/api/v1/abcd"
//        default:
//            return ""
        }
    }

    var query: [URLQueryItem]? {
        switch self {
        case .test:
            return nil
        case .geolocation(let latitude, let longitude):
            return [URLQueryItem(name: "lat", value: latitude),
                    URLQueryItem(name: "lng", value: longitude)]
        case .settings, .simpleRegister, .modalPopUpDetails, .login:
            return nil

            
//        case .getPredictionSubmit(let userId, let userName, let eventId, let prediction, let message):
//            return [URLQueryItem(name: "userId", value: userId),
//                    URLQueryItem(name: "userName", value: userName),
//                    URLQueryItem(name: "tip", value: prediction),
//                    URLQueryItem(name: "id", value: eventId),
//                    URLQueryItem(name: "message", value: message)]
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
        case .geolocation, .settings, .modalPopUpDetails:
            return .get
        case .simpleRegister, .login:
            return .post
//        case .xpto, .foo, .bar:
//            return .post
//        default:
//            return .get
        }
    }

    var body: Data? {

        switch self {
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
        default:
            return nil
        }

    }

}
