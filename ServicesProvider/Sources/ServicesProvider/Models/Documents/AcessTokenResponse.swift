//
//  File.swift
//  
//
//  Created by André Lascas on 12/06/2023.
//

import Foundation

public struct AccessTokenResponse: Codable {
    public var token: String?
    public var userId: String?
    public var description: String?
    public var code: Int?

    enum CodingKeys: String, CodingKey {
        case token = "token"
        case userId = "userId"
        case description = "description"
        case code = "code"
    }
}
