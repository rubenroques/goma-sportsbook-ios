//
//  UserConsentType.swift
//  Sportsbook
//
//  Created by André Lascas on 12/05/2023.
//

import Foundation

enum UserConsentType {
    case sms
    case email

    var versionId: Int {
        switch self {
        case .sms:
            return 1
        case .email:
            return 2
        }
    }
}
