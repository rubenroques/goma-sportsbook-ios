//
//  EveryMatrixBaseConnector.swift
//  ServicesProvider
//
//  Base connector with automatic token refresh for EveryMatrix APIs
//

import Foundation
import Combine

/// Base connector for all EveryMatrix API clients
/// Provides transparent token refresh on 401/403 errors
class EveryMatrixBaseConnector: Connector {
    
    // MARK: - Properties
    
    /// Connection state management
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    
    /// Session coordinator for token management
    let sessionCoordinator: EveryMatrixSessionCoordinator
    
    /// URLSession for API requests
    private let session: URLSession
    
    /// JSON decoder
    private let decoder: JSONDecoder
    
    /// API type identifier for logging
    private let apiIdentifier: String
    
    // MARK: - Helpers
    
    /// Get current session token
    var sessionToken: String? {
        return sessionCoordinator.getSessionToken()
    }
    
    /// Get current user ID
    var userId: String? {
        return sessionCoordinator.getUserId()
    }
    
    /// Clear session data
    func clearSession() {
        sessionCoordinator.clearSession()
    }
    
    //
    // MARK: - Initialization
    
    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         apiIdentifier: String,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.sessionCoordinator = sessionCoordinator
        self.apiIdentifier = apiIdentifier
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Public Methods
    
    /// Make authenticated request with automatic retry on auth errors
    /// - Parameter endpoint: The endpoint to request
    /// - Returns: Publisher emitting decoded response or error
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        print("[EveryMatrix-\(apiIdentifier)] Preparing request for endpoint: \(endpoint.endpoint)")
        
        // Build base request
        guard var request = endpoint.request() else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
        // Set connection close header to avoid connection issues
        request.setValue("close", forHTTPHeaderField: "Connection")
        
