//
//  ServiceProviderModelMapper+OddsBoost.swift
//  BetssonCameroonApp
//
//  Created by Claude on 16/10/2025.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {

    /// Maps ServicesProvider odds boost stairs response to app model
    /// - Parameter spResponse: ServicesProvider OddsBoostStairsResponse
    /// - Returns: App-specific OddsBoostStairsState model
    static func oddsBoostStairsState(
        fromServiceProviderResponse spResponse: ServicesProvider.OddsBoostStairsResponse
    ) -> OddsBoostStairsState {

        // Map current tier
        let currentTier: OddsBoostTier? = spResponse.currentStair.map { spStair in
            OddsBoostTier(
                minSelections: spStair.minSelectionNumber,
                percentage: spStair.percentage,
                capAmount: spStair.capAmount
            )
        }

        // Map next tier
        let nextTier: OddsBoostTier? = spResponse.nextStair.map { spStair in
            OddsBoostTier(
                minSelections: spStair.minSelectionNumber,
                percentage: spStair.percentage,
                capAmount: spStair.capAmount
            )
        }

        return OddsBoostStairsState(
            currentTier: currentTier,
            nextTier: nextTier,
            eligibleEventIds: spResponse.eligibleEventIds,
            ubsWalletId: spResponse.ubsWalletId,
            currency: spResponse.currency
        )
    }
}
