//
//  SportRadarModels+ReferralLink.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

extension SportRadarModels {
    
    struct ReferralLink: Codable {
        
        var code: String
        var link: String
        
        enum CodingKeys: String, CodingKey {
            case code = "referralCode"
            case link = "referralLink"
        }
    }
}
