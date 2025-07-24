//
//  GradientView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/02/2023.
//

import UIKit

class GradientView: UIView {

    var colors: [(color: UIColor, location: NSNumber)] = [(UIColor.red, 0.3), (UIColor.lightGray, 0.7)] {
        didSet {
            self.gradientLayer.colors = self.colors.map { $0.color.cgColor }
            self.gradientLayer.locations = self.colors.map { $0.location }
        }
    }

    var startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0) {
        didSet {
            self.gradientLayer.startPoint = self.startPoint
        }
    }

    var endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0) {
        didSet {
            self.gradientLayer.endPoint = self.endPoint
        }
    }

    var isAnimating: Bool = false

    private let gradientLayer: CAGradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        
        self.gradientLayer.startPoint = self.startPoint
        self.gradientLayer.endPoint = self.endPoint
        self.gradientLayer.colors = self.colors.map(\.color).map(\.cgColor)
        self.gradientLayer.locations = self.colors.map(\.location)
        
        self.layer.insertSublayer(self.gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradientLayer.frame = self.bounds

        if self.isAnimating {
            self.stopAnimations()
            self.startAnimations()
        }

    }

    func startAnimations() {

        self.isAnimating = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = self.colors.map(\.location).map({ $0.floatValue - 1.0 })
          // [-1.0, -0.5, 0.0]
        animation.toValue = self.colors.map(\.location).map({ $0.floatValue + 1.0 })
          // [1.0, 1.5, 2.0]
        animation.duration = 2.0
        animation.autoreverses = true

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 4.0
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [animation]
        gradientLayer.add(animationGroup, forKey: nil)

//        // Apply to gradient to the border
//        let gradientBorder = CAShapeLayer()
//        gradientBorder.lineWidth = 5.0
//        gradientBorder.path = UIBezierPath(rect: self.bounds).cgPath
//        gradientBorder.fillColor = nil
//        gradientBorder.strokeColor = UIColor.black.cgColor
//        gradientLayer.mask = gradientBorder

    }

    func stopAnimations() {
        self.isAnimating = false
        self.gradientLayer.removeAnimation(forKey: "locations")
    }

}
