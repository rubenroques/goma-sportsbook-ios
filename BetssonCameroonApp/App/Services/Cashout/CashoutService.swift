//
//  CashoutService.swift
//  BetssonCameroonApp
//
//  Protocol Witness pattern (pointfree.co style) for cashout operations.
//  Dependencies are closure properties, not protocol methods.
//

import Foundation
import Combine
import ServicesProvider

/// Struct-based dependency injection for cashout operations.
/// Each property is a closure that can be swapped for testing.
///
/// Usage in production:
/// ```
/// let service = CashoutService.live(client: servicesProvider)
/// ```
///
/// Usage in tests:
/// ```
/// let service = CashoutService(
///     subscribeToCashoutValue: { _ in Just(.contentUpdate(mockValue))... },
///     executeCashout: { _ in Fail(error: .unknown)... }
/// )
/// ```
struct CashoutService {

    // MARK: - Dependencies as Closures

    /// Subscribe to real-time cashout value updates via SSE
    var subscribeToCashoutValue: (String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError>

    /// Execute cashout (full or partial)
    var executeCashout: (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>
}

// MARK: - Production Implementation

extension CashoutService {

    /// Production implementation wrapping ServicesProvider.Client
    static func live(client: ServicesProvider.Client) -> Self {
        .init(
            subscribeToCashoutValue: client.subscribeToCashoutValue,
            executeCashout: client.executeCashout
        )
    }
}

// MARK: - Test Implementations

extension CashoutService {

    /// All operations fail immediately with the given error
    static func failing(error: ServiceProviderError = .unknown) -> Self {
        .init(
            subscribeToCashoutValue: { _ in
                Fail(error: error).eraseToAnyPublisher()
            },
            executeCashout: { _ in
                Fail(error: error).eraseToAnyPublisher()
            }
        )
    }

    /// Operations never complete - useful for testing loading states
    static var noop: Self {
        .init(
            subscribeToCashoutValue: { _ in
                Empty(completeImmediately: false).eraseToAnyPublisher()
            },
            executeCashout: { _ in
                Empty(completeImmediately: false).eraseToAnyPublisher()
            }
        )
    }

    /// Configurable mock - pass closures for any behavior needed
    static func mock(
        subscribeToCashoutValue: @escaping (String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError> = { _ in
            Empty(completeImmediately: false).eraseToAnyPublisher()
        },
        executeCashout: @escaping (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError> = { _ in
            Empty(completeImmediately: false).eraseToAnyPublisher()
        }
    ) -> Self {
        .init(
            subscribeToCashoutValue: subscribeToCashoutValue,
            executeCashout: executeCashout
        )
    }
}
