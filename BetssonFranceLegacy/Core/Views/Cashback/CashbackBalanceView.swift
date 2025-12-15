//
//  CashbackBalanceView.swift
//  Sportsbook
//
//  Created by André Lascas on 23/06/2023.
//

import UIKit

class CashbackBalanceView: UIView {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var valueLabel: UILabel = Self.createValueLabel()
    private lazy var switchButton: UISwitch = Self.createSwitchButton()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    var isInteractionEnabled: Bool = true {
        didSet {
            self.isUserInteractionEnabled = isInteractionEnabled
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.squareView

        self.containerView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        self.containerView.layer.borderWidth = 1.5
    }

    func commonInit() {

        self.switchButton.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundBorder

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.valueLabel.textColor = UIColor.App.highlightPrimary

        self.switchButton.onTintColor = UIColor.App.buttonBackgroundPrimary

        self.closeButton.backgroundColor = .clear

    }

    func setupValueLabel(value: String) {
        self.valueLabel.text = value
    }

    // MARK: Actions
    @objc func switchChanged(settingSwitch: UISwitch) {

        let switchValue = settingSwitch.isOn
        self.isSwitchOn = switchValue

        self.didTappedSwitch?(self.isSwitchOn)
    }

    @objc func didTapCloseButton() {
        self.removeFromSuperview()
    }
}

extension CashbackBalanceView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "info_small_icon")
        imageView.contentMode = .center
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("betsson_credits_mise_max")
        label.font = AppFont.with(type: .semibold, size: 13)
        label.numberOfLines = 0
        return label
    }

    private static func createValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0,00€"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 0
        return label
    }

    private static func createSwitchButton() -> UISwitch {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.isOn = false
        return switchButton
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        return button
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.valueLabel)
        self.containerView.addSubview(self.switchButton)
        // self.containerView.addSubview(self.closeButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 48),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            
            self.iconImageView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 4),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 10),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

            self.valueLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 4),
            self.valueLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.valueLabel.trailingAnchor.constraint(equalTo: self.switchButton.leadingAnchor, constant: -25),

            self.switchButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
            self.switchButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

//            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
//            self.closeButton.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
//            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
//            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor)

        ])

    }

}
