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

    /// SSE manager for streaming requests
    private let sseManager: SSEManager
    
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
        self.sseManager = SSEManager(session: session, decoder: decoder)
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

    /// Make authenticated SSE streaming request with automatic retry on auth errors
    /// - Parameters:
    ///   - endpoint: The endpoint to request
    ///   - decodingType: Type to decode from SSE JSON data
    /// - Returns: Publisher emitting SSE events or error
    func requestSSE<T: Decodable>(
        _ endpoint: Endpoint,
        decodingType: T.Type
    ) -> AnyPublisher<SSEEvent<T>, ServiceProviderError> {
        print("[EveryMatrix-\(apiIdentifier)] Preparing SSE request for endpoint: \(endpoint.endpoint)")

        // Build URL components
        guard var components = URLComponents(string: endpoint.url + endpoint.endpoint) else {
            return Fail(error: ServiceProviderError.errorMessage(message: "Invalid URL")).eraseToAnyPublisher()
        }

        // Add query parameters
        components.queryItems = endpoint.query

        guard let url = components.url else {
            return Fail(error: ServiceProviderError.errorMessage(message: "Invalid URL")).eraseToAnyPublisher()
        }

        // Build base headers
        var headers = endpoint.headers ?? [:]

        // Check if endpoint requires authentication
        if endpoint.requireSessionKey {
            // Get valid token and make SSE request with retry logic
            return sessionCoordinator.publisherWithValidToken()
                .flatMap { [weak self] session -> AnyPublisher<SSEEvent<T>, Error> in
                    guard let self = self else {
                        return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                    }

                    print("[EveryMatrix-\(self.apiIdentifier)] Using session token for authenticated SSE request")

                    // Add authentication headers
                    var authenticatedHeaders = headers
                    self.addAuthenticationHeadersToDict(&authenticatedHeaders, session: session, endpoint: endpoint)

                    print("📡 SSE Request: \(url.absoluteString)")
                    print("📡 SSE Headers: \(authenticatedHeaders)")

                    // Make SSE request via SSEManager
                    return self.sseManager.subscribe(
                        url: url,
                        headers: authenticatedHeaders,
                        decodingType: decodingType,
                        timeout: endpoint.timeout
                    )
                    .mapError { error -> Error in
                        // Map EveryMatrix.APIError to Error
                        switch error {
                        case .requestError(let value):
                            return ServiceProviderError.errorMessage(message: value)
                        case .decodingError(let value):
                            return ServiceProviderError.decodingError(message: value)
                        case .notConnected:
                            return ServiceProviderError.errorMessage(message: "Not connected")
                        case .noResultsReceived:
                            return ServiceProviderError.errorMessage(message: "No results received")
                        default:
                            return ServiceProviderError.errorMessage(message: error.localizedDescription)
                        }
                    }
                    .eraseToAnyPublisher()
                }
                .mapError { error -> ServiceProviderError in
                    // Convert Error to ServiceProviderError
                    if let serviceError = error as? ServiceProviderError {
                        return serviceError
                    }
                    return ServiceProviderError.errorMessage(message: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        } else {
            // No authentication required, make direct SSE request
            print("[EveryMatrix-\(apiIdentifier)] Making unauthenticated SSE request")

            print("📡 SSE Request: \(url.absoluteString)")
            print("📡 SSE Headers: \(headers)")

            return sseManager.subscribe(
                url: url,
                headers: headers,
                decodingType: decodingType,
                timeout: endpoint.timeout
            )
            .mapError { error -> ServiceProviderError in
                // Map EveryMatrix.APIError to ServiceProviderError
                switch error {
                case .requestError(let value):
                    return ServiceProviderError.errorMessage(message: value)
                case .decodingError(let value):
                    return ServiceProviderError.decodingError(message: value)
                case .notConnected:
                    return ServiceProviderError.errorMessage(message: "Not connected")
                case .noResultsReceived:
                    return ServiceProviderError.errorMessage(message: "No results received")
                default:
                    return ServiceProviderError.errorMessage(message: error.localizedDescription)
                }
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

    /// Add authentication headers to dictionary (for SSE requests)
    private func addAuthenticationHeadersToDict(_ headers: inout [String: String],
                                               session: EveryMatrixSessionResponse,
                                               endpoint: Endpoint) {
        // Add session token header
        if let sessionIdKey = endpoint.authHeaderKey(for: .sessionId) {
            headers[sessionIdKey] = session.sessionId
            print("[EveryMatrix-\(apiIdentifier)] Added session token with key: \(sessionIdKey)")
        } else {
            // Default header for session token
            headers["X-SessionId"] = session.sessionId
        }

        // Add user ID header if needed
        if let userIdKey = endpoint.authHeaderKey(for: .userId) {
            headers[userIdKey] = session.userId
            print("[EveryMatrix-\(apiIdentifier)] Added user ID with key: \(userIdKey)")
        }

        // Special handling for Casino API (uses Cookie header)
        if apiIdentifier == "Casino" {
            headers["Cookie"] = "sessionId=\(session.sessionId)"
            print("[EveryMatrix-\(apiIdentifier)] Added session as Cookie header")
        }
    }

    /// Perform HTTP request and handle response
    private func performRequest(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        print("[EveryMatrix-\(apiIdentifier)] Performing request: \(request.url?.absoluteString ?? "unknown")")

        // Log request body for debugging
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("[EveryMatrix-\(apiIdentifier)] 📤 Request body: \(bodyString)")
        }

        // Log headers for debugging
        if let headers = request.allHTTPHeaderFields {
            print("[EveryMatrix-\(apiIdentifier)] 📋 Request headers: \(headers)")
        }

        print("============ \n [EveryMatrix-\(apiIdentifier)] cURL Command:")
        print(request.cURL(pretty: true))
        print("============\n")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] result in
                guard let self = self else {
                    throw ServiceProviderError.unknown
                }

                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw ServiceProviderError.invalidResponse
                }

                print("[EveryMatrix-\(self.apiIdentifier)] Response status code: \(httpResponse.statusCode)")

                // Log response body for debugging
                if let responseString = String(data: result.data, encoding: .utf8) {
                    print("[EveryMatrix-\(self.apiIdentifier)] 📥 Response body: \(responseString)")
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
                    print("[EveryMatrix-\(self.apiIdentifier)] Received 401 Unauthorized")
                    throw ServiceProviderError.unauthorized

                case 403:
                    // EveryMatrix often returns 403 for expired sessions
                    print("[EveryMatrix-\(self.apiIdentifier)] Received 403 Forbidden (likely expired session)")
                    throw ServiceProviderError.forbidden

                case 404:
                    print("[EveryMatrix-\(self.apiIdentifier)] ❌ 404 Not Found")
                    throw ServiceProviderError.notFound

                case 409:
                    // 409 Conflict - usually duplicate bet or validation error
                    print("[EveryMatrix-\(self.apiIdentifier)] ⚠️ 409 Conflict - Possible duplicate bet or validation error")
                    if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                        let errorMessage = apiError.thirdPartyResponse?.message ?? apiError.error ?? "Conflict Error"
                        print("[EveryMatrix-\(self.apiIdentifier)] 409 Error message: \(errorMessage)")
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
                    print("[EveryMatrix-\(self.apiIdentifier)] ❌ Unexpected status code: \(httpResponse.statusCode)")
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

