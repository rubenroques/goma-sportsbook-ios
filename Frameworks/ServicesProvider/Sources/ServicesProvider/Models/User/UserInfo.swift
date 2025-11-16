//
//  UserInfo.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation

/// User information container combining wallet state and session status
/// Used for real-time SSE updates from /v2/player/{userId}/information/updates
public struct UserInfo: Equatable {

    /// Current wallet balance state
    public let wallet: UserWallet

    /// Current session state
    public let sessionState: SessionState

    /// Timestamp of last update
    public let lastUpdated: Date

    /// Session state enumeration
    public enum SessionState: Equatable {
        /// Session is active and valid
        case active

        /// Session has expired
        /// - Parameter reason: Optional expiration reason from server
        case expired(reason: String?)

        /// Session was terminated (logout, force disconnect)
        case terminated
    }

    // MARK: - Initialization

    public init(
        wallet: UserWallet,
        sessionState: SessionState = .active,
        lastUpdated: Date = Date()
    ) {
        self.wallet = wallet
        self.sessionState = sessionState
        self.lastUpdated = lastUpdated
    }
}
