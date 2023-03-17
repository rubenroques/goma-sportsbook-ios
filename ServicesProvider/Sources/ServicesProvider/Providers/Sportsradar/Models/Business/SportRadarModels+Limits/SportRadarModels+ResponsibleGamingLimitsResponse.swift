//
//  SportRadarModels+ResponsibleGamingLimitsResponse.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

extension SportRadarModels {

    struct ResponsibleGamingLimitsResponse: Codable {
        var status: String
        var limits: [String]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case limits = "limits"
        }
    }
}
