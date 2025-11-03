//
//  EveryMatrixModelMapper+BettingOptions.swift
//  ServicesProvider
//
//  Model mapper for BettingOptionsV2 responses
//

import Foundation

extension EveryMatrixModelMapper {

    /// Maps EveryMatrix BettingOptionsV2 response to domain UnifiedBettingOptions model
    static func unifiedBettingOptions(
        from response: EveryMatrix.BettingOptionsV2Response
    ) -> UnifiedBettingOptions {

        // Map free bets
        let freeBets = (response.freeBets ?? []).map { fb in
            FreeBetInfo(
                id: fb.id,
                amount: fb.amount,
                minOdds: fb.minOdds,
                maxOdds: fb.maxOdds,
                currency: fb.currency,
                expiryDate: fb.expiryDate
            )
        }

        // Map odds boosts
        let oddsBoosts = (response.oddsBoosts ?? []).map { ob in
            OddsBoostInfo(
                walletId: ob.walletId,
                percentage: ob.percentage,
                capAmount: ob.capAmount,
                minSelections: ob.minSelections,
                maxSelections: ob.maxSelections,
                minOddsPerSelection: ob.minOddsPerSelection
            )
        }

        // Map stake backs
        let stakeBacks = (response.stakeBacks ?? []).map { sb in
            StakeBackInfo(
                percentage: sb.percentage,
                amount: sb.amount,
                currency: sb.currency,
                minStake: sb.minStake,
                maxStake: sb.maxStake
            )
        }

        // Map bet builders
        let betBuilders = (response.betBuilder ?? []).map { bb in
            let selections = (bb.selections ?? []).map { sel in
                BetBuilderSelectionInfo(
                    bettingOfferId: sel.bettingOfferId,
                    outcomeId: sel.outcomeId,
                    bettingTypeId: sel.bettingTypeId,
                    priceValue: sel.priceValue,
                    banker: sel.banker
                )
            }
            return BetBuilderInfo(
                selections: selections,
                betBuilderOdds: bb.betBuilderOdds
            )
        }

        // Map forbidden combinations
        let forbiddenCombinations = (response.forbiddenCombinations ?? []).map { fc in
            let selections = (fc.selections ?? []).map { sel in
                ForbiddenCombinationSelectionInfo(
                    bettingOfferId: sel.bettingOfferId,
                    outcomeId: sel.outcomeId,
                    bettingTypeId: sel.bettingTypeId,
                    priceValue: sel.priceValue,
                    banker: sel.banker
                )
            }
            return ForbiddenCombinationInfo(selections: selections)
        }

        return UnifiedBettingOptions(
            isValid: response.success ?? false,
            minStake: response.minStake,
            maxStake: response.maxStake,
            totalOdds: response.priceValueFactor,
            maxWinning: response.maxWinningAndTaxes?.maxWinning,
            availableFreeBets: freeBets,
            availableOddsBoosts: oddsBoosts,
            availableStakeBacks: stakeBacks,
            betBuilders: betBuilders,
            forbiddenCombinations: forbiddenCombinations,
            manualBetRequestAllowed: response.availableForManualBetRequest ?? true,
            taxEnabled: response.maxWinningAndTaxes?.taxEnabled ?? false
        )
    }
}
