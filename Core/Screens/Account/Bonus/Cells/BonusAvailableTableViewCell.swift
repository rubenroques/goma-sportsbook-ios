//
//  BonusAvailableTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2022.
//

import UIKit

class BonusAvailableTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topStackView: UIStackView = Self.createTopStackView()
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var bottomStackView: UIStackView = Self.createBottomStackView()
    private lazy var moreInfoButton: UIButton = Self.createMoreInfoButton()
    private lazy var getBonusButton: UIButton = Self.createGetBonusButton()

    // MARK: Public Properties
    var hasBannerImage: Bool = false {
        didSet {
            if hasBannerImage {
                self.bannerImageView.isHidden = false
            }
            else {
                self.bannerImageView.isHidden = true
            }
        }
    }

    var isClaimableBonus: Bool = false {
        didSet {
            if isClaimableBonus {
                self.getBonusButton.isHidden = false
            }
            else {
                self.getBonusButton.isHidden = true
            }
        }
    }

    var didTapMoreInfoAction: (() -> Void)?
    var didTapGetBonusAction: (() -> Void)?

    // MARK: Lifetime and Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.moreInfoButton.addTarget(self, action: #selector(didTapMoreInfoButton), for: .touchUpInside)

        self.getBonusButton.addTarget(self, action: #selector(didTapGetBonusButton), for: .touchUpInside)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.topStackView.backgroundColor = .clear

        self.bannerImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textSecondary

        self.bottomStackView.backgroundColor = .clear
    }

    func setupBonus(bonus: EveryMatrix.ApplicableBonus) {

        self.titleLabel.text = bonus.name

        self.subtitleLabel.text = bonus.description

        if bonus.url != "" {
            self.hasBannerImage = true
        }
        else {
            self.hasBannerImage = false
        }
    }

}

//
// MARK: - Actions
//
extension BonusAvailableTableViewCell {
    @objc private func didTapMoreInfoButton() {
        print("More Info")
        self.didTapMoreInfoAction?()
    }

    @objc private func didTapGetBonusButton() {
        print("Get Bonus")
        self.didTapGetBonusAction?()
    }

}

//
// MARK: Subviews initialization and setup
//
extension BonusAvailableTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.button
        view.layer.masksToBounds = true
        return view
    }

    private static func createTopStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }

    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo_horizontal_large")
        imageView.isHidden = true
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title here"
        label.numberOfLines = 0
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle here"
        label.numberOfLines = 0
        label.font = AppFont.with(type: .semibold, size: 11)
        label.textAlignment = .left
        return label
    }

    private static func createBottomStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 18
        return stackView
    }

    private static func createMoreInfoButton() -> UIButton {
        let button = UIButton()
        StyleHelper.styleInfoButton(button: button)
        button.setTitle(localized("more_info"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        return button
    }

    private static func createGetBonusButton() -> UIButton {
        let button = UIButton()
        StyleHelper.styleButton(button: button)
        button.setTitle(localized("get_bonus"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        return button
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.topStackView)

        self.topStackView.addArrangedSubview(self.bannerImageView)
        self.topStackView.addArrangedSubview(self.titleLabel)
        self.topStackView.addArrangedSubview(self.subtitleLabel)

        self.containerView.addSubview(self.bottomStackView)

        self.bottomStackView.addArrangedSubview(self.moreInfoButton)
        self.bottomStackView.addArrangedSubview(self.getBonusButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 25),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -25)

        ])

        // Top stack view
        NSLayoutConstraint.activate([
            self.topStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.topStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.topStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 25),

            self.bannerImageView.leadingAnchor.constraint(equalTo: self.topStackView.leadingAnchor),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.topStackView.trailingAnchor),
            self.bannerImageView.heightAnchor.constraint(equalToConstant: 75),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.topStackView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.topStackView.trailingAnchor),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.topStackView.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.topStackView.trailingAnchor)

        ])

        // Bottom stack view
        NSLayoutConstraint.activate([
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.bottomStackView.topAnchor.constraint(equalTo: self.topStackView.bottomAnchor, constant: 16),
            self.bottomStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -25),
            self.bottomStackView.heightAnchor.constraint(equalToConstant: 50),

            self.moreInfoButton.centerYAnchor.constraint(equalTo: self.bottomStackView.centerYAnchor),

            self.getBonusButton.centerYAnchor.constraint(equalTo: self.bottomStackView.centerYAnchor)
        ])

    }

}
