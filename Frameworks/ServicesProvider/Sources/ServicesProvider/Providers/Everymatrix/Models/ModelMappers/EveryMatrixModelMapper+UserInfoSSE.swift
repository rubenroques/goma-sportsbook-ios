//
//  EveryMatrixModelMapper+UserInfoSSE.swift
//  ServicesProvider
//
//  Created on 15/01/2025.
//

import Foundation

extension EveryMatrixModelMapper {

    // MARK: - Balance Update Application

    /// Apply SSE balance update delta to existing wallet snapshot
    /// Merges afterAmount values from SSE into wallet state
    ///
    /// - Parameters:
    ///   - wallet: Current wallet state (from REST snapshot)
    ///   - updateBody: SSE balance update body with deltas
    /// - Returns: Updated wallet with new balance values
    static func applyBalanceUpdate(
        to wallet: UserWallet,
        from updateBody: EveryMatrix.BalanceUpdateBody
    ) -> UserWallet {
        var updated = wallet

        // Iterate through balance changes (Real, Bonus, etc.)
        for (walletType, change) in updateBody.balanceChange {
            let afterAmount = change.afterAmount

            if walletType == "Real" {
                // Update real balance fields (String + Double pairs)
                updated.totalString = String(format: "%.2f", afterAmount)
                updated.total = afterAmount
                updated.withdrawableString = String(format: "%.2f", afterAmount)
                updated.withdrawable = afterAmount

                print("Applied Real balance update: \(afterAmount) \(updateBody.currency)")

            } else if walletType == "Bonus" {
                // Update bonus balance fields (String + Double pairs)
                updated.bonusString = String(format: "%.2f", afterAmount)
                updated.bonus = afterAmount

                print("Applied Bonus balance update: \(afterAmount) \(updateBody.currency)")
            }
        }

        // Recalculate total (Real + Bonus) - matches WebApp logic
        let realAmount = updated.total ?? 0.0
        let bonusAmount = updated.bonus ?? 0.0
        let totalAmount = realAmount + bonusAmount

        updated.totalString = String(format: "%.2f", totalAmount)
        updated.total = totalAmount

        return updated
    }

    // MARK: - Balance Update Event Creation

    /// Create balance update event metadata from SSE message
    /// Provides transaction context for UI/analytics
    ///
    /// - Parameter body: SSE balance update body
    /// - Returns: Balance update event with transaction metadata
    static func balanceUpdateEvent(
        from body: EveryMatrix.BalanceUpdateBody
    ) -> BalanceUpdateEvent {

        // Parse ISO8601 timestamp
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.date(from: body.streamingDate) ?? Date()

        return BalanceUpdateEvent(
            transactionType: BalanceUpdateEvent.TransactionType(rawValue: body.transType) ?? .unknown,
            operationType: BalanceUpdateEvent.OperationType(rawValue: body.operationType) ?? .debit,
            currency: body.currency,
            source: body.source,
            timestamp: timestamp
        )
    }

    // MARK: - UserInfo Creation

    /// Create UserInfo from wallet and session state
    ///
    /// - Parameters:
    ///   - wallet: Current wallet state
    ///   - sessionState: Current session state
    /// - Returns: UserInfo domain model
    static func userInfo(
        wallet: UserWallet,
        sessionState: UserInfo.SessionState = .active
    ) -> UserInfo {
        return UserInfo(
            wallet: wallet,
            sessionState: sessionState,
            lastUpdated: Date()
        )
    }
}
