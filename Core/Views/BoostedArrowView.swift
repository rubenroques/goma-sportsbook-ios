//
//  BoostedArrowView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/06/2023.
//

import Foundation
import UIKit

class BoostedArrowView: UIView {

    var isReversed: Bool = false {
        didSet {
            self.drawArrows()
            self.setNeedsDisplay()
        }
    }

    var highlightColor: UIColor = .orange {
        didSet {
            self.subviews.forEach({ view in
                if let arrowView = view as? ArrowBoldCustomView {
                    arrowView.highlightColor = self.highlightColor
                }
            })
        }
    }

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
        self.backgroundColor = .clear
        self.drawArrows()
    }

    func drawArrows() {
        self.subviews.forEach({ $0.removeFromSuperview() })

        let arrow1 = ArrowBoldCustomView(frame: .zero)
        arrow1.isReversed = self.isReversed
        arrow1.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(arrow1)

        let arrow2 = ArrowBoldCustomView(frame: .zero)
        arrow2.isReversed = self.isReversed
        arrow2.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(arrow2)

        NSLayoutConstraint.activate([
            arrow1.topAnchor.constraint(equalTo: self.topAnchor),
            arrow1.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            arrow1.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            arrow1.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.56),

            arrow2.topAnchor.constraint(equalTo: self.topAnchor),
            arrow2.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            arrow2.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            arrow2.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.56),
        ])

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}

private class ArrowBoldCustomView: UIView {

    var isReversed: Bool = false

    var highlightColor: UIColor = .orange {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()

        if !isReversed {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
            path.close()
        }
        else {
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
            path.close()
        }

        self.highlightColor.setFill()
        path.fill()
    }
}
