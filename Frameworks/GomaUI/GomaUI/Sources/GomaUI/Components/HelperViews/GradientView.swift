//
//  GradientView.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import UIKit
import SwiftUI

final public class GradientView: UIView {
    
    // MARK: - Public Properties
    public var colors: [(color: UIColor, location: NSNumber)] = [
        (UIColor.systemOrange, 0.0),
        (UIColor.systemOrange.withAlphaComponent(0.8), 1.0)
    ] {
        didSet {
            updateGradientColors()
        }
    }
    
    public var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0) {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    public var endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    public var cornerRadius: CGFloat = 0 {
        didSet {
            gradientLayer.cornerRadius = cornerRadius
            layer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: - Private Properties
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    private var isAnimating: Bool = false
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Setup
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        setupGradientLayer()
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupGradientLayer() {
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        updateGradientColors()
    }
    
    private func updateGradientColors() {
        gradientLayer.colors = colors.map { $0.color.cgColor }
        gradientLayer.locations = colors.map { $0.location }
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        if isAnimating {
            stopAnimation()
            startAnimation()
        }
    }
    
    // MARK: - Animation Methods
    public func startAnimation() {
        isAnimating = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = colors.map { $0.location.floatValue - 1.0 }
        animation.toValue = colors.map { $0.location.floatValue + 1.0 }
        animation.duration = 2.0
        animation.autoreverses = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 4.0
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [animation]
        
        gradientLayer.add(animationGroup, forKey: "gradientAnimation")
    }
    
    public func stopAnimation() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "gradientAnimation")
    }
    
    // MARK: - Convenience Methods
    public func setHorizontalGradient() {
        startPoint = CGPoint(x: 0.0, y: 0.5)
        endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    public func setInvertedHorizontalGradient() {
        startPoint = CGPoint(x: 1.0, y: 0.5)
        endPoint = CGPoint(x: 0.0, y: 0.5)
    }
    
    public func setVerticalGradient() {
        startPoint = CGPoint(x: 0.5, y: 0.0)
        endPoint = CGPoint(x: 0.5, y: 1.0)
    }
    
    public func setInvertedVerticalGradient() {
        startPoint = CGPoint(x: 0.5, y: 1.0)
        endPoint = CGPoint(x: 0.5, y: 0.0)
    }
    
    public func setDiagonalGradient() {
        startPoint = CGPoint(x: 0.0, y: 1.0)
        endPoint = CGPoint(x: 1.0, y: 0.0)
    }
    
    public func setInvertedDiagonalGradient() {
        startPoint = CGPoint(x: 0.0, y: 0.0)
        endPoint = CGPoint(x: 1.0, y: 1.0)
    }
    
    public func setRadialGradient() {
        startPoint = CGPoint(x: 0.5, y: 0.5)
        endPoint = CGPoint(x: 1.0, y: 1.0)
    }
}

// MARK: - Gradient Custom
extension GradientView {
    
    public static func customGradient(colors: [(UIColor, NSNumber)], gradientDirection: GradientDirection) -> GradientView {
        let gradient = GradientView()
        gradient.colors = colors.map { (color: $0.0, location: $0.1) }
        
        switch gradientDirection {
        case .horizontal:
            gradient.setHorizontalGradient()
        case .invertedHorizontal:
            gradient.setInvertedHorizontalGradient()
        case .vertical:
            gradient.setVerticalGradient()
        case .invertedVertical:
            gradient.setInvertedVerticalGradient()
        case .diagonal:
            gradient.setDiagonalGradient()
        case .invertedDiagonal:
            gradient.setInvertedDiagonalGradient()
        case .radial:
            gradient.setRadialGradient()
        }
        
        return gradient
    }
}

public enum GradientDirection {
    case horizontal
    case invertedHorizontal
    case vertical
    case invertedVertical
    case diagonal
    case invertedDiagonal
    case radial
}

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Different Gradients") {
    VStack(spacing: 16) {
        PreviewUIView {
            let gradient = GradientView.customGradient(colors: [
                (UIColor.systemOrange, 0.0),
                (UIColor.systemRed, 1.0)
            ], gradientDirection: .diagonal)
            gradient.cornerRadius = 12
            return gradient
        }
        .frame(height: 60)
        
        PreviewUIView {
            let gradient = GradientView.customGradient(colors: [
                (UIColor.systemBlue, 0.0),
                (UIColor.systemYellow, 1.0)
            ], gradientDirection: .horizontal)
            gradient.cornerRadius = 12
            return gradient
        }
        .frame(height: 60)
        
        PreviewUIView {
            let gradient = GradientView.customGradient(colors: [
                (UIColor.systemPurple, 0.0),
                (UIColor.systemCyan, 1.0)
            ], gradientDirection: .vertical)
            gradient.cornerRadius = 12
            return gradient
        }
        .frame(height: 60)
        
        PreviewUIView {
            let gradient = GradientView.customGradient(colors: [
                (UIColor.systemGreen, 0.0),
                (UIColor.systemGray, 1.0)
            ], gradientDirection: .radial)
            gradient.cornerRadius = 12
            return gradient
        }
        .frame(height: 60)
        
        PreviewUIView {
            let gradient = GradientView.customGradient(colors: [
                (StyleProvider.Color.topBarGradient1, 0.33),
                (StyleProvider.Color.topBarGradient2, 0.66),
                (StyleProvider.Color.topBarGradient3, 1.0),
            ], gradientDirection: .diagonal)
            gradient.cornerRadius = 12
            return gradient
        }
        .frame(height: 60)
    }
    .padding()
}

@available(iOS 17.0, *)
#Preview("Animated Gradient") {
    PreviewUIView {
        let gradient = GradientView.customGradient(colors: [
            (UIColor.systemBlue, 0.0),
            (UIColor.systemYellow, 1.0)
        ], gradientDirection: .diagonal)
        gradient.cornerRadius = 12
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            gradient.startAnimation()
        }
        return gradient
    }
    .frame(width: 300, height: 100)
    .padding()
}

#endif
