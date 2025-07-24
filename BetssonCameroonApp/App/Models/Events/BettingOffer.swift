//
//  BettingOffer.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//

import Foundation

struct BettingOffer: Hashable {

    var id: String

    var statusId: String
    var isLive: Bool
    var isAvailable: Bool

    var odd: OddFormat

    var decimalOdd: Double {
        switch self.odd {
        case .fraction(let numerator, let denominator):
            let decimal = (Double(numerator)/Double(denominator)) + 1.0
            if decimal.isNaN {
                return decimal
            }
            else {
                return decimal
            }
        case .decimal(let odd):
            return odd
        }
    }

    var fractionalOdd: (numerator: Int, denominator: Int) {
        switch self.odd {
        case .fraction(let numerator, let denominator):
            return (numerator, denominator)
        case .decimal(let odd):
            let rational = OddConverter.rationalApproximation(originalValue: odd)
            return (rational.num, rational.den)
        }
    }

    init(id: String, decimalOdd: Double, statusId: String, isLive: Bool, isAvailable: Bool) {
        self.id = id
        self.odd = OddFormat.decimal(odd: decimalOdd)
        self.statusId = statusId
        self.isLive = isLive
        self.isAvailable = isAvailable
    }

    init(id: String, odd: OddFormat, statusId: String, isLive: Bool, isAvailable: Bool) {
        self.id = id
        self.odd = odd
        self.statusId = statusId
        self.isLive = isLive
        self.isAvailable = isAvailable
    }

}
