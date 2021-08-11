//
//  GomaGamingService.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

enum GomaGamingService {
    case test
    //case getActivateUserEmailCode(userEmail: String, activationCode: String) //example of request with params
}

extension GomaGamingService: Endpoint {

    var url: String {
        return TargetVariables.gomaGamingHost
    }

    var endpoint: String {

        let apiVersion = "v1"

        switch self {
        case .test:
            return "/api/me"
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
//        case .getPredictionSubmit(let userId, let userName, let eventId, let prediction, let message):
//            return [URLQueryItem(name: "userId", value: userId),
//                    URLQueryItem(name: "userName", value: userName),
//                    URLQueryItem(name: "tip", value: prediction),
//                    URLQueryItem(name: "id", value: eventId),
//                    URLQueryItem(name: "message", value: message)]
        }
    }

    var headers: HTTP.Headers? {

//        var defaultHeaders = [
//            "Accept-Encoding": "gzip, deflate",
//            "Content-Type": "application/json; charset=UTF-8"
//        ]

        let defaultHeaders: HTTP.Headers = [:]

        switch self {
        case .test:
            () //We can add extra header according to the endpoint we are calling
        }

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
//        case .xpto, .foo, .bar:
//            return .post
//        default:
//            return .get
        }
    }

    var body: Data? {
        return nil
    }

}
