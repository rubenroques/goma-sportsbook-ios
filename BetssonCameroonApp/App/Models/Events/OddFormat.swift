//
//  OddFormat.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 21/07/2025.
//

import Foundation

enum OddFormat: Codable, Hashable, CustomStringConvertible, Equatable {
    case fraction(numerator: Int, denominator: Int)
    case decimal(odd: Double)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .fraction(let numerator, let denominator):
            hasher.combine("fraction")
            hasher.combine(numerator)
            hasher.combine(denominator)
        case .decimal(let odd):
            hasher.combine("decimal")
            hasher.combine(odd)
        }
    }

    var description: String {
        switch self {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            return "OddFormat \(decimal) [\(numerator)/\(denominator)]"
        case .decimal(let odd):
            return "OddFormat \(odd)"
        }

    }

    var decimalValue: Double {
        switch self {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            return decimal
        case .decimal(let odd):
            return odd
        }

    }
}
