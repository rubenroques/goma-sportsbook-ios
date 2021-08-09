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

    struct TargetFeatureFlags: FeatureFlags {
        static var showNewCheckout: Bool { true }
        static var showNewLoginScreen: Bool { true }
        static var limitCheckoutItems: Int { 100 }
    }
    static var featureFlags: TargetFeatureFlags.Type { TargetFeatureFlags.self }

}
