//
//  CashoutRequest.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

/// Public model for cashout execution request
public struct CashoutRequest: Codable, Equatable {

    /// Bet identifier to cash out
    public let betId: String

    /// Cashout value to request
    /// - For full cashout: use value from CashoutValue.cashoutValue
    /// - For partial cashout: calculate as (fullCashoutValue × partialCashoutStake) / totalStake
    public let cashoutValue: Double

    /// Type of cashout operation
    public let cashoutType: CashoutType

    /// For partial cashouts: amount of stake to cash out
    /// - Must be less than total bet stake
    /// - Required when cashoutType is .partial
    public let partialCashoutStake: Double?

    /// How to handle odds changes
    /// - "ACCEPT_ANY": Accept execution even if odds change
    /// - "ACCEPT_HIGHER": Only accept if odds improve
    /// - "NONE": Reject if odds change
    public let cashoutChangeAcceptanceType: String

    public init(
        betId: String,
        cashoutValue: Double,
        cashoutType: CashoutType,
        partialCashoutStake: Double? = nil,
        cashoutChangeAcceptanceType: String = "ACCEPT_ANY"
    ) {
        self.betId = betId
        self.cashoutValue = cashoutValue
        self.cashoutType = cashoutType
        self.partialCashoutStake = partialCashoutStake
        self.cashoutChangeAcceptanceType = cashoutChangeAcceptanceType
    }

    /// Type of cashout operation
    public enum CashoutType: String, Codable {
        /// Cash out entire bet
        case full = "FULL"

        /// Cash out partial stake amount
        case partial = "PARTIAL"
    }
}

// MARK: - Partial Cashout Calculation Helper

extension CashoutRequest {

    /// Calculate partial cashout value using EveryMatrix formula
    ///
    /// Formula: cashoutValue = (fullCashoutValue × partialStake) / totalStake
    ///
    /// - Parameters:
    ///   - fullCashoutValue: Full cashout value from SSE response
    ///   - partialStake: Amount of stake user wants to cash out
    ///   - totalStake: Total bet stake
    /// - Returns: Calculated cashout value for partial cashout
    public static func calculatePartialCashoutValue(
        fullCashoutValue: Double,
        partialStake: Double,
        totalStake: Double
    ) -> Double {
        return (fullCashoutValue * partialStake) / totalStake
    }
}
