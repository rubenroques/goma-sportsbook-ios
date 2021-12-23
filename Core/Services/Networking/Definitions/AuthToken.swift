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
    let expiresDate: TimeInterval

    var isValid: Bool {
        return Date().timeIntervalSince1970 < self.expiresDate
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case hash = "access_token"
        case expiresDate = "expires_in"
    }
}
