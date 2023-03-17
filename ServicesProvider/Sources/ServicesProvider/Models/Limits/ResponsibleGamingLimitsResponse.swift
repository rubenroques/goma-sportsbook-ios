//
//  File.swift
//  
//
//  Created by André Lascas on 17/03/2023.
//

import Foundation

public struct ResponsibleGamingLimitsResponse: Codable {
    public var status: String
    public var limits: [String]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case limits = "limits"
    }
}
