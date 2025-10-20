//
//  ValidateResetPasswordCodeResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/10/2025.
//

import Foundation

public struct ValidateResetPasswordCodeResponse: Codable {
    public let hashKey: String
    
    public init(hashKey: String) {
        self.hashKey = hashKey
    }
}

