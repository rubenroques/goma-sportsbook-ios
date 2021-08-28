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

    // This publisher is shared amongst all calls that request a token refresh
    private var refreshPublisher: AnyPublisher<AuthToken, Error>?

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func validToken(deviceId: String, forceRefresh: Bool = false) -> AnyPublisher<AuthToken, Error> {
        return queue.sync { [weak self] in

            var shouldForceRefresh = forceRefresh

            // We're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // We don't have a token so we override the forceRefresh
            if let selfValue = self, selfValue.currentToken != nil {
                shouldForceRefresh = true
            }

            // We already have a valid token and don't want to force a refresh
            if let selfValue = self, let token = selfValue.currentToken, token.isValid, !shouldForceRefresh {
                return Just(token).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            // We need a new token
            let endpointURL = URL(string: "http://34.141.102.89/api/v1/auth")!

            var request = URLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let bodyJSON = [
                "device_uuid": deviceId,
                "device_type": "ios",
                "type": "anonymous"
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
