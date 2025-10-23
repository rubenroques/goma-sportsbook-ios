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
    /// - Parameter response: Internal SSE response DTO
    /// - Returns: Public CashoutValue model
    static func cashoutValue(fromSSEResponse response: EveryMatrix.CashoutValueSSEResponse) -> CashoutValue {
        return CashoutValue(
            betId: response.betId,
            cashoutValue: response.cashoutValue,
            currentPossibleWinning: response.currentPossibleWinning,
            stake: response.stake,
            autoCashOutEnabled: response.autoCashOutEnabled ?? false,
            partialCashOutEnabled: response.partialCashOutEnabled ?? false,
            details: CashoutValue.CashoutDetails(
                code: response.details.code,
                message: response.details.message
            )
        )
    }

    // MARK: - Cashout Request Mapping (Public → Internal)

    /// Convert public CashoutRequest to EveryMatrix internal request DTO
    ///
    /// - Parameter publicRequest: Public cashout request
    /// - Returns: Internal request REST API model for EveryMatrix API
    static func cashoutRequest(from publicRequest: CashoutRequest) -> EveryMatrix.NewCashoutRequest {
        return EveryMatrix.NewCashoutRequest(
            betId: publicRequest.betId,
            cashoutValue: publicRequest.cashoutValue,
            cashoutType: publicRequest.cashoutType.rawValue,
            partialCashoutStake: publicRequest.partialCashoutStake,
            cashoutChangeAcceptanceType: publicRequest.cashoutChangeAcceptanceType
        )
    }

    // MARK: - Cashout Response Mapping (Internal → Public)

    /// Convert EveryMatrix internal response to public CashoutResponse model
    ///
    /// - Parameter internalResponse: Internal response DTO from EveryMatrix API
    /// - Returns: Public CashoutResponse model
    static func cashoutResponse(fromInternalResponse internalResponse: EveryMatrix.NewCashoutResponse) -> CashoutResponse {
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
