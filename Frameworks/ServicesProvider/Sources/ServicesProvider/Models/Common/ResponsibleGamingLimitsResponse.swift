//
//  ResponsibleGamingLimitsResponse.swift
//  ServicesProvider
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

public struct ResponsibleGamingLimitsResponse: Codable {
    public var status: String
    public var limits: [ResponsibleGamingLimit]
}

public struct ResponsibleGamingLimit: Codable {
    public var id: Int
    public var partyId: Int
    public var limitType: String
    public var periodType: String
    public var effectiveDate: String
    public var expiryDate: String
    public var limit: Double
}
