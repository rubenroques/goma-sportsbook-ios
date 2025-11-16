//
//  BalanceUpdateEvent.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation

/// Balance update event metadata from SSE BALANCE_UPDATE_V2 messages
/// Provides transaction context for wallet balance changes
public struct BalanceUpdateEvent: Equatable {

    /// Type of transaction that caused the balance change
    public let transactionType: TransactionType

    /// Operation direction (debit/credit/reserve/release)
    public let operationType: OperationType

    /// Currency code (e.g., "XAF", "EUR")
    public let currency: String

    /// Source system (e.g., "GmSlim", "Casino")
    public let source: String?

    /// Timestamp when the transaction occurred
    public let timestamp: Date

    // MARK: - Transaction Type

    /// Transaction type classification
    /// Maps to EveryMatrix transType field in SSE events
    public enum TransactionType: Int, Equatable {
        case unknown = 0
        case deposit = 1        // Money added to wallet
        case withdrawal = 2     // Money withdrawn from wallet
        case win = 3            // Bet win payout
        case refund = 4         // Transaction refunded
        case bonus = 5          // Bonus credited
        case adjustment = 6     // Manual balance adjustment
        case bet = 7            // Bet placed (most common)
        case reserve = 8        // Amount reserved/held
        case release = 9        // Reserved amount released
        case jackpot = 10       // Jackpot win

        /// Human-readable description
        public var description: String {
            switch self {
            case .unknown: return "Unknown"
            case .deposit: return "Deposit"
            case .withdrawal: return "Withdrawal"
            case .win: return "Win"
            case .refund: return "Refund"
            case .bonus: return "Bonus"
            case .adjustment: return "Adjustment"
            case .bet: return "Bet"
            case .reserve: return "Reserve"
            case .release: return "Release"
            case .jackpot: return "Jackpot"
            }
        }
    }

    // MARK: - Operation Type

    /// Operation direction classification
    /// Maps to EveryMatrix operationType field in SSE events
    public enum OperationType: Int, Equatable {
        case debit = 0      // Money out (bet, withdrawal)
        case credit = 1     // Money in (deposit, win)
        case reserve = 2    // Hold funds (pending bet)
        case release = 3    // Release held funds (bet cancelled)

        /// Human-readable description
        public var description: String {
            switch self {
            case .debit: return "Debit"
            case .credit: return "Credit"
            case .reserve: return "Reserve"
            case .release: return "Release"
            }
        }
    }

    // MARK: - Initialization

    public init(
        transactionType: TransactionType,
        operationType: OperationType,
        currency: String,
        source: String?,
        timestamp: Date
    ) {
        self.transactionType = transactionType
        self.operationType = operationType
        self.currency = currency
        self.source = source
        self.timestamp = timestamp
    }
}
