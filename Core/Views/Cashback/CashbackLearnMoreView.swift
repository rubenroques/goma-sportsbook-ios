//
//  CashbackLearnMoreView.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2023.
//

import UIKit

class CashbackLearnMoreView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    var didTapLearnMoreAction: (() -> Void) = { }

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.headerInput

        // Create the triangle shape layer
        let triangleLayer = CAShapeLayer()
        triangleLayer.fillColor = UIColor.App.backgroundTertiary.cgColor

        // Create the path for the triangle shape
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: self.containerView.bounds.width - 10, y: self.containerView.bounds.height))
        trianglePath.addLine(to: CGPoint(x: self.containerView.bounds.width - 15, y: self.containerView.bounds.height + 10))
        trianglePath.addLine(to: CGPoint(x: self.containerView.bounds.width - 20, y: self.containerView.bounds.height))
        trianglePath.close()

        // Set the path to the triangle layer
        triangleLayer.path = trianglePath.cgPath

        // Add the triangle layer to the view's layer
        self.containerView.layer.addSublayer(triangleLayer)

        self.containerView.layer.shadowColor = UIColor(red: 3.0 / 255.0, green: 6.0 / 255.0, blue: 27.0 / 255.0, alpha: 1).cgColor

        self.containerView.layer.shadowOpacity = 1
        self.containerView.layer.shadowOffset = .zero
        self.containerView.layer.shadowRadius = 10
        self.containerView.layer.shouldRasterize = true
        self.containerView.layer.rasterizationScale = UIScreen.main.scale
    }

    func commonInit() {
        let learnMoreTap = UITapGestureRecognizer(target: self, action: #selector(self.tapLearnMore))
        self.containerView.addGestureRecognizer(learnMoreTap)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.containerView.backgroundColor = UIColor.App.backgroundTertiary
    }

    @objc private func tapLearnMore() {
        self.didTapLearnMoreAction()
    }
}

extension CashbackLearnMoreView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("cashback_info")) \(localized("learn_more"))"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.numberOfLines = 0

        let text = "\(localized("cashback_info")) \(localized("learn_more"))"
        let underlineAttriString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: text)
        var range = (text as NSString).range(of: localized("learn_more"))

        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightSecondary, range: range)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 10), range: fullRange)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)

        label.attributedText = underlineAttriString

        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 5),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -5),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10)

        ])

    }

}
