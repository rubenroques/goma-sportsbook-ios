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
        var limits: [ResponsibleGamingLimit]

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case limits = "limits"
        }
    }

    struct ResponsibleGamingLimit: Codable {
        var id: Int
        var partyId: Int
        var limitType: String
        var periodType: String
        var effectiveDate: String
        var expiryDate: String
        var limit: Double

        enum CodingKeys: String, CodingKey {
            case id = "responsibleGamingLimitID"
            case partyId = "partyID"
            case limitType = "limitType"
            case periodType = "periodType"
            case effectiveDate = "effectiveDate"
            case expiryDate = "expiryDate"
            case limit = "limit"
        }
    }
}
