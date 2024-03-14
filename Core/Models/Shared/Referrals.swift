//
//  Referrals.swift
//  Sportsbook
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

struct ReferralLink {
    
    let code: String
    let link: String
}

struct Referee {
    let id: Int
    let username: String
    let registeredAt: String
    let kycStatus: KnowYourCustomerStatus
    let depositPassed: Bool
}
