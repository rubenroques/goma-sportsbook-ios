//
//  UserDefaultsKey.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//


import Foundation

enum UserDefaultsKey: String {

    case appearanceMode = "appThemeKey"
    case userSession = "userSession"
    case userSkippedLoginFlow = "userSkippedLoginFlow"
    case userOddsFormat = "userOddsFormat"
    case cardsStyle = "cardsStyleKey"
    case cachedBetslipTickets = "cachedBetslipTickets"

    case bettingUserSettings = "bettingUserSettings"
    case notificationsUserSettings = "notificationsUserSettings"

    case biometricAuthentication
    case acceptedTracking = "acceptedTrackingKey"

    case oddsValueType = "oddsValueType"

    var key: String {
        return self.rawValue
    }
}

extension UserDefaults {
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension UserDefaults {

    var appearanceMode: AppearanceMode {
        get {
            if let appearanceModeInt = self.value(forKey: UserDefaultsKey.appearanceMode.key) as? Int {
                return AppearanceMode(rawValue: appearanceModeInt) ?? .device
            }

            self.setValue(AppearanceMode.dark.rawValue, forKey: UserDefaultsKey.appearanceMode.key)
            self.synchronize()
            return .dark
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaultsKey.appearanceMode.key)
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
            let defaultValue = [BettingTicket]()
            let bettingTickets: [BettingTicket]? = self.codable(forKey: UserDefaultsKey.cachedBetslipTickets.key)
            if let bettingTicketsValue = bettingTickets {
                return bettingTicketsValue
            }

            self.set(defaultValue, forKey: UserDefaultsKey.cachedBetslipTickets.key)
            self.synchronize()
            return defaultValue
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

    func clear() {
        let domain = Env.bundleId
        self.removePersistentDomain(forName: domain)
        self.synchronize()
    }

}

extension UserDefaults {
    static func appendToReadInstaStoriesArray(_ newStory: String) {
        let key = "readInstaStoriesArray"
        var existingStories = UserDefaults.standard.stringArray(forKey: key) ?? []
        existingStories.append(newStory)
        UserDefaults.standard.set(existingStories, forKey: key)
    }

    static func checkStoryInReadInstaStoriesArray(_ storyToCheck: String) -> Bool {
        let key = "readInstaStoriesArray"
        let existingStories = UserDefaults.standard.stringArray(forKey: key) ?? []
        return existingStories.contains(storyToCheck)
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
