//
//  SportRadarModels+ReferralResponse.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

extension SportRadarModels {
    
    struct ReferralResponse: Codable {
        var status: String
        var referralLinks: [ReferralLink]
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case referralLinks = "referralLinks"
        }
    }
}
