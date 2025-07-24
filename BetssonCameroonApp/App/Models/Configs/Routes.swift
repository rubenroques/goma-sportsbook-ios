//
//  Route.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//

import Foundation

enum Route {
    case openBet(id: String)
    case resolvedBet(id: String)
    case event(id: String)
    case ticket(id: String)
    case chatMessage(id: String)
    case chatNotifications
    case contactSettings
    case betSwipe
    case competition(id: String)
    case deposit
    case bonus
    case documents
    case customerSupport
    case favorites
    case promotions
    case referral(code: String)
    case responsibleForm
    case none
}
