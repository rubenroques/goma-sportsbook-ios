//
//  ResetPasswordTokenResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 16/10/2025.
//

import Foundation

public struct ResetPasswordTokenResponse: Codable {
    public let tokenId: String
    
    public init(tokenId: String) {
        self.tokenId = tokenId
    }
}

