//
//  EveryMatrixModelMapper+BettingOfferReference.swift
//  ServicesProvider
//
//  Created by Assistant on 09/10/2025.
//

import Foundation

extension EveryMatrixModelMapper {

    /// Converts EveryMatrix betting offer reference response to facade model.
    ///
    /// This mapper extracts the single event-to-betting-offers mapping from the
    /// EveryMatrix API response and converts it to the public domain model.
    ///
    /// ## Expected Response Structure
    /// For a single outcome ID lookup, the response contains one entry mapping
    /// the event ID to its betting offer IDs:
    ///
    /// ```json
    /// {
    ///   "bettingOfferIdsByEventId": {
    ///     "281887009513017344": ["281961032314902016"]
    ///   },
    ///   "allBettingOffersFound": true,
    ///   "message": "All selections were added"
    /// }
    /// ```
    ///
    /// ## Mapping Logic
    /// 1. Extracts the first (and typically only) entry from the dictionary
    /// 2. Maps event ID and betting offer IDs to facade model
    /// 3. Preserves success flag and message
    ///
    /// - Parameter response: Raw EveryMatrix API response
    /// - Returns: Mapped facade model, or `nil` if response contains no data
    static func outcomeBettingOfferReference(
        fromResponse response: EveryMatrix.BettingOfferReferenceResponse
    ) -> OutcomeBettingOfferReference? {

        // Extract the single event ID and its betting offers
        // Response should have exactly one entry for single outcome lookup
        guard let (eventId, bettingOfferIds) = response.bettingOfferIdsByEventId.first else {
            print("[EveryMatrixModelMapper] ❌ No betting offer mapping found in response")
            return nil
        }

        // Validate that we have betting offer IDs
        guard !bettingOfferIds.isEmpty else {
            print("[EveryMatrixModelMapper] ⚠️ Event \(eventId) has no betting offer IDs")
            // Still return the reference even if empty - allOffersFound will indicate failure
            return nil
        }

        print("[EveryMatrixModelMapper] ✅ Mapped outcome reference: event=\(eventId), offers=\(bettingOfferIds.count)")

        return OutcomeBettingOfferReference(
            eventId: eventId,
            bettingOfferIds: bettingOfferIds,
            allOffersFound: response.allBettingOffersFound,
            message: response.message
        )
    }
}
