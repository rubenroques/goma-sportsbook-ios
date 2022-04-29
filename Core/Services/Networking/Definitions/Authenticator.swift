//
//  Authenticator.swift
//  Sportsbook
//
//  Created by Ruben Roques on 10/08/2021.
//

import Foundation
import Combine

enum AuthenticationError: Error {
    case loginRequired
    case deallocated
}

class Authenticator {

    private let session: NetworkSession
    private var currentToken: AuthToken?
    private let queue = DispatchQueue(label: "Autenticator.\(UUID().uuidString)")

    private let loggedUserEndpointURL: URL
    private let anonymousEndpointURL: URL

    // This publisher is shared amongst all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<AuthToken, Error>?

    init(session: NetworkSession = URLSession.shared, anonymousAuthEndpointURL: URL, loggedUserAuthEndpointURL: URL) {
        self.session = session

        self.anonymousEndpointURL = anonymousAuthEndpointURL
        self.loggedUserEndpointURL = loggedUserAuthEndpointURL
    }

    func refreshAuthTokenWithGomaLogin(token: AuthToken) {
        self.currentToken = token
    }

    func getCurrentToken() -> AuthToken? {
        return self.currentToken
    }

    func validToken(deviceId: String, forceRefresh: Bool = false, loggedUser: UserLoginForm?) -> AnyPublisher<AuthToken, Error> {

        if let loggedUser = loggedUser {
            return self.loggedUserValidToken(deviceId: deviceId, forceRefresh: forceRefresh, loggedUser: loggedUser)
        }
        else {
            return self.anonymousValidToken(deviceId: deviceId, forceRefresh: forceRefresh)
        }

    }

    private func loggedUserValidToken(deviceId: String, forceRefresh: Bool = false, loggedUser: UserLoginForm) -> AnyPublisher<AuthToken, Error> {
        return queue.sync { [weak self] in

            var shouldForceRefresh = forceRefresh

            // We're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // We don't have a token so we override the forceRefresh
            if let selfValue = self, selfValue.currentToken == nil {
                shouldForceRefresh = true
            }

            // We already have a valid token and don't want to force a refresh
            if let selfValue = self, let token = selfValue.currentToken, token.isValid, !shouldForceRefresh {
                return Just(token).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            guard let weakSelf = self else { return Fail(error: NetworkErrorCode.invalidRequest).eraseToAnyPublisher() }

            // We need a new token
            var request = URLRequest(url: weakSelf.loggedUserEndpointURL)
            request.httpMethod = "POST"

            request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let body = """
                       {"username": "\(loggedUser.username)",
                        "password": "\(loggedUser.password)",
                        "device_token": "\(loggedUser.deviceToken)"}
                       """
            let data = body.data(using: String.Encoding.utf8)!
            request.httpBody = data

            let publisher = session.publisher(for: request, token: nil)
                .share()
                .decode(type: AuthToken.self, decoder: JSONDecoder())
                .handleEvents(receiveOutput: { token in
                    self?.currentToken = token
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.refreshPublisher = publisher
            return publisher

        }
    }

    private func anonymousValidToken(deviceId: String, forceRefresh: Bool = false) -> AnyPublisher<AuthToken, Error> {
        return queue.sync { [weak self] in

            var shouldForceRefresh = forceRefresh

            // We're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // We don't have a token so we override the forceRefresh
            if let selfValue = self, selfValue.currentToken == nil {
                shouldForceRefresh = true
            }

            // We already have a valid token and don't want to force a refresh
            if let selfValue = self, let token = selfValue.currentToken, token.isValid, !shouldForceRefresh {
                return Just(token).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            guard let weakSelf = self else { return Fail(error: NetworkErrorCode.invalidRequest).eraseToAnyPublisher() }

            // We need a new token
            var request = URLRequest(url: weakSelf.anonymousEndpointURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let bodyJSON = [
                "device_uuid": deviceId,
                "device_type": "ios",
                "type": "anonymous",
                "device_token": Env.deviceFCMToken
            ]

            let jsonData = try! JSONEncoder().encode(bodyJSON) // swiftlint:disable:this force_try
            request.httpBody = jsonData

            let publisher = session.publisher(for: request, token: nil)
                .share()
                .decode(type: AuthToken.self, decoder: JSONDecoder())
                .handleEvents(receiveOutput: { token in
                    self?.currentToken = token
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.refreshPublisher = publisher
            return publisher

        }
    }

}
