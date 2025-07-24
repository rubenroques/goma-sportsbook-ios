//
//  ReferralLink.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

public struct ReferralLink: Codable {
    
    public var code: String
    public var link: String
    
    enum CodingKeys: String, CodingKey {
        case code = "referralCode"
        case link = "referralLink"
    }
}