        // Check if endpoint requires authentication
        if endpoint.requireSessionKey {
            // Get valid token and make request with retry logic
            return sessionCoordinator.publisherWithValidToken()
                .flatMap { [weak self] session -> AnyPublisher<Data, Error> in
                    guard let self = self else {
                        return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                    }
                    
                    print("[EveryMatrix-\(self.apiIdentifier)] Using session token for authenticated request")
                    
                    // Add authentication headers
                    var authenticatedRequest = request
                    self.addAuthenticationHeaders(to: &authenticatedRequest, session: session, endpoint: endpoint)
                    
                    // Make request
                    return self.performRequest(authenticatedRequest)
                }
                .tryCatch { [weak self] error -> AnyPublisher<Data, Error> in
                    guard let self = self else {
                        throw ServiceProviderError.unknown
                    }
                    
                    print("[EveryMatrix-\(self.apiIdentifier)] Error encountered: \(error)")
                    
                    // Check if error is auth-related (401 or 403)
                    guard let serviceError = error as? ServiceProviderError,
                          (serviceError == .unauthorized || serviceError == .forbidden) else {
                        // Not an auth error, propagate it
                        throw error
                    }
                    
                    print("[EveryMatrix-\(self.apiIdentifier)] Auth error detected, attempting token refresh...")
                    
                    // Force token refresh and retry
                    return self.sessionCoordinator.publisherWithValidToken(forceRefresh: true)
                        .flatMap { session -> AnyPublisher<Data, Error> in
                            print("[EveryMatrix-\(self.apiIdentifier)] Token refreshed, retrying request")
                            
                            // Add new authentication headers
                            var retriedRequest = request
                            self.addAuthenticationHeaders(to: &retriedRequest, session: session, endpoint: endpoint)
                            
                            // Retry request with new token
                            return self.performRequest(retriedRequest)
                        }
                        .eraseToAnyPublisher()
                }
                .tryMap { [weak self] data in
                    guard let self = self else {
                        throw ServiceProviderError.unknown
                    }
                    
                    print("[EveryMatrix-\(self.apiIdentifier)] Decoding response data...")
                    
                    do {
                        return try self.decoder.decode(T.self, from: data)
                    } catch let decodingError {
                        print("[EveryMatrix-\(self.apiIdentifier)] Decoding error: \(decodingError)")
                        print("[EveryMatrix-\(self.apiIdentifier)] Response data: \(String(data: data, encoding: .utf8) ?? "Invalid")")
                        throw ServiceProviderError.decodingError(message: decodingError.localizedDescription)
                    }
                }
                .mapError { error -> ServiceProviderError in
                    if let serviceError = error as? ServiceProviderError {
                        return serviceError
                    }
                    return ServiceProviderError.errorMessage(message: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        } else {
            // No authentication required, make direct request
            print("[EveryMatrix-\(apiIdentifier)] Making unauthenticated request")
            
            return performRequest(request)
                .tryMap { [weak self] data in
                    guard let self = self else {
                        throw ServiceProviderError.unknown
                    }
                    
                    return try self.decoder.decode(T.self, from: data)
                }
                .mapError { error -> ServiceProviderError in
                    if let serviceError = error as? ServiceProviderError {
                        return serviceError
                    }
                    return ServiceProviderError.errorMessage(message: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Private Methods
    
    /// Add authentication headers to request
    private func addAuthenticationHeaders(to request: inout URLRequest,
                                         session: EveryMatrixSessionResponse,
                                         endpoint: Endpoint) {
        // Add session token header
        if let sessionIdKey = endpoint.authHeaderKey(for: .sessionId) {
            request.setValue(session.sessionId, forHTTPHeaderField: sessionIdKey)
            print("[EveryMatrix-\(apiIdentifier)] Added session token with key: \(sessionIdKey)")
        } else {
            // Default header for session token
            request.setValue(session.sessionId, forHTTPHeaderField: "X-SessionId")
        }
        
        // Add user ID header if needed
        if let userIdKey = endpoint.authHeaderKey(for: .userId) {
            request.setValue(session.userId, forHTTPHeaderField: userIdKey)
            print("[EveryMatrix-\(apiIdentifier)] Added user ID with key: \(userIdKey)")
        }
        
        // Special handling for Casino API (uses Cookie header)
        if apiIdentifier == "Casino" {
            request.setValue("sessionId=\(session.sessionId)", forHTTPHeaderField: "Cookie")
            print("[EveryMatrix-\(apiIdentifier)] Added session as Cookie header")
        }
    }
    
    /// Perform HTTP request and handle response
    private func performRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        print("[EveryMatrix-\(apiIdentifier)] Performing request: \(request.url?.absoluteString ?? "unknown")")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] result in
                guard let self = self else {
                    throw ServiceProviderError.unknown
                }
                
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw ServiceProviderError.invalidResponse
                }
                
                print("[EveryMatrix-\(self.apiIdentifier)] Response status code: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    return result.data
                    
                case 401:
                    print("[EveryMatrix-\(self.apiIdentifier)] Received 401 Unauthorized")
                    throw ServiceProviderError.unauthorized
                    
                case 403:
                    // EveryMatrix often returns 403 for expired sessions
                    print("[EveryMatrix-\(self.apiIdentifier)] Received 403 Forbidden (likely expired session)")
                    throw ServiceProviderError.forbidden
                    
                case 404:
                    throw ServiceProviderError.notFound
                    
                case 429:
                    throw ServiceProviderError.rateLimitExceeded
                    
                case 500...599:
                    // Try to decode error message
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.thirdPartyResponse?.message ?? "Server Error"
                        throw ServiceProviderError.errorMessage(message: errorMessage)
                    }
                    throw ServiceProviderError.internalServerError
                    
                default:
                    throw ServiceProviderError.unknown
                }
            }
            .mapError { error -> Error in
                // Check for network errors
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    self.connectionStateSubject.send(.disconnected)
                    return ServiceProviderError.noNetworkConnection
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}

