//
//  Notification.swift
//  TSSampleApp
//
//  Created by Andrei Marinescu on 09.07.2021.
//

import Foundation

extension Notification.Name {
    static let sessionConnected = Notification.Name("sessionConnected")
    static let sessionDisconnected = Notification.Name("sessionDisconnected")
    static let sessionForcedLogoutDisconnected = Notification.Name("sessionForcedLogoutDisconnected")
}
