//
//  ChatBubbleView.swift
//  MultiBet
//
//  Created by André Lascas on 18/10/2024.
//

import UIKit

//class ChatBubbleView: UIView {
//    
//    let cornerRadius: CGFloat = 15.0
//    let tailWidth: CGFloat = 10.0
//    let tailHeight: CGFloat = 10.0
//    
//    override func draw(_ rect: CGRect) {
//        let bubblePath = UIBezierPath()
//        
//        // Start from top-left corner
//        bubblePath.move(to: CGPoint(x: cornerRadius, y: 0))
//        
//        // Top side until the tail position (before top-right corner)
//        bubblePath.addLine(to: CGPoint(x: rect.width - cornerRadius - tailWidth, y: 0))
//        
//        // Tail (top-right, pointing to the right)
//        bubblePath.addLine(to: CGPoint(x: rect.width, y: 0))
//        bubblePath.addLine(to: CGPoint(x: rect.width - tailWidth, y: tailHeight))
//                
//        // Right side
//        bubblePath.addLine(to: CGPoint(x: rect.width - tailWidth, y: rect.height - cornerRadius))
//        
//        // Bottom-right corner
//        bubblePath.addArc(withCenter: CGPoint(x: rect.width - cornerRadius - tailWidth, y: rect.height - cornerRadius),
//                          radius: cornerRadius,
//                          startAngle: 0,
//                          endAngle: CGFloat.pi / 2,
//                          clockwise: true)
//        
//        // Bottom side
//        bubblePath.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
//        
//        // Bottom-left corner
//        bubblePath.addArc(withCenter: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
//                          radius: cornerRadius,
//                          startAngle: CGFloat.pi / 2,
//                          endAngle: CGFloat.pi,
//                          clockwise: true)
//        
//        // Left side
//        bubblePath.addLine(to: CGPoint(x: 0, y: cornerRadius))
//        
//        // Top-left corner
//        bubblePath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
//                          radius: cornerRadius,
//                          startAngle: CGFloat.pi,
//                          endAngle: -CGFloat.pi / 2,
//                          clockwise: true)
//        
//        bubblePath.close()
//        
//        // Set the bubble's fill color
//        UIColor.systemBlue.setFill()
//        bubblePath.fill()
//    }
//}

class ChatBubbleView: UIView {
    
    let cornerRadius: CGFloat = 15.0
    let tailWidth: CGFloat = 10.0
    let tailHeight: CGFloat = 10.0
    
    var useGradient: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    var backgroundColors: [UIColor] = [UIColor.systemBlue, UIColor.systemPurple] {
        didSet {
            setNeedsLayout()
        }
    }
    
    var isReceivedMessage: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var backgroundLayer: CALayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove any previous background layer
        backgroundLayer?.removeFromSuperlayer()
        
        if useGradient {
            // Create and configure the gradient layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = bounds
            gradientLayer.colors = backgroundColors.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            
            // Mask the gradient to the chat bubble path
            let bubblePath = createBubblePath(in: bounds, isLeftTail: self.isReceivedMessage)
            let maskLayer = CAShapeLayer()
            maskLayer.path = bubblePath.cgPath
            gradientLayer.mask = maskLayer
            
            // Insert gradient at the bottom
            layer.insertSublayer(gradientLayer, at: 0)
            self.backgroundLayer = gradientLayer
        } else {
            // Fill with solid color using a shape layer
            let solidColorLayer = CAShapeLayer()
            solidColorLayer.path = createBubblePath(in: bounds, isLeftTail: self.isReceivedMessage).cgPath
            solidColorLayer.fillColor = backgroundColors.first?.cgColor ?? UIColor.App.backgroundSecondary.cgColor
            solidColorLayer.frame = bounds
            
            // Insert solid color layer at the bottom
            layer.insertSublayer(solidColorLayer, at: 0)
            self.backgroundLayer = solidColorLayer
        }
    }

    private func createBubblePath(in rect: CGRect, isLeftTail: Bool = false) -> UIBezierPath {
        let bubblePath = UIBezierPath()
        
        if !isLeftTail {
            // Define your custom path here
            bubblePath.move(to: CGPoint(x: cornerRadius, y: 0))
            bubblePath.addLine(to: CGPoint(x: rect.width - cornerRadius - tailWidth, y: 0))
            bubblePath.addLine(to: CGPoint(x: rect.width, y: 0))
            bubblePath.addLine(to: CGPoint(x: rect.width - tailWidth, y: tailHeight))
            bubblePath.addLine(to: CGPoint(x: rect.width - tailWidth, y: rect.height - cornerRadius))
            bubblePath.addArc(withCenter: CGPoint(x: rect.width - cornerRadius - tailWidth, y: rect.height - cornerRadius),
                              radius: cornerRadius,
                              startAngle: 0,
                              endAngle: CGFloat.pi / 2,
                              clockwise: true)
            bubblePath.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
            bubblePath.addArc(withCenter: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                              radius: cornerRadius,
                              startAngle: CGFloat.pi / 2,
                              endAngle: CGFloat.pi,
                              clockwise: true)
            bubblePath.addLine(to: CGPoint(x: 0, y: cornerRadius))
            bubblePath.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                              radius: cornerRadius,
                              startAngle: CGFloat.pi,
                              endAngle: -CGFloat.pi / 2,
                              clockwise: true)
        }
        else {
            bubblePath.move(to: CGPoint(x: 0, y: 0))
            bubblePath.addLine(to: CGPoint(x: rect.width - cornerRadius - tailWidth, y: 0))
            bubblePath.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                              radius: cornerRadius,
                              startAngle: -CGFloat.pi / 2,
                              endAngle: 0,
                              clockwise: true)
//            bubblePath.addLine(to: CGPoint(x: rect.width, y: 0))
//            bubblePath.addLine(to: CGPoint(x: rect.width - tailWidth, y: tailHeight))
            bubblePath.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
            bubblePath.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                              radius: cornerRadius,
                              startAngle: 0,
                              endAngle: CGFloat.pi / 2,
                              clockwise: true)
            bubblePath.addLine(to: CGPoint(x: cornerRadius + tailWidth, y: rect.height))
            bubblePath.addArc(withCenter: CGPoint(x: cornerRadius + tailWidth, y: rect.height - cornerRadius),
                              radius: cornerRadius,
                              startAngle: CGFloat.pi / 2,
                              endAngle: CGFloat.pi,
                              clockwise: true)
            bubblePath.addLine(to: CGPoint(x: tailWidth, y: tailHeight))
            bubblePath.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        bubblePath.close()
        
        return bubblePath
    }
}
