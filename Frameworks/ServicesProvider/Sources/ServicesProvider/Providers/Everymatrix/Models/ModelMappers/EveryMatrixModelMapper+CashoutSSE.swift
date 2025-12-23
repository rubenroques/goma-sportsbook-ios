//
//  EveryMatrixModelMapper+CashoutSSE.swift
//  ServicesProvider
//
//  Created on 15/10/2025.
//

import Foundation

extension EveryMatrixModelMapper {

    // MARK: - SSE Response Mapping (Internal → Public)

    /// Convert EveryMatrix SSE response to public CashoutValue model
    ///
    /// - Parameter response: Internal SSE response model
    /// - Returns: SP Public CashoutValue model
    static func cashoutValue(fromSSEResponse response: EveryMatrix.CashoutValueSSEResponse) -> CashoutValue {
        // Extract partialCashOutEnabled from cashoutValueSettings first (like Web),
        // fall back to root level, default to true (like Web: `!== false` means nil/undefined = true)
        let partialEnabled = response.cashoutValueSettings?.partialCashOutEnabled
                          ?? response.partialCashOutEnabled
                          ?? true

        return CashoutValue(
            betId: response.betId,
            cashoutValue: response.cashoutValue,
            currentPossibleWinning: response.currentPossibleWinning,
            stake: response.stake,
            autoCashOutEnabled: response.autoCashOutEnabled ?? false,
            partialCashOutEnabled: partialEnabled,
            details: CashoutValue.CashoutDetails(
                code: response.details.code,
                message: response.details.message
            )
        )
    }

    // MARK: - Cashout Request Mapping (Public → Internal)

    /// Convert public CashoutRequest to EveryMatrix internal request model
    ///
    /// - Parameter publicRequest: SP Public cashout request
    /// - Returns: Internal request REST API model for EveryMatrix API
    static func cashoutRequest(from publicRequest: CashoutRequest) -> EveryMatrix.CashoutRequest {
        return EveryMatrix.CashoutRequest(
            betId: publicRequest.betId,
            cashoutValue: publicRequest.cashoutValue,
            cashoutType: publicRequest.cashoutType.rawValue,
            cashoutChangeAcceptance: publicRequest.cashoutChangeAcceptance,
            operatorId: EveryMatrixUnifiedConfiguration.shared.operatorId,
            language: EveryMatrixUnifiedConfiguration.shared.defaultLanguage,
            partialCashoutStake: publicRequest.partialCashoutStake
        )
    }

    // MARK: - Cashout Response Mapping (Internal → Public)

    /// Convert EveryMatrix internal response to public CashoutResponse model
    ///
    /// - Parameter internalResponse: Internal response model from EveryMatrix API
    /// - Returns: SP Public CashoutResponse model
    static func cashoutResponse(fromInternalResponse internalResponse: EveryMatrix.CashoutResponse) -> CashoutResponse {
        return CashoutResponse(
            success: internalResponse.success,
            betId: internalResponse.betId,
            requestId: internalResponse.requestId,
            cashoutValue: internalResponse.cashoutValue,
            cashoutType: internalResponse.cashoutType,
            partialCashoutStake: internalResponse.partialCashoutStake,
            cashoutPayout: internalResponse.cashoutPayout,
            pendingCashOut: internalResponse.pendingCashOut
        )
    }
}
