//
//  BetQRCode.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 19/02/2025.
//

import Foundation

public struct BetQRCode: Codable {
    public var qrCode: String?
    public var expirationDate: String?
    public var message: String?
    
    public init(qrCode: String? = nil, expirationDate: String? = nil, message: String? = nil) {
        self.qrCode = qrCode
        self.expirationDate = expirationDate
        self.message = message
    }
}
