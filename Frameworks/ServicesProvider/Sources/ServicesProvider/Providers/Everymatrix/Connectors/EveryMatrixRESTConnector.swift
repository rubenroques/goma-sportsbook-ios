import Foundation
import Combine
import GomaPerformanceKit

/// Base connector for all EveryMatrix API clients
/// Provides transparent token refresh on 401/403 errors
class EveryMatrixRESTConnector: Connector {
    
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
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.sessionCoordinator = sessionCoordinator
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Public Methods
    
    /// Make authenticated request with automatic retry on auth errors
    /// - Parameter endpoint: The endpoint to request
    /// - Returns: Publisher emitting decoded response or error
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        print("[EveryMatrix-REST api] Preparing request for endpoint: \(endpoint.endpoint)")

        // Get performance feature from endpoint (nil if not tracked)
        let feature = endpoint.performanceFeature

        // Start performance tracking if feature exists
        if let feature = feature {
            PerformanceTracker.shared.start(
                feature: feature,
                layer: .api,
                metadata: [
                    "endpoint": endpoint.endpoint,
                    "method": endpoint.method.value()
                ]
            )
        }

        // Build base request
        guard var request = endpoint.request() else {
            // End tracking on error if tracking was started
            if let feature = feature {
                PerformanceTracker.shared.end(
                    feature: feature,
                    layer: .api,
                    metadata: [
                        "status": "error",
                        "error": "Invalid request format"
                    ]
                )
            }
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
                    
                    print("[EveryMatrix-REST api] Using session token for authenticated request")
                    
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
                    
                    print("[EveryMatrix-REST api] Error encountered: \(error)")
                    
                    // Check if error is auth-related (401 or 403)
                    guard let serviceError = error as? ServiceProviderError,
                          (serviceError == .unauthorized || serviceError == .forbidden) else {
                        // Not an auth error, propagate it
                        throw error
                    }
                    
                    print("[EveryMatrix-REST api] Auth error detected, attempting token refresh...")
                    
                    // Force token refresh and retry
                    return self.sessionCoordinator.publisherWithValidToken(forceRefresh: true)
                        .flatMap { session -> AnyPublisher<Data, Error> in
                            print("[EveryMatrix-REST api] Token refreshed, retrying request")
                            
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

                    print("[EveryMatrix-REST api] Decoding response data...")

                    // Start parsing tracking
                    if let feature = feature {
                        PerformanceTracker.shared.start(
                            feature: feature,
                            layer: .parsing,
                            metadata: ["type": "json_decode"]
                        )
                    }

                    do {
                        let result = try self.decoder.decode(T.self, from: data)

                        // End parsing tracking - success
                        if let feature = feature {
                            PerformanceTracker.shared.end(
                                feature: feature,
                                layer: .parsing,
                                metadata: ["status": "success"]
                            )
                        }

                        return result
                    } catch let decodingError {
                        print("[EveryMatrix-REST api] Decoding error: \(decodingError)")
                        print("[EveryMatrix-REST api] Response data: \(String(data: data, encoding: .utf8) ?? "Invalid")")

                        // End parsing tracking - error
                        if let feature = feature {
                            PerformanceTracker.shared.end(
                                feature: feature,
                                layer: .parsing,
                                metadata: [
                                    "status": "error",
                                    "error": decodingError.localizedDescription
                                ]
                            )
                        }

                        throw ServiceProviderError.decodingError(message: decodingError.localizedDescription)
                    }
                }
                .mapError { error -> ServiceProviderError in
                    if let serviceError = error as? ServiceProviderError {
                        return serviceError
                    }
                    return ServiceProviderError.errorMessage(message: error.localizedDescription)
                }
                .handleEvents(
                    receiveOutput: { _ in
                        // End tracking on success
                        if let feature = feature {
                            PerformanceTracker.shared.end(
                                feature: feature,
                                layer: .api,
                                metadata: ["status": "success"]
                            )
                        }
                    },
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            // End tracking on error
                            if let feature = feature {
                                PerformanceTracker.shared.end(
                                    feature: feature,
                                    layer: .api,
                                    metadata: [
                                        "status": "error",
                                        "error": error.localizedDescription
                                    ]
                                )
                            }
                        }
                    }
                )
                .eraseToAnyPublisher()
        } else {
            // No authentication required, make direct request
            print("[EveryMatrix-REST api] Making unauthenticated request")

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
                .handleEvents(
                    receiveOutput: { _ in
                        // End tracking on success
                        if let feature = feature {
                            PerformanceTracker.shared.end(
                                feature: feature,
                                layer: .api,
                                metadata: ["status": "success"]
                            )
                        }
                    },
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            // End tracking on error
                            if let feature = feature {
                                PerformanceTracker.shared.end(
                                    feature: feature,
                                    layer: .api,
                                    metadata: [
                                        "status": "error",
                                        "error": error.localizedDescription
                                    ]
                                )
                            }
                        }
                    }
                )
                .eraseToAnyPublisher()
        }
    }

    /// Make authenticated SSE streaming request with automatic retry on auth errors
    /// - Parameters:
    ///   - endpoint: The endpoint to request
    ///   - decodingType: Type to decode from SSE JSON data
    /// - Returns: Publisher emitting SSE events or error
    // MARK: - Private Methods
    
    /// Add authentication headers to request
    private func addAuthenticationHeaders(to request: inout URLRequest,
                                         session: EveryMatrixSessionResponse,
                                         endpoint: Endpoint) {
        // Add session token header
        if let sessionIdKey = endpoint.authHeaderKey(for: .sessionId) {
            request.setValue(session.sessionId, forHTTPHeaderField: sessionIdKey)
            print("[EveryMatrix-REST api] Added session token with key: \(sessionIdKey)")
        } else {
            // Default header for session token
            request.setValue(session.sessionId, forHTTPHeaderField: "X-SessionId")
        }
        
        // Add user ID header if needed
        if let userIdKey = endpoint.authHeaderKey(for: .userId) {
            request.setValue(session.userId, forHTTPHeaderField: userIdKey)
            print("[EveryMatrix-REST api] Added user ID with key: \(userIdKey)")
        }

    }

    /// Perform HTTP request and handle response
    private func performRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        print("[EveryMatrix-REST api] Performing request: \(request.url?.absoluteString ?? "unknown")")

        // Log request body for debugging
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("[EveryMatrix-REST api] 📤 Request body: \(bodyString)")
        }

        // Log headers for debugging
        if let headers = request.allHTTPHeaderFields {
            print("[EveryMatrix-REST api] 📋 Request headers: \(headers)")
        }

        print("\n============ \n [EveryMatrix-REST api] cURL Command:")
        print(request.cURL(pretty: true))
        print("============\n")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] result in
                
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw ServiceProviderError.invalidResponse
                }

                // print("[EveryMatrix-REST api] Response status code: \(httpResponse.statusCode)")

                // Log response body for debugging
                if let responseString = String(data: result.data, encoding: .utf8) {
                    // print("[EveryMatrix-REST api] 📥 Response body: \(responseString)")
                }

                switch httpResponse.statusCode {
                case 200...299:
                    return result.data
                case 400:
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.thirdPartyResponse?.message ?? "Invalid Request"
                        throw ServiceProviderError.errorMessage(message: errorMessage)
                    }
                    throw ServiceProviderError.badRequest
                case 401:
                    print("[EveryMatrix-REST api] Received 401 Unauthorized")
                    throw ServiceProviderError.unauthorized

                case 403:
                    // EveryMatrix often returns 403 for expired sessions
                    print("[EveryMatrix-REST api] Received 403 Forbidden (likely expired session)")
                    throw ServiceProviderError.forbidden

                case 404:
                    print("[EveryMatrix-REST api] ❌ 404 Not Found")
                    throw ServiceProviderError.notFound

                case 409:
                    // 409 Conflict - usually duplicate bet or validation error
                    print("[EveryMatrix-REST api] ⚠️ 409 Conflict - Possible duplicate bet or validation error")
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.thirdPartyResponse?.message ?? apiError.error ?? "Conflict Error"
                        print("[EveryMatrix-REST api] 409 Error message: \(errorMessage)")
                        throw ServiceProviderError.errorMessage(message: errorMessage)
                    }
                    throw ServiceProviderError.errorMessage(message: "Bet already placed or validation error")
                case 424:
                    // Try to decode error message
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.error ?? "Server Error"
                        throw ServiceProviderError.errorMessage(message: errorMessage)
                    }
                    throw ServiceProviderError.errorMessage(message: "Token invalid")
                case 429:
                    throw ServiceProviderError.rateLimitExceeded

                case 500...599:
                    // Try to decode error message
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.thirdPartyResponse?.mappedErrorCode ?? "Server Error"
                        throw ServiceProviderError.errorMessage(message: errorMessage)
                    }
                    throw ServiceProviderError.internalServerError

                default:
                    print("[EveryMatrix-REST api] ❌ Unexpected status code: \(httpResponse.statusCode)")
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
