//
//  UserConsent.swift
//  
//
//  Created by André Lascas on 09/05/2023.
//

import Foundation

public struct UserConsent: Hashable {
    public var info: UserConsentInfo
    public var status: UserConsentStatus
    public var type: UserConsentType
}
