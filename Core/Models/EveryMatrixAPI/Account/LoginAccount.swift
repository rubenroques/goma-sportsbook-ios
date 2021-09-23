//
//  LoginAccount.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/09/2021.
//

import Foundation

struct LoginAccount: Decodable {

    let username: String
    let isProfileIncomplete: Bool
    let isEmailVerified: Bool

    enum CodingKeys: String, CodingKey {
        case username = "username"
        case isProfileIncomplete = "isProfileIncomplete"
        case isEmailVerified = "isEmailVerified"
    }
}

struct SessionInfo: Decodable {

    var userID: Int
    var username: String
    var firstname: String
    var surname: String
    var email: String
    var birthDate: String
    var currency: String
    var userCountry: String
    var ipCountry: String

    var isEmailVerified: Bool
    var isAuthenticated: Bool

    var loginDateTime: String?
    var lastLoginDateTime: String?

    var requiredTermsAndConditions: [Int]?
    var roles: [String]?

    enum CodingKeys: String, CodingKey {

        case userID = "userID"
        case username = "username"
        case firstname = "firstname"
        case surname = "surname"
        case email = "email"
        case birthDate = "birthDate"
        case currency = "currency"
        case userCountry = "userCountry"
        case ipCountry = "ipCountry"
        case isEmailVerified = "isEmailVerified"
        case isAuthenticated = "isAuthenticated"
        case loginDateTime = "loginTime"
        case lastLoginDateTime = "lastLoginTime"

        case requiredTermsAndConditions = "requiredTermsAndConditions"
        case roles = "roles"
    }
}
