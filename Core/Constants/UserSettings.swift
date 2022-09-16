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
    case betslipOddValidationType = "betslipOddValidationType"
    case userOddsFormat = "userOddsFormat"
    case cardsStyle = "cardsStyleKey"
    case cachedBetslipTickets = "cachedBetslipTickets"
    
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
        }
    }

    var userSession: UserSession? {
        get {
            return self.codable(forKey: UserDefaultsKey.userSession.key)
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.userSession.key)
        }
    }

    var userSkippedLoginFlow: Bool {
        get {
            if let skipped = self.value(forKey: UserDefaultsKey.userSkippedLoginFlow.key) as? Bool {
                return skipped
            }
            self.setValue(false, forKey: UserDefaultsKey.userSkippedLoginFlow.key)
            return false
        }
        set {
            self.setValue(newValue, forKey: UserDefaultsKey.userSkippedLoginFlow.key)
        }
    }

    var userBetslipSettings: BetslipOddValidationType {
        get {
            let defaultValue = BetslipOddValidationType.defaultValue
            if let type = self.value(forKey: UserDefaultsKey.betslipOddValidationType.key) as? String {
                return BetslipOddValidationType(rawValue: type) ?? defaultValue // Has a previous stored value, use it
            }
            else {
                self.setValue(defaultValue.rawValue, forKey: UserDefaultsKey.cardsStyle.key)
                return defaultValue
            }
        }
        set {
            self.setValue(newValue.rawValue, forKey: UserDefaultsKey.betslipOddValidationType.key)
        }
    }
    
    var cachedBetslipTickets: [BettingTicket] {
        
        get {
            
            let bettingTickets: [BettingTicket]? = self.codable(forKey: UserDefaultsKey.cachedBetslipTickets.key)
            
            if let bettingTicketsValue = bettingTickets {
                return bettingTicketsValue
            }
            
            self.set([], forKey: UserDefaultsKey.cachedBetslipTickets.key)
            return []
        }
        set {
            self.set(codable: newValue, forKey: UserDefaultsKey.cachedBetslipTickets.key)
        }
        
    }

    var userOddsFormat: OddsFormat {
        get {
            return OddsFormat(rawValue: integer(forKey: UserDefaultsKey.userOddsFormat.key)) ?? .europe
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaultsKey.userOddsFormat.key)
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

enum BetslipOddValidationType: String {
    case acceptAny = "ACCEPT_ANY"
    case acceptHigher = "ACCEPT_HIGHER"
    
    static var defaultValue: BetslipOddValidationType {
        return .acceptAny
    }
}
 
