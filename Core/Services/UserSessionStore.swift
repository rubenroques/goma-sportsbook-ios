//
//  UserSessionStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation

struct UserSessionStore {

    static func userLogged() -> UserSession? {
        return UserDefaults.standard.userSession
    }

    static func isUserLogged() -> Bool {
        return UserDefaults.standard.userSession != nil
    }

}
