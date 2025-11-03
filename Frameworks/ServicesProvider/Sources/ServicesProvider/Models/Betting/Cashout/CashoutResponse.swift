//
//  CashoutResponse.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

/// Public model for cashout execution response
public struct CashoutResponse: Codable, Equatable {

    /// Whether the cashout was successful
    public let success: Bool

    /// Bet identifier that was cashed out
    public let betId: String

    /// Unique request identifier for tracking
    public let requestId: String

    /// Actual cashout value executed
    public let cashoutValue: Double

    /// Type of cashout performed
    /// - "USER_CASHED_OUT": Full cashout
    /// - "PARTIAL": Partial cashout
    public let cashoutType: String

    /// For partial cashouts: amount of stake that was cashed out
    public let partialCashoutStake: Double?

    /// Amount paid out to user's balance
    public let cashoutPayout: Double

    /// Whether cashout requires approval
    /// - false: Immediate payout
    /// - true: Pending approval
    public let pendingCashOut: Bool

    public init(
        success: Bool,
        betId: String,
        requestId: String,
        cashoutValue: Double,
        cashoutType: String,
        partialCashoutStake: Double?,
        cashoutPayout: Double,
        pendingCashOut: Bool
    ) {
        self.success = success
        self.betId = betId
        self.requestId = requestId
        self.cashoutValue = cashoutValue
        self.cashoutType = cashoutType
        self.partialCashoutStake = partialCashoutStake
        self.cashoutPayout = cashoutPayout
        self.pendingCashOut = pendingCashOut
    }

    /// Whether this was a full cashout
    public var isFullCashout: Bool {
        return cashoutType == "USER_CASHED_OUT" || cashoutType == "FULL"
    }

    /// Whether this was a partial cashout
    public var isPartialCashout: Bool {
        return cashoutType == "PARTIAL"
    }
}
