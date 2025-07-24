//
//  SportRadarModels+Referee.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

extension SportRadarModels {
    
    struct Referee: Codable {
        
        var id: Int
        var username: String
        var registeredAt: String
        var kycStatus: String
        var depositPassed: Bool
        
        enum CodingKeys: String, CodingKey {
            case id = "partyId"
            case username = "userId"
            case registeredAt = "regDate"
            case kycStatus = "kycStatus"
            case depositPassed = "depositAmountPassed"
        }
    }
}
