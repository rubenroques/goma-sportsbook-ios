//
//  EveryMatrix+ResetPassword.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/10/2025.
//

import Foundation

extension EveryMatrix {
    
    struct ResetPasswordTokenResponse: Codable {
        let tokenId: String
    }
    
    struct ValidateResetPasswordCodeResponse: Codable {
        let hashKey: String
    }

    struct ResetPasswordByHashKeyResponse: Codable {
        let timestamp: String
        let success: Int
    }
}

