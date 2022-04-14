//
//  UserActionView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/04/2022.
//

import UIKit

class UserActionView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var actionButton: UIButton = Self.createActionButton()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    // MARK: Public Properties
    var hasLineSeparator: Bool = false {
        didSet {
            if hasLineSeparator {
                self.separatorLineView.isHidden = false
            }
            else {
                self.separatorLineView.isHidden = true
            }
        }
    }

    var isOnline: Bool = false {
        didSet {
            if isOnline {
                self.iconBaseView.backgroundColor = UIColor.App.highlightPrimary
            }
            else {
                self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary
            }
        }
    }

    var tappedActionButtonAction: (() -> Void)?
    var tappedCloseButtonAction: (() -> Void)?

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

    private func commonInit() {
        self.hasLineSeparator = true
        self.isOnline = false

        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.layoutIfNeeded()

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2

        self.drawDottedLine(start: CGPoint(x: 0, y: 0),
                            end: CGPoint(x: self.separatorLineView.frame.width, y: 0))

        self.layoutSubviews()
        self.layoutIfNeeded()

    }

    // MARK: - Layout and Theme
    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.iconBaseView.backgroundColor = UIColor.App.backgroundTertiary

        self.iconImageView.backgroundColor = UIColor.App.backgroundTertiary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.actionButton.backgroundColor = .clear
        self.actionButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.closeButton.backgroundColor = .clear

        self.separatorLineView.backgroundColor = .clear
    }

    // MARK: Functions
    // NOT WORKING
    func drawDottedLine(start: CGPoint, end: CGPoint) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.App.alertSuccess.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [3, 2]

        let path = CGMutablePath()
        path.addLines(between: [start, end])
        shapeLayer.path = path
        self.separatorLineView.layer.addSublayer(shapeLayer)
    }

    func setupViewInfo(title: String, actionTitle: String) {
        self.titleLabel.text = title

        self.actionButton.setTitle(actionTitle, for: .normal)
    }

    func setActionButtonColor(color: UIColor) {
        self.actionButton.setTitleColor(color, for: .normal)
    }

    // MARK: Actions
    @objc func didTapActionButton() {
        self.tappedActionButtonAction?()
    }

    @objc func didTapCloseButton() {
        self.tappedCloseButtonAction?()
    }

}

//
// MARK: Subviews initialization and setup
//
extension UserActionView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = view.frame.height / 2
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "my_account_profile_icon")
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@Title"
        label.font = AppFont.with(type: .semibold, size: 14)
        return label
    }

    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Action", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 12)
        return button
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)

        self.containerView.addSubview(self.actionButton)

        self.containerView.addSubview(self.closeButton)

        self.containerView.addSubview(self.separatorLineView)

        self.initConstraints()

    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 50),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
            self.iconBaseView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 24),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor, constant: 3),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -3),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 3),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: -3),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 8),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.actionButton.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.actionButton.heightAnchor.constraint(equalToConstant: 40),
            self.actionButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.closeButton.leadingAnchor.constraint(equalTo: self.actionButton.trailingAnchor, constant: 8),
            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor),
            self.closeButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)
        ])

    }

}
