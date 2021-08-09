//
//  FeatureFlag.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/07/2021.
//

import Foundation




//protocol FeatureFlags {
//    static var low: Int { get }
//    static var high: Int { get }
//    //static var mid: Int { get }
//}

protocol Target {
    associatedtype Flags: FeatureFlags
    static var step: Int { get }
    static var flags: Flags.Type { get }
}
