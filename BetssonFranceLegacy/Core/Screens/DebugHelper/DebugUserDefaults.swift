//
//  DebugUserDefaults.swift
//  Sportsbook
//
//  Created by Ruben Roques on 18/07/2023.
//

import Foundation

enum DebugDefaultsKey: String {

    case socketShouldConnect = "socketShouldConnect"
    // add more keys as per your requirements

    var key: String {
        return self.rawValue
    }

}

struct DebugUserDefaults {

    private let defaults = UserDefaults(suiteName: "com.yourcompany.yourapp.debug")!

    var socketShouldConnect: Bool {
        get {
            if let storedValue = self.defaults.value(forKey: DebugDefaultsKey.socketShouldConnect.key) as? Bool {
                return storedValue
            }
            let defaultValue = true
            self.defaults.setValue(defaultValue, forKey: DebugDefaultsKey.socketShouldConnect.key)
            self.defaults.synchronize()
            return defaultValue
        }
        set {
            self.defaults.setValue(newValue, forKey: DebugDefaultsKey.socketShouldConnect.key)
            self.defaults.synchronize()
        }
    }

}
