import Foundation

/// Core subsystems for hierarchical log organization
///
/// Subsystems group related functionality together, making it easier to filter
/// and control logging for specific areas of the application.
///
/// Example usage:
/// ```swift
/// GomaLogger.debug(.authentication, "User logged in")
/// GomaLogger.info(.betting, category: "ODDS_BOOST", "Fetching stairs")
/// ```
public enum LogSubsystem: String, CaseIterable {
    /// Authentication, session management, SSE streams
    /// Maps to: [AUTH_DEBUG], [SSEDebug], [XTREMEPUSH]
    case authentication

    /// Betting operations, odds, betslip management
    /// Maps to: [ODDS_BOOST], [BETTING_OPTIONS], [BET_PLACEMENT], [BETSLIP_SYNC]
    case betting

    /// Network requests, API calls, connectivity
    /// Maps to: [GOMAAPI], SocketDebug, SocketSocialDebug
    case networking

    /// Real-time data updates, WebSocket subscriptions
    /// Maps to: [LIVE_SCORE], [LIVE_DATA], [WAMP]
    case realtime

    /// UI components, view controllers, view models
    /// Maps to: BLINK_DEBUG patterns
    case ui

    /// Performance tracking and monitoring
    /// Maps to: [Performance]
    case performance

    /// Payment processing, deposits, withdrawals
    /// Maps to: PaymentsDropIn patterns
    case payments

    /// Social features, chat, friends
    /// Maps to: Social service patterns
    case social

    /// Analytics and tracking events
    /// Maps to: Analytics patterns
    case analytics

    /// General purpose or uncategorized logging
    case general

    /// Human-readable description
    public var description: String {
        return rawValue.capitalized
    }
}
