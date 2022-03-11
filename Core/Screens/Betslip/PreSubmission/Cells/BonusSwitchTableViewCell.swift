//
//  BonusSwitchTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 10/03/2022.
//

import UIKit

class BonusSwitchTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var bonusSwitch: UISwitch = Self.createBonusSwitch()
    private lazy var closeButton: UIButton = Self.createCloseButton()

    // MARK: Public Properties
    var bonusType: GrantedBonusType = .standard
    var didTapCloseButtonAction: (() -> Void)?
    var didTappedSwitch: (() -> Void)?

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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)

        self.bonusSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .black

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.bonusSwitch.onTintColor = UIColor.App.highlightSecondary

        self.closeButton.backgroundColor = .clear

    }

    func setupBonusInfo(bonus: BetslipFreebet, bonusType: GrantedBonusType) {

        if bonusType == .freeBet {
            self.iconImageView.image = UIImage(named: "bonus_gift_icon")

            let bonusAmount = "\(bonus.currency) \(bonus.freeBetAmount)"
            let bonusTitle = localized("use_freebet").replacingOccurrences(of: "%s", with: bonusAmount)
            self.titleLabel.text = bonusTitle
        }
        else if bonusType == .oddsBoost {
            self.iconImageView.image = UIImage(named: "bonus_lightning_icon")

            let oddsBoost = "\(bonus.freeBetAmount)%"
            let oddsTitle = localized("use_boosted_odds").replacingOccurrences(of: "%s", with: oddsBoost)
            self.titleLabel.text = oddsTitle
        }
    }
}

//
// MARK: - Actions
//
extension BonusSwitchTableViewCell {
    @objc private func didTapCloseButton() {
        self.didTapCloseButtonAction?()
    }

    @objc func switchChanged(settingSwitch: UISwitch) {

        let switchValue = settingSwitch.isOn
        self.isSwitchOn = switchValue

        self.didTappedSwitch?()
    }
}

//
// MARK: Subviews initialization and setup
//
extension BonusSwitchTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "")
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

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        return button
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.bonusSwitch)
        self.containerView.addSubview(self.closeButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
            self.containerView.heightAnchor.constraint(equalToConstant: 50),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 35),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 35),
            self.iconImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 15),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.bonusSwitch.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 15),
            self.bonusSwitch.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),

            self.closeButton.leadingAnchor.constraint(equalTo: self.bonusSwitch.trailingAnchor, constant: 15),
            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.closeButton.widthAnchor.constraint(equalToConstant: 13),
            self.closeButton.heightAnchor.constraint(equalToConstant: 13),
            self.closeButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)

        ])

    }

}
