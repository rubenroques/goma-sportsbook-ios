//
//  OutcomeBettingOfferReference.swift
//  ServicesProvider
//
//  Created by Assistant on 09/10/2025.
//

import Foundation

/// Represents the relationship between an outcome and its betting offers.
///
/// This model is used primarily for the **rebet feature** when reconstructing betting tickets
/// from historical bet data. Since historical bets only store outcome IDs, this reference
/// allows us to look up the current betting offer IDs and parent event needed to place a new bet.
///
/// ## Use Case Example
/// When a user taps "Rebet" on a historical bet, we have outcome IDs but need betting offer IDs
/// to construct the new bet ticket. This RPC resolves that mapping:
///
/// ```swift
/// // User wants to rebet a historical selection
/// let historicalOutcomeId = "281887009723020544"
///
/// eventsProvider.getBettingOfferReference(forOutcomeId: historicalOutcomeId)
///     .sink { reference in
///         // Now we can construct a new bet with:
///         // - reference.eventId → which match this is
///         // - reference.bettingOfferIds → current placeable offer IDs
///     }
/// ```
///
/// ## Lifecycle & Stability
/// - **Outcome IDs**: Stable identifiers for betting selections (e.g., "Team A to Win")
/// - **Betting Offer IDs**: May change as odds update, but represent the current placeable offer
/// - **Event ID**: Identifies the parent match/event containing this outcome
///
/// ## Relationship Hierarchy
/// ```
/// Event (Match: "Team A vs Team B")
///   └─ Market (e.g., "Match Winner")
///       └─ Outcome (e.g., "Team A")
///           └─ BettingOffer (Current odds: 1.85, available now)
/// ```
///
/// ## Important Notes
/// - If `allOffersFound` is `false`, the outcome may no longer be available for betting
/// - Betting offer IDs change when odds update, so always fetch fresh before placing bets
/// - This is a **lookup/reference** model, not persisted - always fetch when needed
public struct OutcomeBettingOfferReference: Codable, Equatable {

    /// The event ID that contains this outcome.
    ///
    /// This identifies the parent match/event where the outcome exists.
    ///
    /// **Example**: `"281887009513017344"` (match ID for "Team A vs Team B")
    public let eventId: String

    /// Array of betting offer IDs associated with this outcome.
    ///
    /// Usually contains **one offer**, but may have multiple for complex bet types.
    /// These IDs represent the current placeable offers with live odds.
    ///
    /// **Example**: `["281961032314902016"]`
    public let bettingOfferIds: [String]

    /// Indicates if all betting offers were successfully found.
    ///
    /// - `true`: All offers found, outcome is available for betting
    /// - `false`: Some/all offers missing, outcome may be closed or suspended
    ///
    /// When `false`, check `message` for details about why offers weren't found.
    public let allOffersFound: Bool

    /// Server message providing additional context about the lookup result.
    ///
    /// **Examples**:
    /// - `"All selections were added"` (success)
    /// - `"Some selections not found"` (partial failure)
    /// - `"Market is closed"` (unavailable)
    public let message: String

    /// Creates a new betting offer reference.
    ///
    /// - Parameters:
    ///   - eventId: The parent event/match ID
    ///   - bettingOfferIds: Array of current betting offer IDs for this outcome
    ///   - allOffersFound: Whether all offers were successfully resolved
    ///   - message: Server message with additional context
    public init(
        eventId: String,
        bettingOfferIds: [String],
        allOffersFound: Bool,
        message: String
    ) {
        self.eventId = eventId
        self.bettingOfferIds = bettingOfferIds
        self.allOffersFound = allOffersFound
        self.message = message
    }
}
