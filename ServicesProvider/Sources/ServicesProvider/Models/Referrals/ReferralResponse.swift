//
//  ReferralResponse.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

public struct ReferralResponse: Codable {
    public var status: String
    public var referralLinks: [ReferralLink]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case referralLinks = "referralLinks"
    }
}
