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
        "http://34.141.102.89"
    }

    static var gomaGamingAuthEndpoint: String {
        "http://34.141.102.89/api/auth/v1"
    }

    static var firebaseDatabaseURL: String {
        #if DEBUG
        "https://goma-sportsbook-dev.europe-west1.firebasedatabase.app/"
        #else
        "https://goma-sportsbook.europe-west1.firebasedatabase.app/"
        #endif
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

}
