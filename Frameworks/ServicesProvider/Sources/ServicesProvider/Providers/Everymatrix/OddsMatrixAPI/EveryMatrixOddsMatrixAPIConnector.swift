//
//  EveryMatrixOddsMatrixAPIConnector.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine

class EveryMatrixOddsMatrixAPIConnector: Connector {
    // Connection state management
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> { connectionStateSubject.eraseToAnyPublisher() }

    // Session token management
    private var sessionToken: String?
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private var cancellables: Set<AnyCancellable> = []

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Session Token Management
    
    func saveSessionToken(_ token: String) {
        self.sessionToken = token
    }
    
    func clearSessionToken() {
        self.sessionToken = nil
    }
    
    private func retrieveSessionToken() -> String? {
        return self.sessionToken
    }

    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        
        // Check if session token is required
        var additionalHeaders: HTTP.Headers?
        if endpoint.requireSessionKey {
            if let sessionToken = self.retrieveSessionToken() {
                additionalHeaders = ["X-SessionId": sessionToken]
            } else {
                return Fail(error: ServiceProviderError.unauthorized).eraseToAnyPublisher()
            }
        }
        
        // Build URLRequest using the Endpoint protocol
        guard let request = endpoint.request(aditionalHeaders: additionalHeaders) else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
        return performRequest(request)
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, ServiceProviderError> {
        return session.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                // Handle HTTP status codes
                if let httpResponse = result.response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200, 201:
                        return result.data
                    case 401:
                        throw ServiceProviderError.unauthorized
                    case 403:
                        throw ServiceProviderError.forbidden
                    case 404:
                        throw ServiceProviderError.notSupportedForProvider
                    case 500...599:
                        // Try to decode the error body if available
                        if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                            let errorMessage = apiError.thirdPartyResponse?.message ?? "Server Error"
                            throw ServiceProviderError.errorMessage(message: errorMessage)
                        } else {
                            throw ServiceProviderError.internalServerError
                        }
                    default:
                        throw ServiceProviderError.unknown
                    }
                }
                return result.data
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .flatMap { [weak self] data -> AnyPublisher<T, ServiceProviderError> in
                guard let self = self else {
                    return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                }
                
                do {
                    let decodedObject = try self.decoder.decode(T.self, from: data)
                    return Just(decodedObject)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                } catch {
                    if error is DecodingError {
                        return Fail(error: ServiceProviderError.decodingError(message: error.localizedDescription))
                            .eraseToAnyPublisher()
                    }
                    return Fail(error: ServiceProviderError.invalidResponse)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
} 
