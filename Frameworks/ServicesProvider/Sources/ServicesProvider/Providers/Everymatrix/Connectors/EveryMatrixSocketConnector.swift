import Foundation
import Combine

class EveryMatrixSocketConnector: Connector {
    
    // MARK: - Properties
    private let wampManager: WAMPManager
    
    private var connectionCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    private let serialQueue = DispatchQueue(label: "com.goma.wamp.connector.queue")
    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.wampManager.connectionStatePublisher.map { wampConnectionState in
            switch wampConnectionState {
            case .connected: return ConnectorState.connected
            case .disconnected: return ConnectorState.disconnected
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(wampManager: WAMPManager = WAMPManager()) {
        self.wampManager = wampManager
        
        // self.setupNotificationHandling()
        
        self.connectionCancellable = self.wampManager.connectionStatePublisher
            .sink { [weak self] wampConnectionState in
                switch wampConnectionState {
                case .connected:
                    print("EveryMatrixConnector init wamp connected")
                case .disconnected:
                    print("EveryMatrixConnector init wamp disconnected")
                    self?.forceReconnect()
                }
            }
    }

    // MARK: - Connection Management
    private func setupNotificationHandling() {
        NotificationCenter.default.publisher(for: .userSessionDisconnected)
            .receive(on: self.serialQueue)
            .sink { _ in
                fatalError("userSessionDisconnected not handled")
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func connect() {
        self.serialQueue.async { [weak self] in
            self?.wampManager.connect()
        }
    }

    func disconnect() {
        self.serialQueue.async { [weak self] in
            self?.wampManager.disconnect()
        }
    }

    func forceReconnect() {
        self.serialQueue.async { [weak self] in
            guard let self = self else { return }

            // First disconnect
            self.wampManager.disconnect()

            // Wait for a short delay to ensure clean disconnect
            Thread.sleep(forTimeInterval: 0.1)

            // Attempt reconnection
            self.wampManager.connect()
        }
    }

    func isConnected() -> Bool {
        return self.serialQueue.sync { self.wampManager.isConnected }
    }

    // MARK: - Request Methods
    func request<T: Codable>(_ router: WAMPRouter) -> AnyPublisher<T, ServiceProviderError> {
        // Get performance feature from router (nil if not tracked)
        let feature = router.performanceFeature

        // Start tracking if feature exists
        if let feature = feature {
            PerformanceTracker.shared.start(
                feature: feature,
                layer: .api,
                metadata: [
                    "type": "rpc",
                    "procedure": router.procedure
                ]
            )
        }

        return self.serialQueue.sync {
            self.wampManager.getModel(router: router, decodingType: T.self)
                .mapError { error -> ServiceProviderError in
                    print("REQUEST ERROR: \(router.procedure)")
                    switch error {
                    case .notConnected:
                        return .onConnection
                    case .requestError(let value):
                        return .errorDetailedMessage(key: "requestError", message: value)
                    case .decodingError(let value):
                        return .decodingError(message: value)
                    case .noResultsReceived:
                        return .invalidResponse
                    default:
                        return .unknown
                    }
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

    func subscribe<T: Codable>(_ router: WAMPRouter) -> AnyPublisher<WAMPSubscriptionContent<T>, ServiceProviderError> {
        return self.serialQueue.sync {
            print("EveryMatrixConnector: Starting subscription to \(router.procedure)")
            return self.wampManager.registerOnEndpoint(router, decodingType: T.self)
                .mapError { error -> ServiceProviderError in
                    print("EveryMatrixConnector: Subscription error: \(error)")
                    switch error {
                    case .notConnected:
                        return .onConnection
                    case .requestError(let value):
                        return .errorDetailedMessage(key: "requestError", message: value)
                    case .decodingError(let value):
                        return .decodingError(message: value)
                    case .noResultsReceived:
                        return .invalidResponse
                    default:
                        return .unknown
                    }
                }
                .handleEvents(
                    receiveOutput: { content in
                        switch content {
                        case .connect(_):
                            print("EveryMatrixConnector: Subscription connected")
                        case .initialContent(_):
                            print("EveryMatrixConnector: Received initial content")
                        case .updatedContent(_):
                            break
                            // print("EveryMatrixConnector: Received content update")
                        case .disconnect:
                            print("EveryMatrixConnector: Subscription disconnected")
                        }
                    }
                )
                .eraseToAnyPublisher()
        }
    }

    func unsubscribe(_ subscription: EndpointPublisherIdentifiable) {
        serialQueue.async { [weak self] in
            self?.wampManager.unregisterFromEndpoint(endpointPublisherIdentifiable: subscription)
        }
    }
}
