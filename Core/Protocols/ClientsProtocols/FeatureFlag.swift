//
//  FeatureFlag.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation

protocol FeatureFlags {
    static var chatEnabled: Bool { get }
    static var showNewCheckout: Bool { get }
    static var showNewLoginScreen: Bool { get }
    static var limitCheckoutItems: Int { get }
}
