//
//  OddFormatter.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/11/2021.
//

import Foundation

enum OddFormatter {
    static func formatOdd(withValue value: Double) -> String {
        let clippedValue = Double(ceil(value * 100)/100)
        return String(format: "%.2f", clippedValue)
    }

    static func isValidOdd(withValue value: Double) -> Bool {
        let clippedValue = Double(ceil(value * 100)/100)
        return clippedValue > 1.0
    }
}

typealias Rational = (num: Int, den: Int)

struct OddConverter {

    static func stringForValue(_ value: Float, format: OddsFormat) -> String {
        return OddConverter.stringForValue(Double(value), format: format)
    }

    static func stringForValue(_ value: Double, format: OddsFormat) -> String {

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        switch format {
        case .europe:
            return String(format: "%.2f", value)

        case .unitedKingdom:
            let rational = OddConverter.rationalApproximation(originalValue: value)
            var valueString = "\(rational.num)/\(rational.den)"
            if valueString == "33/100" {
                valueString = "1/3"
            }
            return valueString

        case .unitedStates:
            if value >= 2 {
                let valueUS = 100*(value-1)
                return String(format: "+%.0f", valueUS)
            }
            else {
                let valueUS = -100/(value-1)
                return String(format: "%.0f", valueUS)
            }
        }
    }

//        case .hongKong:
//            let number = NSNumber(value: value-1)
//            return String(formatter.string(from: number) ?? String(format: "%.2f", number))
//
//        case .indo:
//            let valueMinus = value-1
//            var newValue = valueMinus
//            if valueMinus >= 1 {
//                newValue = valueMinus
//            }
//            else {
//                newValue = ((1/valueMinus) * -1)
//            }
//            let number = NSNumber(value: newValue)
//            return String(formatter.string(from: number) ?? String(format: "%.2f", number))
//
//        case .malay:
//            let valueMinus = value-1
//            if valueMinus <= 1 {
//                return String(format: "%.2f", valueMinus)
//            }
//            else {
//                return String(format: "%.2f", ((1/valueMinus) * -1) )
//            }
//
//        case .probability:
//            return String(format: "%.2f%%", (1/value)*100)
//        }
//    }

    // swiftlint:disable identifier_name
    static func rationalApproximation(originalValue value: Double, withPrecision eps: Double = 1.0E-6) -> Rational {
        var x = value-1
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)

        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
    // swiftlint:enable identifier_name
}
