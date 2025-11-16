//
//  UserInfoStreamManager.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation
import Combine
import LDSwiftEventSource

/// Manages hybrid REST + SSE user information stream
/// Follows WebApp pattern: REST snapshot + SSE delta updates
///
/// Architecture:
/// 1. Fetch initial balance via REST (/v2/player/{userId}/balance)
/// 2. Establish SSE connection (/v2/player/{userId}/information/updates)
/// 3. Merge SSE BALANCE_UPDATE_V2 deltas into REST snapshot
/// 4. Handle SESSION_EXPIRATION_V2 events
/// 5. Support force refresh while SSE continues
final class UserInfoStreamManager {

    // MARK: - Dependencies

    private let restConnector: EveryMatrixRESTConnector
    private let sseConnector: EveryMatrixSSEConnector
    private let sessionCoordinator: EveryMatrixSessionCoordinator

    // MARK: - State

    /// Current wallet snapshot (from REST + SSE merges)
    private var currentWallet: UserWallet?

    /// Current session state
    private var sessionState: UserInfo.SessionState = .active

    /// Publisher for external subscribers
    private let subject = PassthroughSubject<SubscribableContent<UserInfo>, ServiceProviderError>()

    /// Subscription storage
    private var cancellables = Set<AnyCancellable>()

    /// JSON decoder for SSE messages
    private let decoder = JSONDecoder()

    /// Stream active flag
    private var isActive = false

    // MARK: - Initialization

    init(
        restConnector: EveryMatrixRESTConnector,
        sseConnector: EveryMatrixSSEConnector,
        sessionCoordinator: EveryMatrixSessionCoordinator
    ) {
        self.restConnector = restConnector
        self.sseConnector = sseConnector
        self.sessionCoordinator = sessionCoordinator
        self.decoder.dateDecodingStrategy = .iso8601

        print("📊 UserInfoStreamManager: Initialized")
    }

    deinit {
        print("🗑️ UserInfoStreamManager: Deinitialized")
        stop()
    }

    // MARK: - Public API

