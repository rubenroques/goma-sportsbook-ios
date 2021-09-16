//
//  UserSessionStore.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/09/2021.
//

import Foundation

struct UserSessionStore {

    static func loggedUserSession() -> UserSession? {
        return UserDefaults.standard.userSession
    }

    static func isUserLogged() -> Bool {
        return UserDefaults.standard.userSession != nil
    }

    func cacheUserSession(userSession: UserSession) {
        UserDefaults.standard.userSession = userSession
    }

    func logout() {
        UserDefaults.standard.userSession = nil
    }

    
}
