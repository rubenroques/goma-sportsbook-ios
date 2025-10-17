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
#Preview("GradientView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Helper function to create label + gradient pair
        func createLabeledGradient(
            title: String,
            gradient: GradientView,
            height: CGFloat = 60
        ) -> UIStackView {
            let container = UIStackView()
            container.axis = .vertical
            container.spacing = 4
            container.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = title
            label.font = StyleProvider.fontWith(type: .medium, size: 12)
            label.textColor = StyleProvider.Color.textSecondary
            label.translatesAutoresizingMaskIntoConstraints = false

            gradient.translatesAutoresizingMaskIntoConstraints = false

            container.addArrangedSubview(label)
            container.addArrangedSubview(gradient)

            NSLayoutConstraint.activate([
                gradient.heightAnchor.constraint(equalToConstant: height)
            ])

            return container
        }

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "GradientView Examples"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Section: Gradient Directions
        let directionsLabel = UILabel()
        directionsLabel.text = "GRADIENT DIRECTIONS"
        directionsLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        directionsLabel.textColor = StyleProvider.Color.textPrimary
        directionsLabel.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal
        let horizontalGradient = GradientView.customGradient(colors: [
            (UIColor.systemBlue, 0.0),
            (UIColor.systemCyan, 1.0)
        ], gradientDirection: .horizontal)
        horizontalGradient.cornerRadius = 8

        // Inverted Horizontal
        let invertedHorizontalGradient = GradientView.customGradient(colors: [
            (UIColor.systemBlue, 0.0),
            (UIColor.systemCyan, 1.0)
        ], gradientDirection: .invertedHorizontal)
        invertedHorizontalGradient.cornerRadius = 8

        // Vertical
        let verticalGradient = GradientView.customGradient(colors: [
            (UIColor.systemPurple, 0.0),
            (UIColor.systemPink, 1.0)
        ], gradientDirection: .vertical)
        verticalGradient.cornerRadius = 8

        // Inverted Vertical
        let invertedVerticalGradient = GradientView.customGradient(colors: [
            (UIColor.systemPurple, 0.0),
            (UIColor.systemPink, 1.0)
        ], gradientDirection: .invertedVertical)
        invertedVerticalGradient.cornerRadius = 8

        // Diagonal
        let diagonalGradient = GradientView.customGradient(colors: [
            (UIColor.systemOrange, 0.0),
            (UIColor.systemRed, 1.0)
        ], gradientDirection: .diagonal)
        diagonalGradient.cornerRadius = 8

        // Inverted Diagonal
        let invertedDiagonalGradient = GradientView.customGradient(colors: [
            (UIColor.systemOrange, 0.0),
            (UIColor.systemRed, 1.0)
        ], gradientDirection: .invertedDiagonal)
        invertedDiagonalGradient.cornerRadius = 8

        // Radial
        let radialGradient = GradientView.customGradient(colors: [
            (UIColor.systemGreen, 0.0),
            (UIColor.systemTeal, 1.0)
        ], gradientDirection: .radial)
        radialGradient.cornerRadius = 8

        // Section: Corner Radius Variations
        let cornerRadiusLabel = UILabel()
        cornerRadiusLabel.text = "CORNER RADIUS VARIATIONS"
        cornerRadiusLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        cornerRadiusLabel.textColor = StyleProvider.Color.textPrimary
        cornerRadiusLabel.translatesAutoresizingMaskIntoConstraints = false

        let noCornerRadius = GradientView.customGradient(colors: [
            (UIColor.systemIndigo, 0.0),
            (UIColor.systemBlue, 1.0)
        ], gradientDirection: .horizontal)
        noCornerRadius.cornerRadius = 0

        let mediumCornerRadius = GradientView.customGradient(colors: [
            (UIColor.systemIndigo, 0.0),
            (UIColor.systemBlue, 1.0)
        ], gradientDirection: .horizontal)
        mediumCornerRadius.cornerRadius = 12

        let largeCornerRadius = GradientView.customGradient(colors: [
            (UIColor.systemIndigo, 0.0),
            (UIColor.systemBlue, 1.0)
        ], gradientDirection: .horizontal)
        largeCornerRadius.cornerRadius = 24

        // Section: StyleProvider Colors
        let styleProviderLabel = UILabel()
        styleProviderLabel.text = "STYLEPROVIDER COLORS"
        styleProviderLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        styleProviderLabel.textColor = StyleProvider.Color.textPrimary
        styleProviderLabel.translatesAutoresizingMaskIntoConstraints = false

        let styleProviderGradient = GradientView.customGradient(colors: [
            (StyleProvider.Color.topBarGradient1, 0.33),
            (StyleProvider.Color.topBarGradient2, 0.66),
            (StyleProvider.Color.topBarGradient3, 1.0)
        ], gradientDirection: .invertedDiagonal)
        styleProviderGradient.cornerRadius = 8

        // Section: Animation
        let animationLabel = UILabel()
        animationLabel.text = "ANIMATION"
        animationLabel.font = StyleProvider.fontWith(type: .bold, size: 14)
        animationLabel.textColor = StyleProvider.Color.textPrimary
        animationLabel.translatesAutoresizingMaskIntoConstraints = false

        let animatedGradient = GradientView.customGradient(colors: [
            (UIColor.systemPink, 0.0),
            (UIColor.systemYellow, 0.5),
            (UIColor.systemOrange, 1.0)
        ], gradientDirection: .diagonal)
        animatedGradient.cornerRadius = 8
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animatedGradient.startAnimation()
        }

        // Add all sections to stack view
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(directionsLabel)
        stackView.addArrangedSubview(createLabeledGradient(title: "Horizontal (left → right)", gradient: horizontalGradient))
        stackView.addArrangedSubview(createLabeledGradient(title: "Inverted Horizontal (right → left)", gradient: invertedHorizontalGradient))
        stackView.addArrangedSubview(createLabeledGradient(title: "Vertical (top → bottom)", gradient: verticalGradient))
        stackView.addArrangedSubview(createLabeledGradient(title: "Inverted Vertical (bottom → top)", gradient: invertedVerticalGradient))
        stackView.addArrangedSubview(createLabeledGradient(title: "Diagonal (bottom-left → top-right)", gradient: diagonalGradient))
        stackView.addArrangedSubview(createLabeledGradient(title: "Inverted Diagonal (top-left → bottom-right)", gradient: invertedDiagonalGradient))
        stackView.addArrangedSubview(createLabeledGradient(title: "Radial (center → edges)", gradient: radialGradient))

        stackView.addArrangedSubview(cornerRadiusLabel)
        stackView.addArrangedSubview(createLabeledGradient(title: "cornerRadius = 0", gradient: noCornerRadius))
        stackView.addArrangedSubview(createLabeledGradient(title: "cornerRadius = 12", gradient: mediumCornerRadius))
        stackView.addArrangedSubview(createLabeledGradient(title: "cornerRadius = 24", gradient: largeCornerRadius))

        stackView.addArrangedSubview(styleProviderLabel)
        stackView.addArrangedSubview(createLabeledGradient(title: "Brand gradient (topBarGradient1/2/3)", gradient: styleProviderGradient))

        stackView.addArrangedSubview(animationLabel)
        stackView.addArrangedSubview(createLabeledGradient(title: "Animated gradient with 3 colors", gradient: animatedGradient))

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

#endif
