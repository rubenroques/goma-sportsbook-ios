import Foundation
import Combine

/// Connector for Server-Sent Events (SSE) streaming
/// Used exclusively for real-time cashout value updates
class EveryMatrixSSEConnector: Connector {

    // MARK: - Properties

    /// Connection state management
    /// Note: SSE is stateless (request/response streaming), so always returns .connected
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    /// Session coordinator for token management
    let sessionCoordinator: EveryMatrixSessionCoordinator

    /// URLSession for SSE requests
    private let session: URLSession

    /// JSON decoder
    private let decoder: JSONDecoder

    /// SSE manager for streaming requests
    private let sseManager: SSEManager

    // MARK: - Initialization

    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        self.sessionCoordinator = sessionCoordinator
        self.session = session
        self.decoder = decoder
        self.sseManager = SSEManager(session: session, decoder: decoder)
    }

    // MARK: - Public Methods

    /// Make SSE streaming request with automatic authentication
    /// - Parameters:
    ///   - endpoint: The endpoint to stream from
    ///   - decodingType: The type to decode SSE messages to
    /// - Returns: Publisher emitting SSE events or error
    func request<T: Decodable>(_ endpoint: Endpoint, decodingType: T.Type) -> AnyPublisher<SSEEvent<T>, ServiceProviderError> {
        
        print("[EveryMatrix-SSE] Preparing SSE request for endpoint: \(endpoint.endpoint)")

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

                    print("[EveryMatrix-SSE] Using session token for authenticated SSE request")

                    // Add authentication headers
                    var authenticatedHeaders = headers
                    authenticatedHeaders = self.addAuthenticationHeaders(to: authenticatedHeaders, session: session, endpoint: endpoint)

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
            print("[EveryMatrix-SSE] Making unauthenticated SSE request")

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

    /// Add authentication headers and return updated headers dictionary
    private func addAuthenticationHeaders(to headers: [String: String],
                                          session: EveryMatrixSessionResponse,
                                          endpoint: Endpoint) -> [String: String] {
        var updatedHeaders = headers

        // Add session token header
        if let sessionIdKey = endpoint.authHeaderKey(for: .sessionId) {
            updatedHeaders[sessionIdKey] = session.sessionId
            print("[EveryMatrix-SSE] Added session token with key: \(sessionIdKey)")
        } else {
            // Default header for session token
            updatedHeaders["X-SessionId"] = session.sessionId
        }

        // Add user ID header if needed
        if let userIdKey = endpoint.authHeaderKey(for: .userId) {
            updatedHeaders[userIdKey] = session.userId
            print("[EveryMatrix-SSE] Added user ID with key: \(userIdKey)")
        }

        return updatedHeaders
    }
}
