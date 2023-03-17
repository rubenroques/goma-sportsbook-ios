//
//  BonusSwitchView.swift
//  Sportsbook
//
//  Created by André Lascas on 10/03/2022.
//

import UIKit
import Combine

class BonusSwitchView: UIView {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var bonusSwitch: UISwitch = Self.createBonusSwitch()
    // private lazy var closeButton: UIButton = Self.createCloseButton()

    // MARK: Public Properties
    var bonusType: GrantedBonusType = .standard
    // var didTapCloseButtonAction: (() -> Void)?
    var didTappedSwitch: ((Bool) -> Void) = { _ in }

    var isSwitchOn: Bool = false {
        didSet {
            if isSwitchOn {
                self.bonusSwitch.isOn = true
            }
            else {
                self.bonusSwitch.isOn = false
            }
        }
    }

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
        self.alpha = 1

        // self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        self.bonusSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundDarker

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.bonusSwitch.onTintColor = UIColor.App.highlightSecondary

        // self.closeButton.backgroundColor = .clear

    }

    func setupBonusInfo(freeBet: BetslipFreebet?, oddsBoost: BetslipOddsBoost?, bonusType: GrantedBonusType) {

        if bonusType == .freeBet {
            self.iconImageView.image = UIImage(named: "bonus_gift_icon")

            if let freeBet = freeBet {
                let freeBetAmount = "\(freeBet.currency) \(freeBet.freeBetAmount)"
                let freeBetTitle = localized("use_freebets").replacingOccurrences(of: "{amount}", with: freeBetAmount)
                self.titleLabel.text = freeBetTitle
            }
        }
        else if bonusType == .oddsBoost {
            self.iconImageView.image = UIImage(named: "bonus_lightning_icon")
            if let oddsBoost = oddsBoost {
                let oddsBoostConverted = oddsBoost.oddsBoostPercent * 100
                let oddsBoost = "\(oddsBoostConverted)%"
                let oddsTitle = localized("use_boosted_odds").replacingOccurrences(of: "{percentage}", with: oddsBoost)
                self.titleLabel.text = oddsTitle
            }
        }
    }

}

//
// MARK: - Actions
//
extension BonusSwitchView {
//    @objc private func didTapCloseButton() {
//        self.didTapCloseButtonAction?()
//    }

    @objc func switchChanged(settingSwitch: UISwitch) {

        let switchValue = settingSwitch.isOn
        self.isSwitchOn = switchValue

        self.didTappedSwitch(self.isSwitchOn)
    }
}

//
// MARK: Subviews initialization and setup
//
extension BonusSwitchView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Text"
        label.numberOfLines = 0
        label.font = AppFont.with(type: .semibold, size: 14)
        return label
    }

    private static func createBonusSwitch() -> UISwitch {
        let bonusSwitch = UISwitch()
        bonusSwitch.translatesAutoresizingMaskIntoConstraints = false
        bonusSwitch.isOn = false
        return bonusSwitch
    }

//    private static func createCloseButton() -> UIButton {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("", for: .normal)
//        button.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
//        return button
//    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.bonusSwitch)
        // self.containerView.addSubview(self.closeButton)

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

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 35),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 35),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 15),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.bonusSwitch.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 15),
            self.bonusSwitch.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.bonusSwitch.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16)

//            self.closeButton.leadingAnchor.constraint(equalTo: self.bonusSwitch.trailingAnchor, constant: 15),
//            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
//            self.closeButton.widthAnchor.constraint(equalToConstant: 13),
//            self.closeButton.heightAnchor.constraint(equalToConstant: 13),
//            self.closeButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)

        ])

    }

}
