//
//  SportRadarModels+RefereesResponse.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

extension SportRadarModels {
    
    struct RefereesResponse: Codable {
        var status: String
        var referees: [Referee]
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case referees = "referees"
        }
    }
}
