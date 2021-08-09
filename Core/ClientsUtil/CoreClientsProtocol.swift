//
//  CoreClientProtocol.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

protocol SportsbookClient {

}

protocol FeatureFlags {
    static var showNewCheckout: Bool { get }
    static var showNewLoginScreen: Bool { get }
    static var limitCheckoutItems: Int { get }
}

protocol SportsbookTarget {
    associatedtype Flags: FeatureFlags

    static var environmentType: EnvironmentType { get }

    static var featureFlags: Flags.Type { get }
}


//      protocol Target {
//          static var targetName: String { get }
//          static var environmentType: EnvironmentType { get }
//
//          static var featureFlags: FeatureFlags { get }
//      }
//
//      typealias FeatureFlags = (showNewCheckout: Bool,
//                                showNewLoginScreen: Bool,
//                                limitCheckoutItems: Int)
