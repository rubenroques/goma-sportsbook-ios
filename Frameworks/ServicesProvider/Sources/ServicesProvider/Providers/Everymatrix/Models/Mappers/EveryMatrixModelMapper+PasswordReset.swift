//
//  EveryMatrixModelMapper+PasswordReset.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/10/2025.
//

import Foundation

extension EveryMatrixModelMapper {
    
    static func resetPasswordTokenResponse(from internalResponse: EveryMatrix.ResetPasswordTokenResponse) -> ResetPasswordTokenResponse {
        return ResetPasswordTokenResponse(tokenId: internalResponse.tokenId)
    }
    
    static func validateResetPasswordCodeResponse(from internalResponse: EveryMatrix.ValidateResetPasswordCodeResponse) -> ValidateResetPasswordCodeResponse {
        return ValidateResetPasswordCodeResponse(hashKey: internalResponse.hashKey)
    }
    
    static func resetPasswordByHashKeyResponse(from internalResponse: EveryMatrix.ResetPasswordByHashKeyResponse) -> ResetPasswordByHashKeyResponse {
        return ResetPasswordByHashKeyResponse(
            timestamp: internalResponse.timestamp,
            success: internalResponse.success
        )
    }
}

