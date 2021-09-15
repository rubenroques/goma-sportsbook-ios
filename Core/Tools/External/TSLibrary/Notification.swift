//
//  Notification.swift
//  TSSampleApp
//
//  Created by Andrei Marinescu on 09.07.2021.
//

import Foundation

extension Notification.Name {
    static let wampSocketConnected = Notification.Name("TSConnected")
    static let wampSocketDisconnected = Notification.Name("TSDisconnected")
}
