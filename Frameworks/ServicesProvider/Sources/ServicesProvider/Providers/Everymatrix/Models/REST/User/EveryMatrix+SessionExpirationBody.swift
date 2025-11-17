//
//  EveryMatrix+SessionExpirationBody.swift
//  ServicesProvider
//
//  Created on 16/11/2025.
//

import Foundation

extension EveryMatrix {

    /// SESSION_EXPIRATION or SESSION_EXPIRATION_V2 message body structure
    /// Represents a session termination event from SSE stream
    struct SessionExpirationBody: Decodable {

        /// User ID whose session expired
        let userId: String

        /// Session ID that expired
        let sessionId: String

        /// Human-readable exit reason (e.g., "Expired", "Logout", "Kicked")
        let exitReason: String

        /// Exit reason code
        /// 1 = Expired (timeout)
        /// 2 = Manual logout
        /// 3 = Kicked by system
        /// (codes may vary by backend implementation)
        let exitReasonCode: Int

        /// Login timestamp (ISO8601 format, optional)
        let loginTime: String?

        /// Logout timestamp (ISO8601 format, optional)
        let logoutTime: String?

        /// Source system name (e.g., "NWA", "GmSlim")
        let sourceName: String
    }
}
