//
//  CashoutValueSSEResponseDTO.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

extension EveryMatrix {

    /// Internal REST API model for SSE cashout value streaming response
    /// Matches EveryMatrix SSE JSON format exactly
    struct CashoutValueSSEResponse: Decodable {

        /// Message type discriminator
        /// - "CASHOUT_VALUE": Cashout value update
        /// - "AUTOCASHOUT_RULE": Auto-cashout rule status
        let messageType: String

        /// Bet identifier
        let betId: String

        /// Screen/session identifier (optional)
        let screenId: String?

        /// Current cashout value (nil if code 103)
        let cashoutValue: Double?

        /// Maximum possible winning
        let currentPossibleWinning: Double

        /// Total bet stake
        let stake: Double

        /// Whether auto-cashout is enabled (nil in initial response)
        let autoCashOutEnabled: Bool?

        /// Whether partial cashout is enabled (nil in initial response)
        let partialCashOutEnabled: Bool?

        /// Status details
        let details: Details

        /// Cashout settings (optional)
        let cashoutValueSettings: CashoutValueSettings?

        /// Status details
        struct Details: Decodable {
            /// Status code
            /// - 103: "Current odds not found" (temporary state)
            /// - 100: "Success" (valid cashout value)
            let code: Int

            /// Human-readable message
            let message: String
        }

        /// Cashout configuration settings
        struct CashoutValueSettings: Decodable {
            let autoCashOutEnabled: Bool?
            let partialCashOutEnabled: Bool?
            let covValidationAcceptHigher: Bool
            let covValidationAcceptLower: Bool
        }

        enum CodingKeys: String, CodingKey {
            case messageType
            case betId
            case screenId
            case cashoutValue
            case currentPossibleWinning
            case stake
            case autoCashOutEnabled
            case partialCashOutEnabled
            case details
            case cashoutValueSettings
        }
    }
}
