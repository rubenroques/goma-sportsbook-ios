//
//  UserDefaults.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation

extension Notification.Name {
    static let didMoveToInvalidLocation = Notification.Name("didMoveToInvalidLocation")
    static let didMoveToValidLocation = Notification.Name("didMoveToValidLocation")
    static let didChangeAppTheme = Notification.Name("didChangeAppTheme")
}

extension NotificationCenter {
    func post(_ name: Notification.Name) {
        self.post(name: name, object: nil)
    }
}

extension UserDefaults {
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
