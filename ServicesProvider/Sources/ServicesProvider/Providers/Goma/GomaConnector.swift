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
    
    enum CodingKeys: String, CodingKey {
        case hash = "token"
        case type = "type"
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
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default),
         decoder: JSONDecoder = JSONDecoder(),
         deviceIdentifier: String) {
        
        self.session = session
        self.decoder = decoder
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 2003-12-31 00:00:00
        self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        self.authenticator = GomaAPIAuthenticator(deviceIdentifier: deviceIdentifier)
    }
    
    func clearToken() {
        self.authenticator.updateToken(newToken: nil)
    }
    
    func updateToken(newToken: String) {
        self.authenticator.updateToken(newToken: newToken)
    }
    
    func updateCredentials(credentials: GomaUserCredentials?) {
        self.authenticator.updateCredentials(credentials: credentials)
    }
    
    func getPushNotificationToken() -> String? {
        return self.authenticator.pushNotificationsToken
    }
    func updatePushNotificationToken(newToken: String?) {
        self.authenticator.updatePushNotificationToken(newToken: newToken)
    }
    
    func request<T: Codable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        
        guard
            var request = endpoint.request()
        else {
            let error = ServiceProviderError.invalidRequestFormat
            return Fail<T, ServiceProviderError>(error: error).eraseToAnyPublisher()
        }
        
        return self.authenticator.publisherWithValidToken()
            .flatMap { token -> AnyPublisher<Data, Error> in
                request.setValue("Bearer \(token.hash)", forHTTPHeaderField: "Authorization")
                return self.publisher(for: request, token: token).eraseToAnyPublisher()
            }
            .tryCatch { error -> AnyPublisher<Data, Error> in
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
                do {
                    return try self.decoder.decode(T.self, from: data)
                } catch let error as DecodingError {
                    // Handle DecodingError by printing the expected and received JSON
                    print("Decoding Error: \(error)")
                    print("Received JSON: \(String(data: data, encoding: .utf8) ?? "Invalid JSON")")
                    throw error
                } catch {
                    // Propagate other errors
                    throw error
                }
            })
            .mapError({ error -> ServiceProviderError in
                if let typedError = error as? ServiceProviderError {
                    return typedError
                }
                else if let decodingError = error as? DecodingError {
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
        
        var request = request
        if let token = token {
            request.setValue("Bearer \(token.hash)", forHTTPHeaderField: "Authorization")
        }
        else {
            print("Error Authorization token not found.")
        }
        
        print("GomaGaming URL Request: \n", request.cURL(pretty: true), "\n==========================================")
        
        return self.session.dataTaskPublisher(for: request)
            .tryMap { urlSessionOutput in
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
                    if let messageResponse = try? JSONDecoder().decode(ErrorResponse.self, from: urlSessionOutput.data) {
                        throw ServiceProviderError.errorMessage(message: messageResponse.message)
                    }
                    throw ServiceProviderError.unknown
                case 422:
                    if let messageResponse = try? JSONDecoder().decode(ErrorResponse.self, from: urlSessionOutput.data) {
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
