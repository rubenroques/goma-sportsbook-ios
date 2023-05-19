//
//  GradientBorderView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/05/2023.
//

import Foundation
import UIKit

class GradientBorderView: UIView {

    var gradientBorderWidth: CGFloat = 10
    var gradientCornerRadius: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()

        // Remove the old gradient border if it exists
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // Add a new gradient border
        self.addGradientBorder(to: self, borderWidth: self.gradientBorderWidth, cornerRadius: self.gradientCornerRadius)
    }

    private func gradientLayer(bounds: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.97) // Bottom Left
        gradientLayer.endPoint = CGPoint(x: 0.95, y: 0) // Top Right
        gradientLayer.locations = [0.0, 0.44, 1.0]
        gradientLayer.colors = [UIColor.App.cardBorderLineGradient1.cgColor,
                                UIColor.App.cardBorderLineGradient2.cgColor,
                                UIColor.App.cardBorderLineGradient3.cgColor]
        return gradientLayer
    }

    private func maskLayer(bounds: CGRect, borderWidth: CGFloat, cornerRadius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2), cornerRadius: cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        maskLayer.lineWidth = borderWidth
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        return maskLayer
    }

    private func addGradientBorder(to view: UIView, borderWidth: CGFloat, cornerRadius: CGFloat) {
        let gradient = gradientLayer(bounds: view.bounds)
        let mask = maskLayer(bounds: view.bounds, borderWidth: borderWidth, cornerRadius: cornerRadius)
        gradient.mask = mask
        view.layer.addSublayer(gradient)
    }
}
