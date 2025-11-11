//
//  EveryMatrix+BettingOfferReference.swift
//  ServicesProvider
//
//  Created on 09/10/2025.
//

import Foundation

extension EveryMatrix {

    /// Raw response from `/sports#oddsByOutcomes` RPC endpoint.
    ///
    /// This internal model represents the EveryMatrix API response when looking up
    /// betting offers by outcome IDs. It maps event IDs to their associated betting offer IDs.
    ///
    /// **API Endpoint**: `/sports#oddsByOutcomes`
    ///
    /// **Request Format**:
    /// ```json
    /// {
    ///   "lang": "en",
    ///   "outcomeIds": ["281887009723020544"]
    /// }
    /// ```
    ///
    /// **Response Format**:
    /// ```json
    /// {
    ///   "bettingOfferIdsByEventId": {
    ///     "281887009513017344": ["281961032314902016"]
    ///   },
    ///   "allBettingOffersFound": true,
    ///   "message": "All selections were added"
    /// }
    /// ```
    struct BettingOfferReferenceResponse: Codable {

        /// Dictionary mapping event IDs to arrays of betting offer IDs.
        ///
        /// For a single outcome lookup, this typically contains one entry.
        /// The key is the event ID, and the value is an array of betting offer IDs
        /// associated with the requested outcome within that event.
        ///
        /// **Example**: `{"281887009513017344": ["281961032314902016"]}`
        let bettingOfferIdsByEventId: [String: [String]]

        /// Indicates whether all requested betting offers were found.
        ///
        /// - `true`: All offers successfully located
        /// - `false`: Some or all offers could not be found (market closed, suspended, etc.)
        let allBettingOffersFound: Bool

        /// Server-provided message with additional context about the lookup result.
        ///
        /// Common values:
        /// - `"All selections were added"` - Success
        /// - `"Some selections not found"` - Partial failure
        let message: String
    }
}
