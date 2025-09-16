//
//  EveryMatrixModelMapper+Cashier.swift
//  ServicesProvider
//
//  Created by Banking Implementation on 10/09/2025.
//

import Foundation

extension EveryMatrixModelMapper {
    
    // MARK: - CashierWebViewResponse Mapping
    
    /// Maps EveryMatrix GetPaymentSession response to ServicesProvider CashierWebViewResponse
    static func cashierWebViewResponse(from response: EveryMatrix.GetPaymentSessionResponse) -> CashierWebViewResponse {
        return CashierWebViewResponse(
            webViewURL: response.cashierInfo.url,
            responseCode: response.responseCode,
            requestId: response.requestId
        )
    }
    
    // MARK: - CashierParameters Mapping
    
    /// Maps ServicesProvider CashierParameters to EveryMatrix GetPaymentSession request
    static func getPaymentSessionRequest(from parameters: CashierParameters) -> EveryMatrix.GetPaymentSessionRequest {
        return EveryMatrix.GetPaymentSessionRequest(
            channel: parameters.channel,
            type: parameters.type,
            successUrl: parameters.successUrl,
            cancelUrl: parameters.cancelUrl,
            failUrl: parameters.failUrl,
            language: parameters.language,
            productType: parameters.productType,
            currency: parameters.currency,
            isShortCashier: parameters.isShortCashier,
            bonusCode: parameters.bonusCode,
            showBonusSelectionInput: parameters.showBonusSelectionInput
        )
    }
}