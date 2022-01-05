//
//  ClientVariables.swift
//  ShowcaseBeta
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

struct TargetVariables: SportsbookTarget {

    typealias Flags = TargetFeatureFlags

    static var environmentType: EnvironmentType = .dev

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
        "https://goma-sportsbook-dev.europe-west1.firebasedatabase.app/"
    }
    
    static var everyMatrixHost: String {
        return ""
    }

    struct TargetFeatureFlags: FeatureFlags {
        static var showNewCheckout: Bool { true }
        static var showNewLoginScreen: Bool { true }
        static var limitCheckoutItems: Int { 100 }
    }
    static var featureFlags: TargetFeatureFlags.Type { TargetFeatureFlags.self }

}
