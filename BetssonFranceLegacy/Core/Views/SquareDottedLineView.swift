//
//  SquareDottedLineView.swift
//  Sportsbook
//
//  Created by André Lascas on 04/09/2025.
//

import Foundation
import UIKit

public class SquareDottedLineView: UIView {

    public struct SquareDottedLineConfiguration {
        public var color: UIColor
        public var dashLength: CGFloat
        public var dashGap: CGFloat

        public init(
            color: UIColor,
            dashLength: CGFloat,
            dashGap: CGFloat) {
            self.color = color
            self.dashLength = dashLength
            self.dashGap = dashGap
        }

        static let defaultConfig: Self = .init(
            color: UIColor.App.separatorLineSecondary,
            dashLength: 2,
            dashGap: 4)
    }

    // MARK: - Properties
    override public var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    public final var config: SquareDottedLineConfiguration = .defaultConfig {
        didSet {
            drawDottedLine()
        }
    }

    private var dashedLayer: CAShapeLayer?

    // MARK: - Life Cycle

    override public func layoutSubviews() {
        super.layoutSubviews()

        // We only redraw the dashes if the width has changed.
        guard bounds.width != dashedLayer?.frame.width else { return }

        drawDottedLine()
    }

    // MARK: - Drawing

    private func drawDottedLine() {
        if dashedLayer != nil {
            dashedLayer?.removeFromSuperlayer()
        }

        dashedLayer = drawDottedLine(
            start: bounds.origin,
            end: CGPoint(x: bounds.width, y: bounds.origin.y),
            config: config)
    }

}

private extension SquareDottedLineView {
    func drawDottedLine(
        start: CGPoint,
        end: CGPoint,
        config: SquareDottedLineConfiguration) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = config.color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [config.dashLength as NSNumber, config.dashGap as NSNumber]

        let path = CGMutablePath()
        path.addLines(between: [start, end])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)

        return shapeLayer
    }
}
