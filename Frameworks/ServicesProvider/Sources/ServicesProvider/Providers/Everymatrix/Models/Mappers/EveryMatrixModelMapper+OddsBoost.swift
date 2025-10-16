//
//  EveryMatrixModelMapper+OddsBoost.swift
//  ServicesProvider
//
//  Created by Claude on 15/10/2025.
//

import Foundation

extension EveryMatrixModelMapper {

    /// Maps EveryMatrix odds boost wallet response to domain model
    ///
    /// - Parameters:
    ///   - response: Raw EveryMatrix bonus wallet response
    ///   - userCurrency: User's currency code (e.g., "XAF", "EUR")
    /// - Returns: Mapped odds boost stairs response, or nil if no bonus available
    static func oddsBoostStairsResponse(from response: EveryMatrix.OddsBoostWalletResponse) -> OddsBoostStairsResponse? {

        // Extract first item from items array
        guard let firstItem = response.items.first else {
            return nil
        }

        // Extract oddsBoost info (only present when combination parameter is provided)
        guard let oddsBoostInfo = firstItem.oddsBoost else {
            return nil
        }

        // Map current stair
        let currentStair: OddsBoostStair? = oddsBoostInfo.currentStair.flatMap { internalStair in
            guard let capAmount = internalStair.capAmount[firstItem.currency] else {
                return nil
            }
            return OddsBoostStair(
                minSelectionNumber: internalStair.minSelectionNumber,
                percentage: internalStair.percentage,
                capAmount: capAmount
            )
        }

        // Map next stair
        let nextStair: OddsBoostStair? = oddsBoostInfo.nextStair.flatMap { internalStair in
            guard let capAmount = internalStair.capAmount[firstItem.currency] else {
                return nil
            }
            return OddsBoostStair(
                minSelectionNumber: internalStair.minSelectionNumber,
                percentage: internalStair.percentage,
                capAmount: capAmount
            )
        }

        // Extract UBS Wallet ID - critical for bet placement
        let ubsWalletId = String(firstItem.id)

        // Extract eligible event IDs
        let eligibleEventIds = oddsBoostInfo.eligibleEventID

        // Build domain response
        return OddsBoostStairsResponse(
            currentStair: currentStair,
            nextStair: nextStair,
            eligibleEventIds: eligibleEventIds,
            ubsWalletId: ubsWalletId,
            currency: firstItem.currency
        )
    }
}
