import Foundation
import Combine

class EveryMatrixConnector: Connector {
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
            .sink { wampConnectionState in
                switch wampConnectionState {
                case .connected:
                    print("EveryMatrixConnector init wamp connected")
                case .disconnected:
                    print("EveryMatrixConnector init wamp disconnected")
                }
            }
    }

    // MARK: - Connection Management
    private func setupNotificationHandling() {
        NotificationCenter.default.publisher(for: .userSessionDisconnected)
            .receive(on: serialQueue)
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
        serialQueue.async { [weak self] in
            guard let self = self else { return }

            // First disconnect
            self.wampManager.disconnect()

            // Wait for a short delay to ensure clean disconnect
            Thread.sleep(forTimeInterval: 0.5)

            // Attempt reconnection
            self.wampManager.connect()
        }
    }

    func isConnected() -> Bool {
        return serialQueue.sync { self.wampManager.isConnected }
    }

    // MARK: - Request Methods
    func request<T: Codable>(_ router: WAMPRouter) -> AnyPublisher<T, ServiceProviderError> {
        return self.serialQueue.sync {
            self.wampManager.getModel(router: router, decodingType: T.self)
                .mapError { error -> ServiceProviderError in
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
                .eraseToAnyPublisher()
        }
    } 

    func subscribe<T: Codable>(_ router: WAMPRouter) -> AnyPublisher<WAMPSubscriptionContent<T>, ServiceProviderError> {
        return self.serialQueue.sync {
            self.wampManager.registerOnEndpoint(router, decodingType: T.self)
                .mapError { error -> ServiceProviderError in
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
                .eraseToAnyPublisher()
        }
    }

    func unsubscribe(_ subscription: EndpointPublisherIdentifiable) {
        serialQueue.async { [weak self] in
            self?.wampManager.unregisterFromEndpoint(endpointPublisherIdentifiable: subscription)
        }
    }
}
