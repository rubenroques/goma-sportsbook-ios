//
//  AuthToken.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

struct AuthToken: Decodable {
    let userId: Int
    let hash: String
    let expiresIn: TimeInterval

    var isValid: Bool {
        return true
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case hash = "access_token"
        case expiresIn = "expires_in"
    }
}
