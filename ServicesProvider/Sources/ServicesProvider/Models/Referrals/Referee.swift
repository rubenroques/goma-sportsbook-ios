//
//  Referee.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

public struct Referee: Codable {
    
    public var id: Int
    public var username: String
    public var registeredAt: String
    public var kycStatus: String
    public var depositPassed: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "partyId"
        case username = "userId"
        case registeredAt = "regDate"
        case kycStatus = "kycStatus"
        case depositPassed = "depositAmountPassed"
    }
}
