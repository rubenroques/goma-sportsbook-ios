//
//  EveryMatrixModelMapper+WalletBalance.swift
//  ServicesProvider
//
//  Created by André Lascas on 21/08/2025.
//

import Foundation
import SharedModels

extension EveryMatrixModelMapper {
    
    /// Maps EveryMatrix wallet balance response to ServicesProvider UserWallet
    static func userWallet(fromWalletBalance walletBalance: EveryMatrix.WalletBalance) -> UserWallet {
        
        // Extract currency from any of the amount fields (they should all have the same currency)
        let currency = walletBalance.totalAmount.currency
        
        // Map the amounts
        let total = walletBalance.totalCashAmount.amount
        let totalRealAmount = walletBalance.totalRealAmount.amount
        let withdrawable = walletBalance.totalWithdrawableAmount.amount
        let bonus = walletBalance.totalBonusAmount.amount

        // Create string representations for compatibility
        let totalString = String(format: "%.2f", total)
        let totalRealAmountString = String(format: "%.2f", totalRealAmount)
        let withdrawableString = String(format: "%.2f", withdrawable)
        let bonusString = String(format: "%.2f", bonus)
        
        // Find specific wallet items for additional details
        let realItem = walletBalance.items.first { $0.type == "Real" }
        let bonusItem = walletBalance.items.first { $0.type == "Bonus" }
        let realLockedItem = walletBalance.items.first { $0.type == "RealLocked" }
        
        let realAmount = realItem?.amount ?? 0.0
        let realLockedAmount = realLockedItem?.amount ?? 0.0
        
        return UserWallet(
            vipStatus: nil, // Not available in EveryMatrix response
            currency: currency,
            loyaltyPoint: nil, // Not available in EveryMatrix response

            totalString: totalString,
            total: total,
            totalRealAmountString: totalRealAmountString,
            totalRealAmount: totalRealAmount,
            withdrawableString: withdrawableString,
            withdrawable: withdrawable,
            bonusString: bonusString,
            bonus: bonus,
            pendingBonusString: nil, // Not available in EveryMatrix response
            pendingBonus: nil,
            casinoPlayableBonusString: nil, // Not available in EveryMatrix response
            casinoPlayableBonus: nil,
            sportsbookPlayableBonusString: nil, // Not available in EveryMatrix response
            sportsbookPlayableBonus: nil,
            withdrawableEscrowString: nil, // Not available in EveryMatrix response
            withdrawableEscrow: nil,
            totalWithdrawableString: withdrawableString,
            totalWithdrawable: withdrawable,
            withdrawRestrictionAmountString: nil, // Not available in EveryMatrix response
            withdrawRestrictionAmount: nil,
            totalEscrowString: nil, // Not available in EveryMatrix response
            totalEscrow: nil
        )
    }
}

