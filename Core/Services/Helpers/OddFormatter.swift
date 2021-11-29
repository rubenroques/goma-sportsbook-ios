//
//  OddFormatter.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/11/2021.
//

import Foundation

enum OddFormatter {
    static func formatOdd(withValue value: Double) -> String {
        let clippedValue = Double(floor(value * 100)/100)
        return String(format: "%.2f", clippedValue)
    }

    static func isValidOdd(withValue value: Double) -> Bool {
        let clippedValue = Double(floor(value * 100)/100)
        return clippedValue > 1.0
    }
}

