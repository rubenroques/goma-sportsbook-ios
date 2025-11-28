import Foundation
import Combine
import GomaPerformanceKit
import GomaLogger

class EveryMatrixCasinoConnector {
    
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
        GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Preparing request for endpoint: \(endpoint.endpoint)")

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
                    
                    GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Using session token for authenticated request")
                    
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
                    
                    GomaLogger.error(.networking, category: "EM_REST_CASINO", "Error encountered: \(error)")
                    
                    // Check if error is auth-related (401 or 403)
                    guard let serviceError = error as? ServiceProviderError,
                          (serviceError == .unauthorized || serviceError == .forbidden) else {
                        // Not an auth error, propagate it
                        throw error
                    }
                    
                    GomaLogger.info(.networking, category: "EM_REST_CASINO", "Auth error detected, attempting token refresh...")
                    
                    // Force token refresh and retry
                    return self.sessionCoordinator.publisherWithValidToken(forceRefresh: true)
                        .flatMap { session -> AnyPublisher<Data, Error> in
                            GomaLogger.info(.networking, category: "EM_REST_CASINO", "Token refreshed, retrying request")
                            
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

                    GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Checking for error response...")

                    // Pre-parse check for Casino API error codes (e.g., 4004 InvalidXSessionId)
                    // Casino API returns HTTP 200 with error details in body instead of 401/403
                    if let errorCheck = try? self.decoder.decode(EveryMatrix.CasinoAPIErrorCheck.self, from: data),
                       errorCheck.success == false {
                        GomaLogger.error(.networking, category: "EM_REST_CASINO", "Detected API error: code=\(errorCheck.errorCode ?? 0), message=\(errorCheck.errorMessage ?? "unknown")")

                        // Check for InvalidXSessionId error (4004)
                        if errorCheck.errorCode == 4004 {
                            GomaLogger.error(.networking, category: "EM_REST_CASINO", "Error 4004 (InvalidXSessionId) detected - will trigger token refresh")
                            throw ServiceProviderError.unauthorized
                        }

                        // Other error codes
                        let errorMsg = errorCheck.errorMessage ?? "API Error \(errorCheck.errorCode ?? 0)"
                        throw ServiceProviderError.errorMessage(message: errorMsg)
                    }

                    GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Decoding response data...")

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
                        GomaLogger.error(.networking, category: "EM_REST_CASINO", "Decoding error: \(decodingError)")
                        GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Response data: \(String(data: data, encoding: .utf8) ?? "Invalid")")

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
            GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Making unauthenticated request")

            return performRequest(request)
                .tryMap { [weak self] data in
                    guard let self = self else {
                        throw ServiceProviderError.unknown
                    }

                    GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Decoding response data...")

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
                        GomaLogger.error(.networking, category: "EM_REST_CASINO", "Decoding error: \(decodingError)")
                        GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Response data: \(String(data: data, encoding: .utf8) ?? "Invalid")")

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
            GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Added session token with key: \(sessionIdKey)")
        } else {
            // Default header for session token
            request.setValue(session.sessionId, forHTTPHeaderField: "X-SessionId")
        }
        
        // Add user ID header if needed
        if let userIdKey = endpoint.authHeaderKey(for: .userId) {
            request.setValue(session.userId, forHTTPHeaderField: userIdKey)
            GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Added user ID with key: \(userIdKey)")
        }
    }

    /// Perform HTTP request and handle response
    private func performRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Performing request: \(request.url?.absoluteString ?? "unknown")")

        // Log request body for debugging
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Request body: \(bodyString)")
        }

        // Log headers for debugging
        if let headers = request.allHTTPHeaderFields {
            GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Request headers: \(headers)")
        }

        GomaLogger.debug(.networking, category: "EM_REST_CASINO", "cURL Command:\n\(request.cURL(pretty: true))")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] result in
                guard let self = self else {
                    throw ServiceProviderError.unknown
                }
                
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw ServiceProviderError.invalidResponse
                }
                
                GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Response status code: \(httpResponse.statusCode)")
                
                // Log response body for debugging
//                if let responseString = String(data: result.data, encoding: .utf8) {
//                    GomaLogger.debug(.networking, category: "EM_REST_CASINO", "Response body: \(responseString)")
//                }
                
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
                    GomaLogger.error(.networking, category: "EM_REST_CASINO", "Received 401 Unauthorized")
                    throw ServiceProviderError.unauthorized

                case 403:
                    // EveryMatrix often returns 403 for expired sessions
                    GomaLogger.error(.networking, category: "EM_REST_CASINO", "Received 403 Forbidden (likely expired session)")
                    throw ServiceProviderError.forbidden

                case 404:
                    GomaLogger.error(.networking, category: "EM_REST_CASINO", "404 Not Found")
                    throw ServiceProviderError.notFound

                case 409:
                    // 409 Conflict - usually duplicate bet or validation error
                    GomaLogger.error(.networking, category: "EM_REST_CASINO", "409 Conflict - Possible duplicate bet or validation error")
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.thirdPartyResponse?.message ?? apiError.error ?? "Conflict Error"
                        GomaLogger.error(.networking, category: "EM_REST_CASINO", "409 Error message: \(errorMessage)")
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
                        let errorMessage = apiError.thirdPartyResponse?.message ?? "Server Error"
                        throw ServiceProviderError.errorMessage(message: errorMessage)
                    }
                    throw ServiceProviderError.internalServerError
                    
                default:
                    GomaLogger.error(.networking, category: "EM_REST_CASINO", "Unexpected status code: \(httpResponse.statusCode)")
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
