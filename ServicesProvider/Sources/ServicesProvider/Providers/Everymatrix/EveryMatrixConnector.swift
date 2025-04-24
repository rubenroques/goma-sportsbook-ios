import Foundation
import Combine

class EveryMatrixConnector: Connector {
    // MARK: - Properties
    private let wampManager: WAMPManager
    private var cancellables = Set<AnyCancellable>()

    private let serialQueue = DispatchQueue(label: "com.everymatrix.connector.queue")
    private let connectionStateSubject = CurrentValueSubject<ConnectorState, Never>(.disconnected)

    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        return self.connectionStateSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(wampManager: WAMPManager = WAMPManager()) {
        self.wampManager = wampManager
        self.setupNotificationHandling()
    }

    // MARK: - Connection Management
    private func setupNotificationHandling() {
        NotificationCenter.default.publisher(for: .socketConnected)
            .receive(on: serialQueue)
            .sink { [weak self] _ in
                self?.handleConnectionStateChange(.connected)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .socketDisconnected)
            .receive(on: serialQueue)
            .sink { [weak self] _ in
                self?.handleConnectionStateChange(.disconnected)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .userSessionDisconnected)
            .receive(on: serialQueue)
            .sink { [weak self] _ in
                self?.handleConnectionStateChange(.disconnected)
            }
            .store(in: &cancellables)
    }

    private func handleConnectionStateChange(_ state: ConnectorState) {
        self.serialQueue.async { [weak self] in
            self?.connectionStateSubject.send(state)
        }
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

            // Start monitoring reconnection attempt
            self.monitorReconnection()
        }
    }

    private func monitorReconnection() {
        // Create a timeout timer
        let timeoutInterval: TimeInterval = 10.0
        var attempts = 0
        let maxAttempts = 3

        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                self.serialQueue.async {
                    if self.wampManager.isConnected {
                        self.handleConnectionStateChange(.connected)
                        return
                    }

                    attempts += 1
                    if attempts >= maxAttempts {
                        // If we've exceeded max attempts, give up and notify failure
                        self.handleConnectionStateChange(.disconnected)
                        return
                    }

                    // Try reconnecting again
                    self.wampManager.connect()
                }
            }
            .store(in: &cancellables)
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
            self.wampManager.subscribeEndpoint(router, decodingType: T.self)
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
            self?.wampManager.unsubscribeFromEndpoint(endpointPublisherIdentifiable: subscription)
        }
    }
}
