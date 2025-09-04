//
//  CircularDottedLineView.swift
//  Sportsbook
//
//  Created by André Lascas on 04/09/2025.
//

import Foundation
import UIKit

class CircularDottedLineView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let dotRadius: CGFloat = 1.0
        let dotSpacing: CGFloat = 6.0
        let centerY = bounds.midY
        
        context.setFillColor(UIColor(red: 0.25, green: 0.25, blue: 0.5, alpha: 1.0).cgColor)
        
        var currentX: CGFloat = 0
        while currentX <= bounds.width {
            let dotRect = CGRect(x: currentX - dotRadius,
                               y: centerY - dotRadius,
                               width: dotRadius * 2,
                               height: dotRadius * 2)
            context.fillEllipse(in: dotRect)
            currentX += dotSpacing
        }
    }
}
