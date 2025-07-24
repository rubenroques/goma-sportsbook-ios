//
//  RefereesResponse.swift
//
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation

public struct RefereesResponse: Codable {
    public var status: String
    public var referees: [Referee]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case referees = "referees"
    }
}
