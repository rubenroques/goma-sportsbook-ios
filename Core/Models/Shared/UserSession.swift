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
    var isEmailVerified: Bool
    var isProfileCompleted: Bool
    var avatarName: String?

}
