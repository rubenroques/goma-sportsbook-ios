//
//  UserSettings.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation

enum UserDefaultsKey: String {
    case theme = "appThemeKey"
    case userSession = "userSession"
}

extension UserDefaults {

    var theme: Theme {
        get {
            register(defaults: [UserDefaultsKey.theme.rawValue: Theme.device.rawValue])
            return Theme(rawValue: integer(forKey: UserDefaultsKey.theme.rawValue)) ?? .device
        }
        set {
            set(newValue.rawValue, forKey: UserDefaultsKey.theme.rawValue)
        }
    }

    var userSession: UserSession? {
        get {
            if let session = self.value(forKey: UserDefaultsKey.userSession.rawValue) as? UserSession {
                return session
            }
            return nil
        }
        set {
            set(newValue, forKey: UserDefaultsKey.userSession.rawValue)
        }
    }
}
