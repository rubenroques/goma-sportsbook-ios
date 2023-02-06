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
        self.backgroundColor = .white
        self.layer.insertSublayer(self.gradientLayer, at: 0)

        self.gradientLayer.startPoint = self.startPoint
        self.gradientLayer.endPoint = self.endPoint
        self.gradientLayer.colors = self.colors.map(\.color).map(\.cgColor)
        self.gradientLayer.locations = self.colors.map(\.location)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.frame = self.bounds
    }

}
