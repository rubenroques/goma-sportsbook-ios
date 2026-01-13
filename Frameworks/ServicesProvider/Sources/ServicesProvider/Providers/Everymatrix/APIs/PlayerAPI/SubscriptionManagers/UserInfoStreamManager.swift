//
//  UserInfoStreamManager.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation
import Combine
import LDSwiftEventSource
import GomaLogger

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

    /// Subscription storage for non-SSE subscriptions (initial balance fetch)
    private var cancellables = Set<AnyCancellable>()

    /// CRITICAL: SSE subscription stored separately to prevent leaks
    /// Each reconnection MUST cancel this before creating new subscription
    private var sseSubscription: AnyCancellable?

    /// JSON decoder for SSE messages
    private let decoder = JSONDecoder()

    /// Stream active flag
    private var isActive = false

    // MARK: - Reconnection State (Matches Web Implementation)

    /// Reconnection active flag - prevents reconnection when stopped
    /// Matches Web's `isActive` flag (client.js:537)
    private var isReconnectionActive = true

    /// Current reconnection attempt count
    /// Matches Web's `retryCount` (client.js:538)
    private var retryCount = 0

    /// Maximum reconnection attempts before giving up
    /// iOS uses 6 retries (vs Web's 5) for faster mobile network recovery
    private let maxRetries = 6

    /// Reconnection scheduled task
    private var reconnectionTask: DispatchWorkItem?

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

        GomaLogger.debug(.realtime, category: "SSE", "📊 UserInfoStreamManager: Initialized")
    }

    deinit {
        GomaLogger.debug(.realtime, category: "SSE", "🗑️ UserInfoStreamManager: Deinitialized")

        // Cancel any pending reconnection
        reconnectionTask?.cancel()
        reconnectionTask = nil

        // Cancel SSE subscription
        sseSubscription?.cancel()
        sseSubscription = nil

        stop(reason: "DEINIT")
    }

    // MARK: - Public API

    /// Start user info stream
    /// Hybrid flow: REST snapshot → SSE stream → continuous updates
    ///
    /// - Returns: Publisher emitting SubscribableContent<UserInfo> events
    func start() -> AnyPublisher<SubscribableContent<UserInfo>, ServiceProviderError> {
        guard !isActive else {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Already active")
            return subject.eraseToAnyPublisher()
        }

        isActive = true
        isReconnectionActive = true  // ✅ Enable reconnection (matches Web)
        retryCount = 0               // ✅ Reset retry count

        GomaLogger.debug(.realtime, category: "SSE", "🚀 UserInfoStreamManager: Starting hybrid REST + SSE flow")
        GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: Reconnection enabled (max retries: \(maxRetries))")

        // Step 1: Fetch initial balance snapshot via REST
        fetchInitialBalance()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        GomaLogger.error(.realtime, category: "SSE", "❌ UserInfoStreamManager: Initial balance fetch failed - \(error)")
                        self?.subject.send(completion: .failure(error))
                    }
                },
                receiveValue: { [weak self] wallet in
                    guard let self = self else { return }

                    GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: Initial balance fetched")
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
    /// - Parameter reason: Optional reason for stopping (e.g., "SESSION_EXPIRATION", "MANUAL_LOGOUT")
    func stop(reason: String? = nil) {
        guard isActive else { return }

        let reasonText = reason ?? "MANUAL"
        GomaLogger.debug(.realtime, category: "SSE", "🛑 UserInfoStreamManager: Stopping (reason: \(reasonText))")

        // CRITICAL: Disable reconnection when stopping (matches Web's isActive = false)
        isReconnectionActive = false

        // Cancel any pending reconnection
        reconnectionTask?.cancel()
        reconnectionTask = nil

        GomaLogger.debug(.realtime, category: "SSE", "🛑 UserInfoStreamManager: Reconnection disabled")

        // CRITICAL: Cancel SSE subscription to stop EventSource
        // This triggers handleEvents(receiveCancel) which calls adapter.stop()
        if let subscription = sseSubscription {
            GomaLogger.debug(.realtime, category: "SSE", "🛑 UserInfoStreamManager: Canceling SSE subscription")
            subscription.cancel()
            sseSubscription = nil
            GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: SSE subscription canceled")
        }

        isActive = false
        cancellables.removeAll()
        currentWallet = nil
        sessionState = .terminated

        subject.send(.disconnected)
        GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: Stream stopped and disconnected")
    }

    /// Force refresh balance via REST
    /// SSE stream continues in background, REST update emitted via same publisher
    func refreshBalance() {
        guard isActive else {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Cannot refresh - stream not active")
            return
        }

        GomaLogger.debug(.realtime, category: "SSE", "🔄 UserInfoStreamManager: Force refreshing balance")

        fetchInitialBalance()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        GomaLogger.error(.realtime, category: "SSE", "❌ UserInfoStreamManager: Force refresh failed - \(error)")
                    }
                },
                receiveValue: { [weak self] wallet in
                    guard let self = self else { return }

                    GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: Force refresh completed")
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

        GomaLogger.debug(.realtime, category: "SSE", "📡 UserInfoStreamManager: Fetching initial balance for user \(userId)")

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
            GomaLogger.error(.realtime, category: "SSE", "❌ UserInfoStreamManager: Cannot start SSE - no user ID")
            return
        }

        // CRITICAL: Cancel previous SSE subscription before creating new one
        // This prevents zombie EventSource instances from accumulating on reconnection
        if let oldSubscription = sseSubscription {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Canceling previous SSE subscription before reconnection")
            oldSubscription.cancel()
            sseSubscription = nil
            GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: Previous SSE subscription canceled")
        }

        GomaLogger.debug(.realtime, category: "SSE", "📡 UserInfoStreamManager: Starting SSE stream for user \(userId)")

        let endpoint = EveryMatrixPlayerAPI.getUserInformationUpdatesSSE(userId: userId)

        // Store subscription separately to enable explicit cancellation
        sseSubscription = sseConnector.request(endpoint, decodingType: EveryMatrix.UserInfoSSEResponse.self)
            .sink(
                receiveCompletion: { [weak self] completion in
                    GomaLogger.debug(.realtime, category: "SSE", "🔌 UserInfoStreamManager: SSE stream completed")
                    if case .failure(let error) = completion {
                        GomaLogger.error(.realtime, category: "SSE", "❌ UserInfoStreamManager: SSE error - \(error)")
                    }

                    // CRITICAL: Only clear subscription reference, DON'T set isActive = false
                    // Completion only fires when stop() is called (which already sets isActive = false)
                    // Normal disconnections/errors send .disconnected event, not completion
                    self?.sseSubscription = nil
                    GomaLogger.debug(.realtime, category: "SSE", "📌 UserInfoStreamManager: SSE subscription cleared on completion")
                },
                receiveValue: { [weak self] streamEvent in
                    self?.handleSSEStreamEvent(streamEvent)
                }
            )
    }

    /// Handle SSE stream events (connected/message/disconnected)
    private func handleSSEStreamEvent(_ streamEvent: SSEStreamEvent) {
        switch streamEvent {
        case .connected:
            GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: SSE connected")
            GomaLogger.debug(.realtime, category: "SSE", "   - EventSource stream established")

            // CRITICAL: Reset retry count on successful connection (matches Web line 557)
            if retryCount > 0 {
                GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: Connection successful - resetting retry count (was: \(retryCount))")
                retryCount = 0
            }

            GomaLogger.debug(.realtime, category: "SSE", "   - Manual reconnection enabled (max retries: \(maxRetries))")

        case .message(let messageEvent):
            handleSSEMessage(messageEvent)

        case .disconnected:
            GomaLogger.debug(.realtime, category: "SSE", "🔌 UserInfoStreamManager: SSE disconnected")
            GomaLogger.debug(.realtime, category: "SSE", "   - Stream closed by server or network interruption")

            // Manual reconnection logic (matches Web implementation)
            handleReconnection()
        }
    }

    /// Handle SSE message event
    private func handleSSEMessage(_ messageEvent: MessageEvent) {
        guard let jsonData = messageEvent.data.data(using: .utf8) else {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Failed to convert message data to UTF-8")
            return
        }

        guard let response = try? decoder.decode(EveryMatrix.UserInfoSSEResponse.self, from: jsonData) else {
            GomaLogger.error(.realtime, category: "SSE", "❌ UserInfoStreamManager: Failed to decode SSE message")
            return
        }

        switch response.messageType {
        case .balanceUpdate:
            if case .balanceUpdate(let balanceBody)? = response.body {
                GomaLogger.debug(.realtime, category: "SSE", "💰 UserInfoStreamManager: Received BALANCE_UPDATE (type: '\(response.type)')")
                handleBalanceUpdate(balanceBody)
            } else {
                GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: BALANCE_UPDATE has no valid body (type: '\(response.type)')")
            }

        case .sessionExpiration:
            GomaLogger.debug(.realtime, category: "SSE", "🚨 UserInfoStreamManager: Received SESSION_EXPIRATION (type: '\(response.type)')")
            if case .sessionExpiration(let sessionBody)? = response.body {
                GomaLogger.debug(.realtime, category: "SSE", "   - Exit Reason: \(sessionBody.exitReason)")
                GomaLogger.debug(.realtime, category: "SSE", "   - Exit Code: \(sessionBody.exitReasonCode)")
                GomaLogger.debug(.realtime, category: "SSE", "   - Session ID: \(sessionBody.sessionId)")
                GomaLogger.debug(.realtime, category: "SSE", "   - Source: \(sessionBody.sourceName)")
                handleSessionExpiration(sessionBody)
            } else {
                GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: SESSION_EXPIRATION has no valid body (type: '\(response.type)')")
            }

        case .unknown:
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Unknown SSE message type: '\(response.type)'")
        }
    }

    /// Handle BALANCE_UPDATE_V2 message
    private func handleBalanceUpdate(_ body: EveryMatrix.BalanceUpdateBody) {
        guard var wallet = currentWallet else {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: No current wallet - skipping balance update")
            return
        }

        GomaLogger.debug(.realtime, category: "SSE", "💰 UserInfoStreamManager: Processing balance update (transType: \(body.transType ?? -1), operation: \(body.operationType))")
        GomaLogger.debug(.realtime, category: "SSE", "📦 Balance update details:")
        GomaLogger.debug(.realtime, category: "SSE", "   - Currency: \(body.currency)")
        GomaLogger.debug(.realtime, category: "SSE", "   - PostingId: \(body.postingId)")
        GomaLogger.debug(.realtime, category: "SSE", "   - Source: \(body.source)")
        GomaLogger.debug(.realtime, category: "SSE", "   - Balance changes: \(body.balanceChange)")
        GomaLogger.debug(.realtime, category: "SSE", "   - Wallet BEFORE: total=\(wallet.total ?? 0), withdrawable=\(wallet.withdrawable ?? 0), bonus=\(wallet.bonus ?? 0)")

        // Apply SSE delta to wallet snapshot (WebApp logic)
        wallet = EveryMatrixModelMapper.applyBalanceUpdate(to: wallet, from: body)
        currentWallet = wallet

        GomaLogger.debug(.realtime, category: "SSE", "   - Wallet AFTER:  total=\(wallet.total ?? 0), withdrawable=\(wallet.withdrawable ?? 0), bonus=\(wallet.bonus ?? 0)")

        // Emit updated user info
        emitUserInfo(event: .contentUpdate)
    }

    /// Handle SESSION_EXPIRATION_V2 message
    private func handleSessionExpiration(_ body: EveryMatrix.SessionExpirationBody) {
        GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Session expiration received")
        GomaLogger.debug(.realtime, category: "SSE", "   - Reason: \(body.exitReason) (code: \(body.exitReasonCode))")
        GomaLogger.debug(.realtime, category: "SSE", "   - User: \(body.userId), Session: \(body.sessionId)")
        GomaLogger.debug(.realtime, category: "SSE", "   - Source: \(body.sourceName)")

        // Pass exitReason to expired state for UserSessionStore logging
        sessionState = .expired(reason: body.exitReason)

        // Emit session expired event via contentUpdate with expired session state
        // SubscribableContent doesn't have .sessionExpired case, use .contentUpdate
        GomaLogger.debug(.realtime, category: "SSE", "📤 UserInfoStreamManager: About to emit SESSION_EXPIRATION to subscribers")
        emitUserInfo(event: .contentUpdate)
        GomaLogger.debug(.realtime, category: "SSE", "✅ UserInfoStreamManager: SESSION_EXPIRATION event emitted successfully")

        // Stop SSE stream to prevent reconnection with invalid token
        // Use async to ensure contentUpdate is fully processed before stopping
        GomaLogger.debug(.realtime, category: "SSE", "🛑 UserInfoStreamManager: Will stop stream due to SESSION_EXPIRATION")
        DispatchQueue.main.async { [weak self] in
            GomaLogger.debug(.realtime, category: "SSE", "🛑 UserInfoStreamManager: Stopping stream (reason: SESSION_EXPIRATION - \(body.exitReason))")
            self?.stop(reason: "SESSION_EXPIRATION(\(body.exitReason))")
        }
    }

    // MARK: - Reconnection Logic (Matches Web Implementation)

    /// Handle SSE reconnection with exponential backoff
    /// Matches Web's reconnection logic (client.js:594-605 and 618-629)
    private func handleReconnection() {
        // Check if reconnection is allowed
        guard isReconnectionActive else {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Reconnection disabled (stream stopped)")
            return
        }

        guard retryCount < maxRetries else {
            GomaLogger.error(.realtime, category: "SSE", "❌ UserInfoStreamManager: Max retries (\(maxRetries)) reached - giving up")
            GomaLogger.debug(.realtime, category: "SSE", "🔌 UserInfoStreamManager: Sending final disconnection to subscribers")
            subject.send(.disconnected)

            // Send completion to terminate publisher
            let error = ServiceProviderError.errorMessage(message: "SSE max retries reached")
            subject.send(completion: .failure(error))
            return
        }

        // Calculate exponential backoff delay (faster for mobile)
        // iOS: min(0.2 * pow(2, retryCount), 30.0) seconds
        // Backoff: 200ms → 400ms → 800ms → 1.6s → 3.2s → 6.4s → 12.8s → 25.6s → 30s (capped)
        let delay = min(0.2 * pow(2.0, Double(retryCount)), 30.0)

        GomaLogger.debug(.realtime, category: "SSE", "🔄 UserInfoStreamManager: Reconnecting in \(String(format: "%.1f", delay))s (attempt \(retryCount + 1)/\(maxRetries))")
        retryCount += 1

        // Cancel any pending reconnection
        reconnectionTask?.cancel()

        // Schedule reconnection with exponential backoff
        let task = DispatchWorkItem { [weak self] in
            guard let self = self, self.isReconnectionActive else {
                GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Reconnection cancelled (stream stopped)")
                return
            }

            GomaLogger.debug(.realtime, category: "SSE", "🔄 UserInfoStreamManager: Executing reconnection (attempt \(self.retryCount)/\(self.maxRetries))")
            self.startSSEStream()
        }

        reconnectionTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }

    /// Emit UserInfo via subject
    private func emitUserInfo(event: SubscribableContentEvent) {
        guard let wallet = currentWallet else {
            GomaLogger.debug(.realtime, category: "SSE", "⚠️ UserInfoStreamManager: Cannot emit - no wallet data")
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
