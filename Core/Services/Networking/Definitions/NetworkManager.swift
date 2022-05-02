//
//  NetworkManager.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/08/2021.
//

import Foundation
import Combine

struct NetworkManager {

    private let session: NetworkSession
    private let authenticator: Authenticator

    init(session: NetworkSession = URLSession.shared) {

        let anonymousAuthEndpoint = URL(string: TargetVariables.gomaGamingAnonymousAuthEndpoint)!
        let gomaGamingLoggedAuthEndpoint = URL(string: TargetVariables.gomaGamingLoggedAuthEndpoint)!

        self.session = session
        self.authenticator = Authenticator(session: session,
                                           anonymousAuthEndpointURL: anonymousAuthEndpoint,
                                           loggedUserAuthEndpointURL: gomaGamingLoggedAuthEndpoint)
    }

    func refreshAuthToken(token: AuthToken) {
        self.authenticator.refreshAuthTokenWithGomaLogin(token: token)
    }

    func getCurrentToken() -> AuthToken? {
        return self.authenticator.getCurrentToken()
    }

    func requestEndpoint<T: Decodable>(deviceId: String, endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {

        guard
            let request = endpoint.request()
        else {
            let error = NetworkError.init(errors: [.invalidRequest])
            return AnyPublisher(Fail<T, NetworkError>(error: error))
        }

        var userLoginForm: UserLoginForm?
        if let user = UserSessionStore.loggedUserSession() {
            userLoginForm = UserLoginForm(username: user.username, password: user.userId, deviceToken: Env.deviceFCMToken)
        }

        return authenticator.validToken(deviceId: deviceId, loggedUser: userLoginForm)
            .flatMap { token -> AnyPublisher<Data, Error> in
                return session.publisher(for: request, token: token)
            }
            .tryCatch { error -> AnyPublisher<Data, Error> in

                guard
                    let serviceError = error as? NetworkError,
                    serviceError.errors.contains(.unauthorized)
                else {
                    throw error
                }

                return authenticator.validToken(deviceId: deviceId, forceRefresh: true, loggedUser: userLoginForm)
                    .flatMap { token -> AnyPublisher<Data, Error> in
                        // We can now use this new token to authenticate the second attempt at making this request
                        return session.publisher(for: request, token: token)
                    }
                    .eraseToAnyPublisher()
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let serviceError = error as? NetworkError, serviceError.errors.contains(.forbidden) {
                    return NetworkError(errors: [.forbidden])
                }
                else {

                    return NetworkError(errors: [.invalidResponse])
                }
            }
            .eraseToAnyPublisher()
    }

    // TODO: Code Review - remove this, requestEndpoint is enought 
    func requestEndpointArrayData<T: Decodable>(deviceId: String, endpoint: Endpoint) -> AnyPublisher<T?, NetworkError> {

        guard
            let request = endpoint.request()
        else {
            let error = NetworkError.init(errors: [.invalidRequest])
            return AnyPublisher(Fail<T?, NetworkError>(error: error))
        }

        var userLoginForm: UserLoginForm?
        if let user = UserSessionStore.loggedUserSession() {
            userLoginForm = UserLoginForm(username: user.username, password: user.userId, deviceToken: Env.deviceFCMToken)
        }

        return authenticator.validToken(deviceId: deviceId, loggedUser: userLoginForm)
            .flatMap({ token -> AnyPublisher<Data, Error> in
                // We can now use this token to authenticate the request
                return session.publisher(for: request, token: token)
            })
            .tryCatch({ error -> AnyPublisher<Data, Error> in
                guard
                    let serviceError = error as? NetworkError,
                    serviceError.errors.contains(.unauthorized)
                else {
                    throw error
                }

                return authenticator.validToken(deviceId: deviceId, forceRefresh: true, loggedUser: userLoginForm)
                    .flatMap({ token -> AnyPublisher<Data, Error> in
                        // We can now use this new token to authenticate the second attempt at making this request
                        return session.publisher(for: request, token: token)
                    })
                    .eraseToAnyPublisher()
            })
            .decode(type: T?.self, decoder: JSONDecoder())
            .mapError({ error1 in
                print("mapError error \(error1)")
                return NetworkError(errors: [.invalidResponse]) })
            .eraseToAnyPublisher()
    }
}
