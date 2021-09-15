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

        let authEndpointURL = URL(string: TargetVariables.gomaGamingAuthEndpoint)!

        self.session = session
        self.authenticator = Authenticator(session: session, authEndpointURL: authEndpointURL)
    }

    func requestEndpoint<T: Decodable>(deviceId: String, endpoint: Endpoint) -> AnyPublisher<T?, NetworkError> {

        guard
            let request = endpoint.request()
        else {
            let error = NetworkError.init(errors: [.invalidRequest])
            return AnyPublisher(Fail<T?, NetworkError>(error: error))
        }

        return authenticator.validToken(deviceId: deviceId)
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

                return authenticator.validToken(deviceId: deviceId, forceRefresh: true)
                    .flatMap { token -> AnyPublisher<Data, Error> in
                        // We can now use this new token to authenticate the second attempt at making this request
                        return session.publisher(for: request, token: token)
                    }
                    .eraseToAnyPublisher()
            }
            .decode(type: NetworkResponse<T>.self, decoder: JSONDecoder())
            .mapError { _ in
                        return NetworkError(errors: [.invalidResponse])
            }
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func requestEndpointArrayData<T: Decodable>(deviceId: String, endpoint: Endpoint) -> AnyPublisher<T?, NetworkError> {

            guard
                let request = endpoint.request()
            else {
                let error = NetworkError.init(errors: [.invalidRequest])
                return AnyPublisher(Fail<T?, NetworkError>(error: error))
            }

            return authenticator.validToken(deviceId: deviceId)
                .flatMap({ token -> AnyPublisher<Data, Error> in
                    // We can now use this token to authenticate the request
                    print("flatMap1 token \(token)")
                    return session.publisher(for: request, token: token)
                })
                .tryCatch({ error -> AnyPublisher<Data, Error> in

                    print("tryCatch error \(error)")

                    guard
                        let serviceError = error as? NetworkError,
                        serviceError.errors.contains(.unauthorized)
                    else {
                        throw error
                    }

                    return authenticator.validToken(deviceId: deviceId, forceRefresh: true)
                        .flatMap({ token -> AnyPublisher<Data, Error> in
                            print("flatMap1 token \(token)")
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
