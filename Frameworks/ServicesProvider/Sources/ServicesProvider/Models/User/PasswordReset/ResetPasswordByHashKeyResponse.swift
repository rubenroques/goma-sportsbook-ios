//
//  ResetPasswordByHashKeyResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/10/2025.
//

import Foundation

public struct ResetPasswordByHashKeyResponse: Codable {
    public let timestamp: String
    public let success: Int
    
    public init(timestamp: String, success: Int) {
        self.timestamp = timestamp
        self.success = success
    }
}

