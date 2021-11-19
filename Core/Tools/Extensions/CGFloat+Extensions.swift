//
//  CGFloat+Extensions.swift
//  Sportsbook
//
//  Created by André Lascas on 19/10/2021.
//

import Foundation
import CoreGraphics

extension CGFloat {
    func round(to places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
