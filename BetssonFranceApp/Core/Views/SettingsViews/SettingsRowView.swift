//
//  SettingsRowView.swift
//  Sportsbook
//
//  Created by André Lascas on 16/02/2022.
//

import UIKit

class SettingsRowView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var switchButton: UISwitch = Self.createSwitchButton()
    private lazy var rightImageView: UIImageView = Self.createRightImageView()

    // MARK: Public Properties
    var hasSeparatorLineView: Bool = false {
        didSet {
            if hasSeparatorLineView {
                self.separatorLineView.isHidden = false
            }
            else {
                self.separatorLineView.isHidden = true
            }
        }
    }

    var hasSwitchButton: Bool = false {
        didSet {
            if hasSwitchButton {
                self.switchButton.isHidden = false
            }
            else {
                self.switchButton.isHidden = true
            }
        }
    }

    var isSwitchOn: Bool = false {
        didSet {
            if isSwitchOn {
                self.switchButton.isOn = true
            }
            else {
                self.switchButton.isOn = false
            }
        }
    }

    var hasNavigationImageView: Bool = false {
        didSet {
            if hasNavigationImageView {
                self.rightImageView.isHidden = false
            }
            else {
                self.rightImageView.isHidden = true
            }
        }
    }

    var didTappedSwitch: ((Bool) -> Void)?

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

    func commonInit() {

        self.hasSeparatorLineView = false
        self.hasSwitchButton = false
        self.hasNavigationImageView = false

        self.switchButton.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.switchButton.onTintColor = UIColor.App.buttonBackgroundPrimary

    }

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    @objc func switchChanged(settingSwitch: UISwitch) {

        let switchValue = settingSwitch.isOn
        self.isSwitchOn = switchValue

        self.didTappedSwitch?(self.isSwitchOn)
    }

}

//
// MARK: Subviews initialization and setup
//
extension SettingsRowView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.font = AppFont.with(type: .bold, size: 16)
        label.numberOfLines = 0
        return label
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSwitchButton() -> UISwitch {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.isOn = false
        return switchButton
    }

    private static func createRightImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nav_arrow_right_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.separatorLineView)
        self.containerView.addSubview(self.switchButton)
        self.containerView.addSubview(self.rightImageView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 60),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -80),

            self.switchButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.switchButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.rightImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.rightImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.rightImageView.widthAnchor.constraint(equalToConstant: 15),

            self.separatorLineView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1)

        ])

    }

}
