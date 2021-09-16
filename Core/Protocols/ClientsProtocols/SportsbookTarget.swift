//
//  CoreClientProtocol.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import Foundation

protocol SportsbookClient {

}

protocol SportsbookTarget {
    associatedtype Flags: FeatureFlags

    static var environmentType: EnvironmentType { get }

    static var gomaGamingHost: String { get }
    static var gomaGamingAuthEndpoint: String { get }

    static var firebaseDatabaseURL: String { get }

    static var everyMatrixHost: String { get }

    static var featureFlags: Flags.Type { get }
}
