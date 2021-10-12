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
    case userSkippedLoginFlow = "userSkippedLoginFlow"
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
            return self.codable(forKey: UserDefaultsKey.userSession.rawValue)
        }
        set {
            set(codable: newValue, forKey: UserDefaultsKey.userSession.rawValue)
        }
    }

    var userSkippedLoginFlow: Bool {
        get {
            if let skipped = self.value(forKey: UserDefaultsKey.userSkippedLoginFlow.rawValue) as? Bool {
                return skipped
            }
            setValue(false, forKey: UserDefaultsKey.userSkippedLoginFlow.rawValue)
            return false
        }
        set {
            setValue(newValue, forKey: UserDefaultsKey.userSkippedLoginFlow.rawValue)
        }
    }

    func clear() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaults {
    func set<Element: Codable>(codable value: Element, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(data, forKey: key)
    }
    func codable<Element: Codable>(forKey key: String) -> Element? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }
}
