//
//  CashoutService.swift
//  ServicesProvider
//
//  Protocol Witness pattern (pointfree.co style) for cashout operations.
//  Dependencies are closure properties, not protocol methods.
//
//  This struct provides a testable interface for cashout operations
//  that can be easily mocked in unit tests.
//

import Foundation
import Combine

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
public struct CashoutService {

    // MARK: - Dependencies as Closures

    /// Subscribe to real-time cashout value updates via SSE
    public var subscribeToCashoutValue: (String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError>

    /// Execute cashout (full or partial)
    public var executeCashout: (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>

    // MARK: - Initialization

    public init(
        subscribeToCashoutValue: @escaping (String) -> AnyPublisher<SubscribableContent<CashoutValue>, ServiceProviderError>,
        executeCashout: @escaping (CashoutRequest) -> AnyPublisher<CashoutResponse, ServiceProviderError>
    ) {
        self.subscribeToCashoutValue = subscribeToCashoutValue
        self.executeCashout = executeCashout
    }
}

// MARK: - Production Implementation

extension CashoutService {

    /// Production implementation wrapping ServicesProvider.Client
    public static func live(client: Client) -> Self {
        .init(
            subscribeToCashoutValue: client.subscribeToCashoutValue,
            executeCashout: client.executeCashout
        )
    }
}

// MARK: - Test Implementations

extension CashoutService {

    /// All operations fail immediately with the given error
    public static func failing(error: ServiceProviderError = .unknown) -> Self {
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
    public static var noop: Self {
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
    public static func mock(
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
