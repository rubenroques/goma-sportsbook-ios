//
//  UserConsent.swift
//  Sportsbook
//
//  Created by André Lascas on 12/05/2023.
//

import Foundation

struct UserConsent {
    var id: Int
    var consentVersionId: Int
    var name: String
    var key: String
    var consentStatus: UserConsentStatus
    var consentType: UserConsentType

}
