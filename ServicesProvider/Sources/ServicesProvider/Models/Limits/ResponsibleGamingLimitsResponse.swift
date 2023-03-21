//
//  File.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

public struct ResponsibleGamingLimitsResponse: Codable {
    public var status: String
    public var limits: [ResponsibleGamingLimit]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case limits = "limits"
    }
}

public struct ResponsibleGamingLimit: Codable {
    public var id: Int
    public var partyId: Int
    public var limitType: String
    public var periodType: String
    public var effectiveDate: String
    public var expiryDate: String
    public var limit: Double

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
