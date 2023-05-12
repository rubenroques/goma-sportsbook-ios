//
//  UserConsent.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

public struct UserConsent: Codable {
    public var consentInfo: UserConsentInfo
    public var consentStatus: UserConsentStatus? = nil
    public var consentType: UserConsentType? = nil

    enum CodingKeys: String, CodingKey {
        case consentInfo = "consent"
    }
}
