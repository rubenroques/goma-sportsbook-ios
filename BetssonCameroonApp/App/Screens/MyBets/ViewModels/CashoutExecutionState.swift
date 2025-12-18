//
//  CashoutExecutionState.swift
//  BetssonCameroonApp
//
//  Created on 17/12/2025.
//

import Foundation
import ServicesProvider

/// State machine for cashout execution flow
enum CashoutExecutionState: Equatable {
    /// Default state - user can interact with slider and button
    case idle

    /// Cashout request in progress
    case loading

    /// Full cashout completed successfully - bet should be removed from list
    case fullCashoutSuccess(payout: Double)

    /// Partial cashout completed successfully - bet should be reloaded
    case partialCashoutSuccess(payout: Double, remainingStake: Double)

    /// Cashout failed - show error with retry option
    case failed(CashoutExecutionError)

    /// Whether the state represents a loading condition
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

/// Error model for cashout execution failures
struct CashoutExecutionError: Equatable, Error {
    let message: String
    let isRetryable: Bool

    /// Create error from ServiceProviderError
    static func fromServiceError(_ error: ServiceProviderError) -> CashoutExecutionError {
        CashoutExecutionError(
            message: error.localizedDescription,
            isRetryable: true
        )
    }

    /// Create error from generic Error
    static func fromError(_ error: Error) -> CashoutExecutionError {
        CashoutExecutionError(
            message: error.localizedDescription,
            isRetryable: true
        )
    }
}
