//
//  EveryMatrixAPIConnector.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation
import Combine

class EveryMatrixPlayerAPIConnector: Connector {
    // Token/session management
    var token: CurrentValueSubject<String?, Never> = .init(nil)
    var tokenPublisher: AnyPublisher<String?, Never> { token.eraseToAnyPublisher() }
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> { connectionStateSubject.eraseToAnyPublisher() }

    private let session: URLSession
    private let decoder: JSONDecoder
    private var cancellables: Set<AnyCancellable> = []

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        
        // Build URLRequest using the Endpoint protocol
        guard let request = endpoint.request() else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
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
                        throw ServiceProviderError.internalServerError
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
