//
//  File.swift
//
//
//  Created by Ruben Roques on 18/12/2023.
//

import Foundation
import Combine

struct GomaSessionAccessToken: Codable {
    var hash: String
    var type: String
    var expireTimestamp: Int?

    enum CodingKeys: String, CodingKey {
        case hash = "token"
        case type = "type"
        case expireTimestamp = "expires_at"
    }

}

struct GomaUserCredentials: Codable {
    var username: String
    var password: String
}

class GomaConnector: Connector {

    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return connectionStateSubject.eraseToAnyPublisher()
    }

    var authenticator: GomaAPIAuthenticator
    
    private static var defaultSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.waitsForConnectivity = true
        configuration.httpShouldUsePipelining = false
        return configuration
    }
    
    private static var defaultSession: URLSession {
        return URLSession(configuration: Self.defaultSessionConfiguration)
    }
    
    private let session: URLSession
    private let decoder: JSONDecoder

    convenience init(session: URLSession = GomaConnector.defaultSession,
         decoder: JSONDecoder = JSONDecoder(),
         deviceIdentifier: String) {

        self.init(session: session,
                  decoder: decoder,
                  gomaAPIAuthenticator: GomaAPIAuthenticator(deviceIdentifier: deviceIdentifier))
    }

    init(session: URLSession = GomaConnector.defaultSession,
         decoder: JSONDecoder = JSONDecoder(),
         gomaAPIAuthenticator: GomaAPIAuthenticator) {

        self.session = session
        self.decoder = decoder

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2003-12-31 00:00:00
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)

        self.authenticator = gomaAPIAuthenticator
    }

    func clearToken() {
        print("[GOMAAPI][DEBUG] Clearing token...")
        self.authenticator.updateToken(newToken: nil)
    }

    func updateToken(newToken: String) {
        print("[GOMAAPI][DEBUG] Updating token...")
        self.authenticator.updateToken(newToken: newToken)
    }

    func updateCredentials(credentials: GomaUserCredentials?) {
        print("[GOMAAPI][DEBUG] Updating credentials for user: \(credentials?.username ?? "unknown")")
        self.authenticator.updateCredentials(credentials: credentials)
    }

    func getPushNotificationToken() -> String? {
        return self.authenticator.pushNotificationsToken
    }
    func updatePushNotificationToken(newToken: String?) {
        self.authenticator.updatePushNotificationToken(newToken: newToken)
    }

    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        print("[GOMAAPI][DEBUG] Preparing request for endpoint: \(endpoint)")
        guard
            var request = endpoint.request()
        else {
            let error = ServiceProviderError.invalidRequestFormat
            return Fail<T, ServiceProviderError>(error: error).eraseToAnyPublisher()
        }
        
        request.setValue("close", forHTTPHeaderField: "Connection")

        return self.authenticator.publisherWithValidToken()
            .flatMap { token -> AnyPublisher<Data, Error> in
                print("[GOMAAPI][DEBUG] Received valid token: \(token.hash)")
                request.setValue("Bearer \(token.hash)", forHTTPHeaderField: "Authorization")
                return self.publisher(for: request, token: token).eraseToAnyPublisher()
            }
            .tryCatch { error -> AnyPublisher<Data, Error> in
                print("[GOMAAPI][DEBUG] Error encountered: \(error). Attempting token refresh...")
                // We only catch this error if it's a unauthorized
                guard
                    let serviceError = error as? ServiceProviderError,
                    serviceError == .unauthorized
                else {
                    throw error
                }
                // We only catch this error if it's an unauthorized
                return self.authenticator.publisherWithValidToken(forceRefresh: true)
                    .flatMap { token -> AnyPublisher<Data, Error> in
                        // We can now use this new token to authenticate the second attempt at making this request
                        request.setValue("Bearer \(token.hash)", forHTTPHeaderField: "Authorization")
                        return self.publisher(for: request, token: token).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .tryMap({ data in
                print("[GOMAAPI][DEBUG] Decoding data...")
                do {
                    return try self.decoder.decode(T.self, from: data)
                } catch let error as DecodingError {
                    // Handle DecodingError by printing the expected and received JSON
                    print("[GOMAAPI][DEBUG] Decoding Error: \(error)")
                    print("[GOMAAPI][DEBUG] Received JSON: \(String(data: data, encoding: .utf8) ?? "Invalid JSON")")
                    throw error
                } catch {
                    // Propagate other errors
                    throw error
                }
            })
            .mapError({ error -> ServiceProviderError in

                print("[GOMAAPI][DEBUG] Mapping error: \(error)")
                if let typedError = error as? ServiceProviderError {
                    print("[GOMAAPI][DEBUG] request: \(request)")
                    return typedError
                }
                else if let decodingError = error as? DecodingError {
                    print("[GOMAAPI][DEBUG] request: \(request)")

                    let errorMessage = "\(decodingError)"
                    return ServiceProviderError.decodingError(message: errorMessage)
                }
                return ServiceProviderError.invalidResponse
            })
            .eraseToAnyPublisher()
    }

    private func publisher(for url: URL, token: GomaSessionAccessToken?) -> AnyPublisher<Data, Error> {
        self.publisher(for: URLRequest(url: url), token: token)
    }

    private func publisher(for request: URLRequest, token: GomaSessionAccessToken?) -> AnyPublisher<Data, Error> {
        print("[GOMAAPI][DEBUG] Creating publisher for request: \(request.url?.absoluteString ?? "unknown URL")")
        var request = request
        if let token = token {
            request.setValue("Bearer \(token.hash)", forHTTPHeaderField: "Authorization")
        }
        else {
            print("[GOMAAPI][DEBUG] Error Authorization token not found.")
        }

        print("[GOMAAPI][DEBUG] GomaGaming URL Request: ", request.cURL(pretty: false), "\n==========================================")

        return self.session.dataTaskPublisher(for: request)
            .tryMap { urlSessionOutput in
                print("[GOMAAPI][DEBUG] Received response with status code: \((urlSessionOutput.response as? HTTPURLResponse)?.statusCode ?? -1)")
                guard let httpResponse = urlSessionOutput.response as? HTTPURLResponse else {
                    throw ServiceProviderError.invalidResponse
                }
                switch httpResponse.statusCode {
                case 200...299:
                    return urlSessionOutput.data
                case 401:
                    throw ServiceProviderError.unauthorized
                case 403:
                    throw ServiceProviderError.forbidden
                case 404:
                    if let messageResponse = try? JSONDecoder().decode(BasicMessageResponse.self, from: urlSessionOutput.data) {
                        throw ServiceProviderError.errorMessage(message: messageResponse.message)
                    }
                    throw ServiceProviderError.unknown
                case 422:
                    if let messageResponse = try? JSONDecoder().decode(BasicMessageResponse.self, from: urlSessionOutput.data) {
                        if messageResponse.message.lowercased().contains("does not allow selections") {
                            throw ServiceProviderError.notPlacedBet(message: messageResponse.message)
                        }
                        else {
                            throw ServiceProviderError.errorMessage(message: messageResponse.message)
                        }
                    }
                    throw ServiceProviderError.unknown
                case 500:
                    throw ServiceProviderError.internalServerError
                default:
                    throw ServiceProviderError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
