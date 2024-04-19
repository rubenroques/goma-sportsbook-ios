//
//  UserConsentType.swift
//  Sportsbook
//
//  Created by André Lascas on 12/05/2023.
//

import Foundation

enum UserConsentType: Hashable {
    case sms
    case email
    case terms
    case unknown
    
    var versionId: Int {
        switch self {
        case .sms:
            return 1
        case .email:
            return 2
        case .terms:
            return 3
        case .unknown:
            return -1
        }
    }
}
