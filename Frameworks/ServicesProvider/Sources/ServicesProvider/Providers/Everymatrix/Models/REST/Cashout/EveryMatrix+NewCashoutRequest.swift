//
//  NewCashoutRequestDTO.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

extension EveryMatrix {

    /// Internal REST API model for new cashout API execution request
    /// Matches EveryMatrix POST /bets-api/v1/{operatorId}/cashout endpoint format
    struct CashoutRequest: Encodable {

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

        /// How to handle odds changes
        /// - "WITHIN_THRESHOLD": Accept if change is within acceptable threshold
        /// - "ACCEPT_HIGHER": Only accept if odds improve
        /// - "NONE": Reject if odds change
        let cashoutChangeAcceptance: String

        /// Operator identifier
        let operatorId: String

        /// Language code (e.g., "en")
        let language: String

        /// For partial cashouts: amount of stake to cash out
        let partialCashoutStake: Double?

        enum CodingKeys: String, CodingKey {
            case betId
            case cashoutValue
            case cashoutType
            case cashoutChangeAcceptance
            case operatorId
            case language
            case partialCashoutStake
        }
    }
}
