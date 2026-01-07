//
//  WalletService.swift
//  ServicesProvider
//
//  Protocol Witness pattern (pointfree.co style) for wallet operations.
//  Dependencies are closure properties, not protocol methods.
//
//  This struct provides a testable interface for wallet/balance operations
//  that can be easily mocked in unit tests.
//

import Foundation
import Combine

/// Struct-based dependency injection for wallet operations.
/// Each property is a closure that can be swapped for testing.
///
/// Usage in production:
/// ```
/// let service = WalletService.live(client: servicesProvider)
/// ```
///
/// Usage in tests:
/// ```
/// let service = WalletService(
///     getUserBalance: { Just(mockWallet).setFailureType(to: ServiceProviderError.self).eraseToAnyPublisher() },
///     subscribeUserInfoUpdates: { sseSubject.eraseToAnyPublisher() }
/// )
/// ```
public struct WalletService {

    // MARK: - Dependencies as Closures

    /// Get current user wallet balance (one-time fetch)
    public var getUserBalance: () -> AnyPublisher<UserWallet, ServiceProviderError>

    /// Get user cashback balance
    public var getUserCashbackBalance: () -> AnyPublisher<CashbackBalance, ServiceProviderError>

    /// Subscribe to real-time user info updates (wallet + session) via SSE
    public var subscribeUserInfoUpdates: () -> AnyPublisher<SubscribableContent<UserInfo>, ServiceProviderError>

    /// Force refresh balance via REST
    public var refreshUserBalance: () -> Void

    // MARK: - Initialization

    public init(
        getUserBalance: @escaping () -> AnyPublisher<UserWallet, ServiceProviderError>,
        getUserCashbackBalance: @escaping () -> AnyPublisher<CashbackBalance, ServiceProviderError>,
        subscribeUserInfoUpdates: @escaping () -> AnyPublisher<SubscribableContent<UserInfo>, ServiceProviderError>,
        refreshUserBalance: @escaping () -> Void
    ) {
        self.getUserBalance = getUserBalance
        self.getUserCashbackBalance = getUserCashbackBalance
        self.subscribeUserInfoUpdates = subscribeUserInfoUpdates
        self.refreshUserBalance = refreshUserBalance
    }
}

// MARK: - Production Implementation

extension WalletService {

    /// Production implementation wrapping ServicesProvider.Client
    public static func live(client: Client) -> Self {
        .init(
            getUserBalance: client.getUserBalance,
            getUserCashbackBalance: client.getUserCashbackBalance,
            subscribeUserInfoUpdates: client.subscribeUserInfoUpdates,
            refreshUserBalance: client.refreshUserBalance
        )
    }
}

// MARK: - Test Implementations

extension WalletService {

    /// All operations fail immediately with the given error
    public static func failing(error: ServiceProviderError = .unknown) -> Self {
        .init(
            getUserBalance: {
                Fail(error: error).eraseToAnyPublisher()
            },
            getUserCashbackBalance: {
                Fail(error: error).eraseToAnyPublisher()
            },
            subscribeUserInfoUpdates: {
                Fail(error: error).eraseToAnyPublisher()
            },
            refreshUserBalance: { }
        )
    }

    /// Operations never complete - useful for testing loading states
    public static var noop: Self {
        .init(
            getUserBalance: {
                Empty(completeImmediately: false).eraseToAnyPublisher()
            },
            getUserCashbackBalance: {
                Empty(completeImmediately: false).eraseToAnyPublisher()
            },
            subscribeUserInfoUpdates: {
                Empty(completeImmediately: false).eraseToAnyPublisher()
            },
            refreshUserBalance: { }
        )
    }

    /// Configurable mock - pass closures for any behavior needed
    public static func mock(
        getUserBalance: @escaping () -> AnyPublisher<UserWallet, ServiceProviderError> = {
            Empty(completeImmediately: false).eraseToAnyPublisher()
        },
        getUserCashbackBalance: @escaping () -> AnyPublisher<CashbackBalance, ServiceProviderError> = {
            Empty(completeImmediately: false).eraseToAnyPublisher()
        },
        subscribeUserInfoUpdates: @escaping () -> AnyPublisher<SubscribableContent<UserInfo>, ServiceProviderError> = {
            Empty(completeImmediately: false).eraseToAnyPublisher()
        },
        refreshUserBalance: @escaping () -> Void = { }
    ) -> Self {
        .init(
            getUserBalance: getUserBalance,
            getUserCashbackBalance: getUserCashbackBalance,
            subscribeUserInfoUpdates: subscribeUserInfoUpdates,
            refreshUserBalance: refreshUserBalance
        )
    }
}
