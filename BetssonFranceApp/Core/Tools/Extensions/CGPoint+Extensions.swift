//
//  CGPoint+Extensions.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/05/2022.
//

import Foundation
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }

    static func topToBottomPointForAngle(_ angle: CGFloat) -> CGPoint {
        let radians = angle * .pi / 180
        let x = cos(radians)
        let y = sin(radians)
        return CGPoint(x: 0.5 + 0.5 * x, y: 0.5 + 0.5 * y)
    }

    static func bottomToTopPointForAngle(_ angle: CGFloat) -> CGPoint {
        let radians = angle * .pi / 180
        let x = cos(radians)
        let y = sin(radians)
        return CGPoint(x: 0.5 + 0.5 * x, y: 0.5 - 0.5 * y)
    }
}
