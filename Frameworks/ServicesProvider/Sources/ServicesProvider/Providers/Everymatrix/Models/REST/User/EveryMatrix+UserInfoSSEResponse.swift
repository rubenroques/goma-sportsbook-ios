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
        /// - "BALANCE_UPDATE" or "BALANCE_UPDATE_V2": Wallet balance changed
        /// - "SESSION_EXPIRATION" or "SESSION_EXPIRATION_V2": User session expired
        let type: String

        /// Message body (type-safe enum for different message types)
        let body: SSEMessageBody?

        /// Parsed message type enum
        /// Supports both V2 and non-V2 message type formats for backward compatibility
        var messageType: MessageType {
            switch type {
            case "BALANCE_UPDATE_V2", "BALANCE_UPDATE":
                return .balanceUpdate
            case "SESSION_EXPIRATION_V2", "SESSION_EXPIRATION":
                return .sessionExpiration
            default:
                print("⚠️ UserInfoSSEResponse: Unknown message type: '\(type)'")
                return .unknown
            }
        }

        /// Message type classification
        enum MessageType {
            case balanceUpdate
            case sessionExpiration
            case unknown
        }

        /// Type-safe enum for SSE message bodies
        /// Allows decoding different body structures based on message type
        enum SSEMessageBody: Decodable {
            case balanceUpdate(BalanceUpdateBody)
            case sessionExpiration(SessionExpirationBody)

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()

                // Try decoding as BalanceUpdateBody first
                if let balanceUpdate = try? container.decode(BalanceUpdateBody.self) {
                    print("[SSEDebug] 📦 SSEMessageBody: Successfully decoded as BalanceUpdateBody")
                    self = .balanceUpdate(balanceUpdate)
                    return
                }

                // Try decoding as SessionExpirationBody
                if let sessionExpiration = try? container.decode(SessionExpirationBody.self) {
                    print("[SSEDebug] 📦 SSEMessageBody: Successfully decoded as SessionExpirationBody")
                    print("[SSEDebug]    - Exit Reason: \(sessionExpiration.exitReason)")
                    print("[SSEDebug]    - User ID: \(sessionExpiration.userId)")
                    self = .sessionExpiration(sessionExpiration)
                    return
                }

                print("[SSEDebug] ❌ SSEMessageBody: Failed to decode body as BalanceUpdate or SessionExpiration")
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unable to decode SSE message body - not BalanceUpdate or SessionExpiration"
                )
            }
        }
    }
}

