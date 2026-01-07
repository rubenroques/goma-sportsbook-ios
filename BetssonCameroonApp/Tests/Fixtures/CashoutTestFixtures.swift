//
//  CashoutTestFixtures.swift
//  BetssonCameroonAppTests
//
//  Test fixtures for cashout-related ServicesProvider types.
//  Provides static factory methods for creating test data.
//

import Foundation
import ServicesProvider

// MARK: - CashoutValue Fixtures

extension CashoutValue {

    /// Standard cashout value with partial enabled
    static func fixture(
        betId: String = "bet-123",
        cashoutValue: Double? = 50.0,
        currentPossibleWinning: Double = 100.0,
        stake: Double = 10.0,
        autoCashOutEnabled: Bool = false,
        partialCashOutEnabled: Bool = true,
        detailsCode: Int = 100,
        detailsMessage: String = "Success"
    ) -> CashoutValue {
        CashoutValue(
            betId: betId,
            cashoutValue: cashoutValue,
            currentPossibleWinning: currentPossibleWinning,
            stake: stake,
            autoCashOutEnabled: autoCashOutEnabled,
            partialCashOutEnabled: partialCashOutEnabled,
            details: CashoutDetails(code: detailsCode, message: detailsMessage)
        )
    }

    /// Loading state (code 103) - no cashout value yet
    static var loading: CashoutValue {
        .fixture(cashoutValue: nil, detailsCode: 103, detailsMessage: "Loading odds")
    }

    /// Full cashout only (partial disabled)
    static var fullCashoutOnly: CashoutValue {
        .fixture(partialCashOutEnabled: false)
    }

    /// High value cashout for testing large amounts
    static var highValue: CashoutValue {
        .fixture(cashoutValue: 1000.0, stake: 100.0)
    }
}

// MARK: - CashoutResponse Fixtures

extension CashoutResponse {

    /// Configurable cashout response
    static func fixture(
        success: Bool = true,
        betId: String = "bet-123",
        requestId: String = "req-456",
        cashoutValue: Double = 50.0,
        cashoutType: String = "USER_CASHED_OUT",
        partialCashoutStake: Double? = nil,
        cashoutPayout: Double = 50.0,
        pendingCashOut: Bool = false
    ) -> CashoutResponse {
        CashoutResponse(
            success: success,
            betId: betId,
            requestId: requestId,
            cashoutValue: cashoutValue,
            cashoutType: cashoutType,
            partialCashoutStake: partialCashoutStake,
            cashoutPayout: cashoutPayout,
            pendingCashOut: pendingCashOut
        )
    }

    /// Full cashout success response
    static var fullCashoutSuccess: CashoutResponse {
        .fixture(cashoutType: "USER_CASHED_OUT", cashoutPayout: 50.0)
    }

    /// Partial cashout success response
    static func partialCashoutSuccess(stake: Double = 5.0, payout: Double = 25.0) -> CashoutResponse {
        .fixture(
            cashoutType: "PARTIAL",
            partialCashoutStake: stake,
            cashoutPayout: payout
        )
    }

    /// Pending cashout (needs approval)
    static var pendingApproval: CashoutResponse {
        .fixture(pendingCashOut: true)
    }

    /// Failed cashout response
    static var failed: CashoutResponse {
        .fixture(success: false)
    }
}

// MARK: - CashoutRequest Fixtures

extension CashoutRequest {

    /// Configurable cashout request
    static func fixture(
        betId: String = "bet-123",
        cashoutValue: Double = 50.0,
        cashoutType: CashoutType = .full,
        partialCashoutStake: Double? = nil,
        cashoutChangeAcceptance: String = "WITHIN_THRESHOLD"
    ) -> CashoutRequest {
        CashoutRequest(
            betId: betId,
            cashoutValue: cashoutValue,
            cashoutType: cashoutType,
            partialCashoutStake: partialCashoutStake,
            cashoutChangeAcceptance: cashoutChangeAcceptance
        )
    }

    /// Full cashout request
    static var fullCashout: CashoutRequest {
        .fixture(cashoutType: .full)
    }

    /// Partial cashout request
    static func partialCashout(stake: Double = 5.0, value: Double = 25.0) -> CashoutRequest {
        .fixture(
            cashoutValue: value,
            cashoutType: .partial,
            partialCashoutStake: stake
        )
    }
}
