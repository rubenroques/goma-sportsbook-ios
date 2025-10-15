//
//  NewCashoutRequestDTO.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

extension EveryMatrix {

    /// Internal DTO for new cashout API execution request
    /// Matches EveryMatrix POST /cashout/v1/cashout endpoint format
    struct NewCashoutRequest: Encodable {

        /// Bet identifier
        let betId: String

        /// Cashout value to request
        /// - For full cashout: exact value from SSE response
        /// - For partial cashout: calculated as (fullValue × partialStake) / totalStake
        let cashoutValue: Double

        /// Type of cashout
        /// - "FULL": Cash out entire bet
        /// - "PARTIAL": Cash out partial stake
        let cashoutType: String

        /// For partial cashouts: amount of stake to cash out
        let partialCashoutStake: Double?

        /// How to handle odds changes
        /// - "ACCEPT_ANY": Accept execution even if odds change
        /// - "ACCEPT_HIGHER": Only accept if odds improve
        /// - "NONE": Reject if odds change
        let cashoutChangeAcceptanceType: String

        enum CodingKeys: String, CodingKey {
            case betId
            case cashoutValue
            case cashoutType
            case partialCashoutStake
            case cashoutChangeAcceptanceType
        }
    }
}
