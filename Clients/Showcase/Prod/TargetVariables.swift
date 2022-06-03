//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {

    typealias Flags = TargetFeatureFlags

    #if DEBUG
    static var environmentType: EnvironmentType = .dev
    #else
    static var environmentType: EnvironmentType = .prod
    #endif

    static var gomaGamingHost: String {
        return "https://sportsbook-api.gomagaming.com"
    }

    static var gomaGamingAnonymousAuthEndpoint: String {
        "https://sportsbook-api.gomagaming.com/api/auth/v1"
    }

    static var gomaGamingLoggedAuthEndpoint: String {
        "https://sportsbook-api.gomagaming.com/api/auth/v1/login"
    }

    static var firebaseDatabaseURL: String {
        #if DEBUG
        "https://goma-sportsbook-ios-dev.europe-west1.firebasedatabase.app/"
        #else
        "https://goma-sportsbook-dev.europe-west1.firebasedatabase.app/"
        // "ht tps://goma-sportsbook.europe-west1.firebasedatabase.app/"
        #endif
    }

    static var homeTemplateKey: String? {
        return nil
    }

    static var everyMatrixHost: String {
        return ""
    }

    struct TargetFeatureFlags: FeatureFlags {
        static var showNewCheckout: Bool { true }
        static var showNewLoginScreen: Bool { true }
        static var limitCheckoutItems: Int { 1 }
    }
    static var featureFlags: TargetFeatureFlags.Type { TargetFeatureFlags.self }

    static var supportedThemes: [Theme] {
        return Theme.allCases
    }

    static var defaultCardStyle: CardsStyle {
        return .normal
    }

}
