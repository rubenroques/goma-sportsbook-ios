import Foundation
import Combine
import LDSwiftEventSource

/// Connector for Server-Sent Events (SSE) streaming using LDSwiftEventSource
/// Used for real-time updates (cashout values, wallet updates, user session events)
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

    /// JSON decoder
    private let decoder: JSONDecoder

    // MARK: - Initialization

    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         decoder: JSONDecoder = JSONDecoder()) {
        self.sessionCoordinator = sessionCoordinator
        self.decoder = decoder
    }

    // MARK: - Public Methods

    /// Make SSE streaming request with automatic authentication
    /// - Parameters:
    ///   - endpoint: The endpoint to stream from
    ///   - decodingType: The type to decode SSE messages to
    /// - Returns: Publisher emitting SSEStreamEvent or error
    func request<T: Decodable>(_ endpoint: Endpoint, decodingType: T.Type) -> AnyPublisher<SSEStreamEvent, ServiceProviderError> {

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
                .flatMap { [weak self] session -> AnyPublisher<SSEStreamEvent, Error> in
                    guard let self = self else {
                        return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                    }

                    print("[EveryMatrix-SSE] Using session token for authenticated SSE request")

                    // Add authentication headers
                    var authenticatedHeaders = headers
                    authenticatedHeaders = self.addAuthenticationHeaders(to: authenticatedHeaders, session: session, endpoint: endpoint)

                    print("📡 SSE Request: \(url.absoluteString)")
                    print("📡 SSE Headers: \(authenticatedHeaders)")

                    // Create EventSource with LDSwiftEventSource
                    return self.createEventSource(
                        url: url,
                        headers: authenticatedHeaders,
                        timeout: endpoint.timeout,
                        decodingType: decodingType
                    )
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

            return createEventSource(
                url: url,
                headers: headers,
                timeout: endpoint.timeout,
                decodingType: decodingType
            )
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

    /// Create and configure LDSwiftEventSource EventSource
    private func createEventSource<T: Decodable>(
        url: URL,
        headers: [String: String],
        timeout: TimeInterval,
        decodingType: T.Type
    ) -> AnyPublisher<SSEStreamEvent, Error> {

        // Create adapter for event handling
        let adapter = SSEEventHandlerAdapter<T>(decoder: decoder)

        // Configure EventSource
        var config = EventSource.Config(handler: adapter, url: url)
        config.method = "GET"
        config.headers = headers
        config.idleTimeout = timeout

        // Create EventSource
        let eventSource = EventSource(config: config)
        adapter.setEventSource(eventSource)

        print("🚀 SSEConnector: Starting EventSource connection")
        eventSource.start()

        // Return publisher with cleanup on cancellation
        return adapter.subject
            .mapError { $0 as Error }
            .handleEvents(
                receiveCancel: { [weak adapter] in
                    print("🛑 SSEConnector: Subscription cancelled, stopping EventSource")
                    adapter?.stop()
                }
            )
            .eraseToAnyPublisher()
    }

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
