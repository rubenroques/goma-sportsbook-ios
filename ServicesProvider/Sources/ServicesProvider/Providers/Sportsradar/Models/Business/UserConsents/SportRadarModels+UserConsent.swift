//
//  SportRadarModels+UserConsent.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

extension SportRadarModels {

    struct UserConsent: Codable {
        var consentInfo: UserConsentInfo
        var consentStatus: String

        enum CodingKeys: String, CodingKey {
            case consentInfo = "consent"
            case consentStatus = "consentStatus"
        }
    }

}
