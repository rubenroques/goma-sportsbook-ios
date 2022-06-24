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
    case userBetslipSettings = "user_betslip_settings"
    case userOddsFormat = "userOddsFormat"
    case cardsStyle = "cardsStyleKey"
    case cachedBetslipTickets = "cachedBetslipTickets"
}

extension UserDefaults {

    var theme: Theme {
        get {
            self.register(defaults: [UserDefaultsKey.theme.rawValue: Theme.device.rawValue])
            return Theme(rawValue: self.integer(forKey: UserDefaultsKey.theme.rawValue)) ?? .device
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaultsKey.theme.rawValue)
        }
    }

    var userSession: UserSession? {
        get {
            return self.codable(forKey: UserDefaultsKey.userSession.rawValue)
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.userSession.rawValue)
        }
    }

    var userSkippedLoginFlow: Bool {
        get {
            if let skipped = self.value(forKey: UserDefaultsKey.userSkippedLoginFlow.rawValue) as? Bool {
                return skipped
            }
            self.setValue(false, forKey: UserDefaultsKey.userSkippedLoginFlow.rawValue)
            return false
        }
        set {
            self.setValue(newValue, forKey: UserDefaultsKey.userSkippedLoginFlow.rawValue)
        }
    }

    var userBetslipSettings: String {
        get {
            return self.string(forKey: "user_betslip_settings") ?? ""
        }
        set {
            self.setValue(newValue, forKey: "user_betslip_settings")
        }
    }
    
    var cachedBetslipTickets: [BettingTicket] {
        get {
            if let array = self.value(forKey: "cachedBetslipTickets") {
                return array as! [BettingTicket]
            }else{
                return []
            }
        }
        set {
            self.setValue(newValue, forKey: "cachedBetslipTickets")
        }
    }

    var userOddsFormat: OddsFormat {
        get {
            register(defaults: [UserDefaultsKey.userOddsFormat.rawValue: OddsFormat.europe.rawValue])
            return OddsFormat(rawValue: integer(forKey: UserDefaultsKey.userOddsFormat.rawValue)) ?? .europe
        }
        set {
            set(newValue.rawValue, forKey: UserDefaultsKey.userOddsFormat.rawValue)
        }
    }

    var cardsStyle: CardsStyle {
        get {
            let defaultValue = TargetVariables.defaultCardStyle
            if let skipped = self.value(forKey: UserDefaultsKey.cardsStyle.rawValue) as? Int {
                return CardsStyle(rawValue: skipped) ?? defaultValue // Has a previous stored value, use it
            }
            else {
                self.setValue(defaultValue.rawValue, forKey: UserDefaultsKey.cardsStyle.rawValue)
                return defaultValue
            }
        }
        set {
            self.setValue(newValue.rawValue, forKey: UserDefaultsKey.cardsStyle.rawValue)
            self.synchronize()
        }
    }

    func clear() {
        let domain = Bundle.main.bundleIdentifier!
        self.removePersistentDomain(forName: domain)
        self.synchronize()
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

enum CardsStyle: Int {
    case small = 3
    case normal = 5
}
