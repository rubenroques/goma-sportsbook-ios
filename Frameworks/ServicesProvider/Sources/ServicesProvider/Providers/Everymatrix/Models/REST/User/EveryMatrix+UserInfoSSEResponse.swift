//
//  EveryMatrix+UserInfoSSEResponse.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation

extension EveryMatrix {

    /// Internal REST API model for SSE user information updates
    /// Matches EveryMatrix SSE JSON format from /v2/player/{userId}/information/updates
    struct UserInfoSSEResponse: Decodable {

        /// Message type discriminator
        /// - "BALANCE_UPDATE_V2": Wallet balance changed
        /// - "SESSION_EXPIRATION_V2": User session expired
        let type: String

        /// Message body (only present for BALANCE_UPDATE_V2)
        let body: BalanceUpdateBody?

        /// Parsed message type enum
        var messageType: MessageType {
            switch type {
            case "BALANCE_UPDATE_V2":
                return .balanceUpdate
            case "SESSION_EXPIRATION_V2":
                return .sessionExpiration
            default:
                return .unknown
            }
        }

        /// Message type classification
        enum MessageType {
            case balanceUpdate
            case sessionExpiration
            case unknown
        }
    }
}
