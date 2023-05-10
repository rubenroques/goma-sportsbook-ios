//
//  UserConsent.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

public struct UserConsent: Codable {
    public var consentInfo: UserConsentInfo
    public var consentStatus: String

    enum CodingKeys: String, CodingKey {
        case consentInfo = "consent"
        case consentStatus = "consentStatus"
    }
}
