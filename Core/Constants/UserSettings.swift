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
    case userOddsFormat = "userOddsFormat"
    case cardsStyle = "cardsStyleKey"
    case cachedBetslipTickets = "cachedBetslipTickets"
    
    case bettingUserSettings = "bettingUserSettings"
    case notificationsUserSettings = "notificationsUserSettings"

    case biometricAuthentication
    case acceptedTracking

    var key: String {
        return self.rawValue
    }
}

extension UserDefaults {

    var theme: Theme {
        get {
            self.register(defaults: [UserDefaultsKey.theme.key: Theme.device.rawValue])
            return Theme(rawValue: self.integer(forKey: UserDefaultsKey.theme.key)) ?? .device
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaultsKey.theme.key)
            self.synchronize()
        }
    }

    var userSession: UserSession? {
        get {
            return self.codable(forKey: UserDefaultsKey.userSession.key)
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.userSession.key)
            self.synchronize()
        }
    }

    var userSkippedLoginFlow: Bool {
        get {
            if let skipped = self.value(forKey: UserDefaultsKey.userSkippedLoginFlow.key) as? Bool {
                return skipped
            }
            self.setValue(false, forKey: UserDefaultsKey.userSkippedLoginFlow.key)
            self.synchronize()
            return false
        }
        set {
            self.setValue(newValue, forKey: UserDefaultsKey.userSkippedLoginFlow.key)
            self.synchronize()
        }
    }
    
    var cachedBetslipTickets: [BettingTicket] {
        get {
            let bettingTickets: [BettingTicket]? = self.codable(forKey: UserDefaultsKey.cachedBetslipTickets.key)
            if let bettingTicketsValue = bettingTickets {
                return bettingTicketsValue
            }
            self.set([], forKey: UserDefaultsKey.cachedBetslipTickets.key)
            self.synchronize()
            return []
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.cachedBetslipTickets.key)
            self.synchronize()
        }
        
    }

    var userOddsFormat: OddsFormat {
        get {
            return OddsFormat(rawValue: integer(forKey: UserDefaultsKey.userOddsFormat.key)) ?? .europe
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaultsKey.userOddsFormat.key)
            self.synchronize()
        }
    }

    var bettingUserSettings: BettingUserSettings {
        get {
            let defaultValue = BettingUserSettings.defaultSettings
            let bettingUserSettings: BettingUserSettings? = self.codable(forKey: UserDefaultsKey.bettingUserSettings.key)
            
            if let bettingUserSettingsValue = bettingUserSettings {
                return bettingUserSettingsValue
            }
            else {
                self.set(codable: defaultValue, forKey: UserDefaultsKey.bettingUserSettings.key)
                self.synchronize()
                return defaultValue
            }
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.bettingUserSettings.key)
            self.synchronize()
        }
    }
    
    var notificationsUserSettings: NotificationsUserSettings {
        get {
            let defaultValue = NotificationsUserSettings.defaultSettings
            let notificationsUserSettings: NotificationsUserSettings? = self.codable(forKey: UserDefaultsKey.notificationsUserSettings.key)
            
            if let notificationsUserSettingsValue = notificationsUserSettings {
                return notificationsUserSettingsValue
            }
            else {
                self.set(codable: defaultValue, forKey: UserDefaultsKey.notificationsUserSettings.key)
                self.synchronize()
                return defaultValue
            }
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.notificationsUserSettings.key)
            self.synchronize()
        }
    }
    
    var cardsStyle: CardsStyle {
        get {
            let defaultValue = TargetVariables.defaultCardStyle
            if let skipped = self.value(forKey: UserDefaultsKey.cardsStyle.key) as? Int {
                return CardsStyle(rawValue: skipped) ?? defaultValue // Has a previous stored value, use it
            }
            else {
                self.setValue(defaultValue.rawValue, forKey: UserDefaultsKey.cardsStyle.key)
                return defaultValue
            }
        }
        set {
            self.setValue(newValue.rawValue, forKey: UserDefaultsKey.cardsStyle.key)
            self.synchronize()
        }
    }

    var biometricAuthenticationEnabled: Bool {
        get {
            if let biometric = self.value(forKey: UserDefaultsKey.biometricAuthentication.key) as? Bool {
                return biometric
            }
            self.setValue(true, forKey: UserDefaultsKey.biometricAuthentication.key)
            self.synchronize()
            return true
        }
        set {
            self.setValue(newValue, forKey: UserDefaultsKey.biometricAuthentication.key)
            self.synchronize()
        }
    }

    var acceptedTracking: Bool {
        get {
            if let acceptedTracking = self.value(forKey: UserDefaultsKey.acceptedTracking.key) as? Bool {
                return acceptedTracking
            }
            self.setValue(false, forKey: UserDefaultsKey.acceptedTracking.key)
            self.synchronize()
            return false
        }
        set {
            self.setValue(newValue, forKey: UserDefaultsKey.acceptedTracking.key)
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
        let encodedData = try? JSONEncoder().encode(value)
        UserDefaults.standard.setValue(encodedData, forKey: key)
        UserDefaults.standard.synchronize()
    }
    func codable<Element: Codable>(forKey key: String) -> Element? {
        guard let decodedData = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            let decodedObject = try JSONDecoder().decode(Element.self, from: decodedData)
            return decodedObject
        }
        catch {
            return nil
        }
        
    }
}

enum CardsStyle: Int {
    case small = 3
    case normal = 5
}

enum BetslipOddValidationType: String, CaseIterable {

    case acceptAny = "ACCEPT_ANY"
    case acceptHigher = "ACCEPT_HIGHER"
    
    static var defaultValue: BetslipOddValidationType {
        return .acceptAny
    }

    var key: String {
        return self.rawValue
    }

    var localizedDescription: String {
        switch self {
        case .acceptAny:
            return localized("accept_any")
        case .acceptHigher:
            return localized("accept_higher")
        }
    }

}
