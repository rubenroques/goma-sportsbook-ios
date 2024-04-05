//
//  FadingView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/04/2024.
//

import Foundation
import UIKit

class FadingView: UIView {
    private var gradientLayer: CAGradientLayer?

    // Configuration properties for the fading effect
    var colors: [UIColor] = [.black, .clear] {
        didSet {
            updateGradient()
        }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            updateGradient()
        }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            updateGradient()
        }
    }
    
    // Accepts an array of numbers representing the locations of gradient color changes
    var fadeLocations: [NSNumber]? {
        didSet {
            updateGradient()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFadingEffect()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFadingEffect() {
        self.gradientLayer = CAGradientLayer()
        self.updateGradient()
        self.layer.mask = self.gradientLayer
    }
    
    private func updateGradient() {
        self.gradientLayer?.frame = self.bounds
        self.gradientLayer?.colors = colors.map { $0.cgColor }
        self.gradientLayer?.startPoint = startPoint
        self.gradientLayer?.endPoint = endPoint
        self.gradientLayer?.locations = fadeLocations
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = self.bounds
    }
}