    /// Start user info stream
    /// Hybrid flow: REST snapshot → SSE stream → continuous updates
    ///
    /// - Returns: Publisher emitting SubscribableContent<UserInfo> events
    func start() -> AnyPublisher<SubscribableContent<UserInfo>, ServiceProviderError> {
        guard !isActive else {
            print("⚠️ UserInfoStreamManager: Already active")
            return subject.eraseToAnyPublisher()
        }

        isActive = true
        print("🚀 UserInfoStreamManager: Starting hybrid REST + SSE flow")

        // Step 1: Fetch initial balance snapshot via REST
        fetchInitialBalance()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ UserInfoStreamManager: Initial balance fetch failed - \(error)")
                        self?.subject.send(completion: .failure(error))
                    }
                },
                receiveValue: { [weak self] wallet in
                    guard let self = self else { return }

                    print("✅ UserInfoStreamManager: Initial balance fetched")
                    self.currentWallet = wallet

                    // Emit connected event with initial balance
                    let subscription = Subscription(id: "user-info-stream")
                    self.subject.send(.connected(subscription: subscription))

                    // Emit initial data
                    self.emitUserInfo(event: .contentUpdate)

                    // Step 2: Start SSE stream
                    self.startSSEStream()
                }
            )
            .store(in: &cancellables)

        return subject.eraseToAnyPublisher()
    }

    /// Stop user info stream and cleanup
    func stop() {
        guard isActive else { return }

        print("🛑 UserInfoStreamManager: Stopping")
        isActive = false
        cancellables.removeAll()
        currentWallet = nil
        sessionState = .terminated

        subject.send(.disconnected)
    }

    /// Force refresh balance via REST
    /// SSE stream continues in background, REST update emitted via same publisher
    func refreshBalance() {
        guard isActive else {
            print("⚠️ UserInfoStreamManager: Cannot refresh - stream not active")
            return
        }

        print("🔄 UserInfoStreamManager: Force refreshing balance")

        fetchInitialBalance()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ UserInfoStreamManager: Force refresh failed - \(error)")
                    }
                },
                receiveValue: { [weak self] wallet in
                    guard let self = self else { return }

                    print("✅ UserInfoStreamManager: Force refresh completed")
                    self.currentWallet = wallet
                    self.emitUserInfo(event: .contentUpdate)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Methods: REST

    /// Fetch initial balance snapshot via REST
    private func fetchInitialBalance() -> AnyPublisher<UserWallet, ServiceProviderError> {
        guard let userId = sessionCoordinator.currentUserId else {
            return Fail(error: ServiceProviderError.errorMessage(message: "No user ID available"))
                .eraseToAnyPublisher()
        }

        print("📡 UserInfoStreamManager: Fetching initial balance for user \(userId)")

        let endpoint = EveryMatrixPlayerAPI.getUserBalance(userId: userId)

        let publisher: AnyPublisher<EveryMatrix.WalletBalance, ServiceProviderError> = restConnector.request(endpoint)

        return publisher
            .map { walletBalance in
                return EveryMatrixModelMapper.userWallet(fromWalletBalance: walletBalance)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods: SSE

    /// Start SSE stream for real-time updates
    private func startSSEStream() {
        guard let userId = sessionCoordinator.currentUserId else {
            print("❌ UserInfoStreamManager: Cannot start SSE - no user ID")
            return
        }

        print("📡 UserInfoStreamManager: Starting SSE stream for user \(userId)")

        let endpoint = EveryMatrixPlayerAPI.getUserInformationUpdatesSSE(userId: userId)

        sseConnector.request(endpoint, decodingType: EveryMatrix.UserInfoSSEResponse.self)
            .sink(
                receiveCompletion: { [weak self] completion in
                    print("🔌 UserInfoStreamManager: SSE stream completed")
                    if case .failure(let error) = completion {
                        print("❌ UserInfoStreamManager: SSE error - \(error)")
                    }
                    self?.isActive = false
                },
                receiveValue: { [weak self] streamEvent in
                    self?.handleSSEStreamEvent(streamEvent)
                }
            )
            .store(in: &cancellables)
    }

    /// Handle SSE stream events (connected/message/disconnected)
    private func handleSSEStreamEvent(_ streamEvent: SSEStreamEvent) {
        switch streamEvent {
        case .connected:
            print("✅ UserInfoStreamManager: SSE connected")

        case .message(let messageEvent):
            handleSSEMessage(messageEvent)

        case .disconnected:
            print("🔌 UserInfoStreamManager: SSE disconnected")
        }
    }

    /// Handle SSE message event
    private func handleSSEMessage(_ messageEvent: MessageEvent) {
        guard let jsonData = messageEvent.data.data(using: .utf8) else {
            print("⚠️ UserInfoStreamManager: Failed to convert message data to UTF-8")
            return
        }

        guard let response = try? decoder.decode(EveryMatrix.UserInfoSSEResponse.self, from: jsonData) else {
            print("❌ UserInfoStreamManager: Failed to decode SSE message")
            return
        }

        switch response.messageType {
        case .balanceUpdate:
            if let body = response.body {
                handleBalanceUpdate(body)
            }

        case .sessionExpiration:
            handleSessionExpiration()

        case .unknown:
            print("⚠️ UserInfoStreamManager: Unknown SSE message type: \(response.type)")
        }
    }

    /// Handle BALANCE_UPDATE_V2 message
    private func handleBalanceUpdate(_ body: EveryMatrix.BalanceUpdateBody) {
        guard var wallet = currentWallet else {
            print("⚠️ UserInfoStreamManager: No current wallet - skipping balance update")
            return
        }

        print("💰 UserInfoStreamManager: Processing balance update (transType: \(body.transType), operation: \(body.operationType))")

        // Apply SSE delta to wallet snapshot (WebApp logic)
        wallet = EveryMatrixModelMapper.applyBalanceUpdate(to: wallet, from: body)
        currentWallet = wallet

        // Emit updated user info
        emitUserInfo(event: .contentUpdate)
    }

    /// Handle SESSION_EXPIRATION_V2 message
    private func handleSessionExpiration() {
        print("⚠️ UserInfoStreamManager: Session expiration received")

        sessionState = .expired(reason: nil)

        // Emit session expired event via contentUpdate with expired session state
        // SubscribableContent doesn't have .sessionExpired case, use .contentUpdate
        emitUserInfo(event: .contentUpdate)
    }

    /// Emit UserInfo via subject
    private func emitUserInfo(event: SubscribableContentEvent) {
        guard let wallet = currentWallet else {
            print("⚠️ UserInfoStreamManager: Cannot emit - no wallet data")
            return
        }

        let userInfo = EveryMatrixModelMapper.userInfo(
            wallet: wallet,
            sessionState: sessionState
        )

        switch event {
        case .connected:
            // Already sent .connected in start()
            break

        case .contentUpdate:
            subject.send(.contentUpdate(content: userInfo))
        }
    }

    /// Content event type for emission
    private enum SubscribableContentEvent {
        case connected
        case contentUpdate
    }
}
