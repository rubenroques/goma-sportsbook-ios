//
//  NewCashoutResponseDTO.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

extension EveryMatrix {

    /// Internal REST API model for new cashout API execution response
    /// Matches EveryMatrix POST /cashout/v1/cashout endpoint response format
    struct NewCashoutResponse: Decodable {

        /// Whether cashout was successful
        let success: Bool

        /// Bet identifier
        let betId: String

        /// Unique request identifier for tracking
        let requestId: String

        /// Executed cashout value
        let cashoutValue: Double

        /// Type of cashout performed
        /// - "USER_CASHED_OUT": Full cashout
        /// - "PARTIAL": Partial cashout
        let cashoutType: String

        /// For partial cashouts: amount of stake cashed out
        let partialCashoutStake: Double?

        /// Amount paid out to user
        let cashoutPayout: Double

        /// Whether cashout requires approval
        /// - false: Immediate payout
        /// - true: Pending approval
        let pendingCashOut: Bool

        enum CodingKeys: String, CodingKey {
            case success
            case betId
            case requestId
            case cashoutValue
            case cashoutType
            case partialCashoutStake
            case cashoutPayout
            case pendingCashOut
        }
    }
}
