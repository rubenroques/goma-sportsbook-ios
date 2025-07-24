//
//  UserSession.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

struct UserSession: Codable {

    var username: String
    var password: String?
    var email: String
    var userId: String
    var birthDate: String
    var avatarName: String?

    var safeUserSession: UserSession {
        return UserSession(username: self.username,
                           password: nil,
                           email: self.email,
                           userId: self.userId,
                           birthDate: self.birthDate,
                           avatarName: self.avatarName)
    }

}
