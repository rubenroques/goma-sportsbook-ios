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

    struct TargetFeatureFlags: FeatureFlags {
        static var showNewCheckout: Bool { true }
        static var showNewLoginScreen: Bool { true }
        static var limitCheckoutItems: Int { 1 }
    }
    static var featureFlags: TargetFeatureFlags.Type { TargetFeatureFlags.self }

}





