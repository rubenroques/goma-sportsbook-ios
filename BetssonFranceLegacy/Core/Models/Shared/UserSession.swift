//
//  UserSession.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation
import UIKit

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
