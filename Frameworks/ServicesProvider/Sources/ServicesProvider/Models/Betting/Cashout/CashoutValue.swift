//
//  CashoutValue.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

/// Public model for real-time cashout value updates (SSE streaming)
public struct CashoutValue: Codable, Equatable {

    /// Bet identifier
    public let betId: String

    /// Current cashout value (nil if code 103 - loading state)
    public let cashoutValue: Double?

    /// Maximum possible winning if bet completes successfully
    public let currentPossibleWinning: Double

    /// Total bet stake
    public let stake: Double

    /// Whether auto-cashout rules can be configured
    public let autoCashOutEnabled: Bool

    /// Whether partial cashouts are allowed
    public let partialCashOutEnabled: Bool

    /// Detailed status information
    public let details: CashoutDetails

    public init(
        betId: String,
        cashoutValue: Double?,
        currentPossibleWinning: Double,
        stake: Double,
        autoCashOutEnabled: Bool,
        partialCashOutEnabled: Bool,
        details: CashoutDetails
    ) {
        self.betId = betId
        self.cashoutValue = cashoutValue
        self.currentPossibleWinning = currentPossibleWinning
        self.stake = stake
        self.autoCashOutEnabled = autoCashOutEnabled
        self.partialCashOutEnabled = partialCashOutEnabled
        self.details = details
    }

    /// Status details from cashout value response
    public struct CashoutDetails: Codable, Equatable {

        /// Status code (103 = loading odds, 100 = success)
        public let code: Int

        /// Human-readable message
        public let message: String

        public init(code: Int, message: String) {
            self.code = code
            self.message = message
        }

        /// Whether the cashout value is ready for use
        public var isReady: Bool {
            return code == 100
        }

        /// Whether still loading (code 103)
        public var isLoading: Bool {
            return code == 103
        }
    }
}
