//
//  GradientCalculator.swift
//  Sportsbook
//
//  Created by André Lascas on 20/06/2023.
//

import Foundation

class GradientCalculator {

    init() {
    }

    func pointForAngle(_ angle: CGFloat) -> CGPoint {
        let radians = angle * .pi / 180
        let x = cos(radians)
        let y = sin(radians)
        return CGPoint(x: 0.5 + 0.5 * x, y: 0.5 + 0.5 * y)
    }
}
