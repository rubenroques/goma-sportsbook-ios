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
}
