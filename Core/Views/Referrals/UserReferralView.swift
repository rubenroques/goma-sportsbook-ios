//
//  UserReferralView.swift
//  Sportsbook
//
//  Created by André Lascas on 14/07/2023.
//

import UIKit

class UserReferralView: UIView {

    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var iconBaseView: UIView = Self.createIconBaseView()
    private lazy var iconInnerView: UIView = Self.createIconInnerView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var kycStatusView: UIView = Self.createKycStatusView()
    private lazy var kycStatusLabel: UILabel = Self.createKycStatusLabel()
    private lazy var depositView: UIView = Self.createDepositView()
    private lazy var depositLabel: UILabel = Self.createDepositLabel()

    // MARK: Public properties
    var isKycValidated: Bool = false {
        didSet {
            if isKycValidated {
                self.kycStatusView.backgroundColor = UIColor.App.alertSuccess
                self.kycStatusLabel.text = localized("account_validated")
            }
            else {
                self.kycStatusView.backgroundColor = UIColor.App.alertError
                self.kycStatusLabel.text = localized("account_not_validated")

            }
        }
    }

    var hasDeposit: Bool = false {
        didSet {
            if hasDeposit {
                self.depositView.backgroundColor = UIColor.App.alertSuccess
            }
            else {
                self.depositView.backgroundColor = UIColor.App.alertError

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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.squareView

        self.iconBaseView.layer.cornerRadius = self.iconBaseView.frame.height / 2

        self.iconInnerView.layer.cornerRadius = self.iconInnerView.frame.height / 2

        self.kycStatusView.layer.cornerRadius = CornerRadius.squareView

        self.depositView.layer.cornerRadius = CornerRadius.squareView

    }

    func commonInit() {

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.iconBaseView.backgroundColor = UIColor.App.textPrimary

        self.iconInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.highlightPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.kycStatusView.backgroundColor = UIColor.App.alertSuccess

        self.kycStatusLabel.textColor = UIColor.App.buttonTextPrimary

        self.depositView.backgroundColor = UIColor.App.alertSuccess

        self.depositLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func configure(title: String, subtitle: String? = nil, icon: String, isKycValidated: Bool, hasDeposit: Bool) {
        self.titleLabel.text = title

        self.isKycValidated = isKycValidated

        self.hasDeposit = hasDeposit

        self.iconImageView.image = UIImage(named: icon)

        if isKycValidated && hasDeposit {
            self.subtitleLabel.text = localized("referral_bonus_won")
        }
        else if isKycValidated && !hasDeposit {
            self.subtitleLabel.text = localized("referral_deposit_pending")
        }
        else if !isKycValidated {
            self.subtitleLabel.text = localized("referral_account_pending")

        }

        if let subtitle = subtitle {
            self.subtitleLabel.text = subtitle
        }
    }
}

extension UserReferralView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }

    private static func createIconBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "User"
        label.font = AppFont.with(type: .bold, size: 16)
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("referral_bonus_pending")
        label.font = AppFont.with(type: .regular, size: 12)
        label.numberOfLines = 0
        return label
    }

    private static func createKycStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createKycStatusLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("account_validated")
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createDepositView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDepositLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("rf_first_deposit")
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.iconBaseView)

        self.iconBaseView.addSubview(self.iconInnerView)
        self.iconBaseView.addSubview(self.iconImageView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)

        self.containerView.addSubview(self.kycStatusView)

        self.kycStatusView.addSubview(self.kycStatusLabel)

        self.containerView.addSubview(self.depositView)

        self.depositView.addSubview(self.depositLabel)

        self.initConstraints()

        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.iconBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 15),
            self.iconBaseView.widthAnchor.constraint(equalToConstant: 50),
            self.iconBaseView.heightAnchor.constraint(equalTo: self.iconBaseView.widthAnchor),
            self.iconBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10),
            self.iconBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -10),

            self.iconInnerView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor, constant: 1),
            self.iconInnerView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: -1),
            self.iconInnerView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 1),
            self.iconInnerView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor, constant: -1),

            self.iconImageView.leadingAnchor.constraint(equalTo: self.iconBaseView.leadingAnchor),
            self.iconImageView.trailingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor),
            self.iconImageView.bottomAnchor.constraint(equalTo: self.iconBaseView.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.iconBaseView.trailingAnchor, constant: 10),
            self.titleLabel.topAnchor.constraint(equalTo: self.iconBaseView.topAnchor, constant: 5),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -15),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 5),

            self.kycStatusView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 8),
            self.kycStatusView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

            self.kycStatusLabel.leadingAnchor.constraint(equalTo: self.kycStatusView.leadingAnchor, constant: 4),
            self.kycStatusLabel.trailingAnchor.constraint(equalTo: self.kycStatusView.trailingAnchor, constant: -4),
            self.kycStatusLabel.topAnchor.constraint(equalTo: self.kycStatusView.topAnchor, constant: 2),
            self.kycStatusLabel.bottomAnchor.constraint(equalTo: self.kycStatusView.bottomAnchor, constant: -2),

            self.depositView.leadingAnchor.constraint(equalTo: self.kycStatusView.trailingAnchor, constant: 8),
            self.depositView.trailingAnchor.constraint(lessThanOrEqualTo: self.containerView.trailingAnchor, constant: -10),
            self.depositView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),

            self.depositLabel.leadingAnchor.constraint(equalTo: self.depositView.leadingAnchor, constant: 4),
            self.depositLabel.trailingAnchor.constraint(equalTo: self.depositView.trailingAnchor, constant: -4),
            self.depositLabel.topAnchor.constraint(equalTo: self.depositView.topAnchor, constant: 2),
            self.depositLabel.bottomAnchor.constraint(equalTo: self.depositView.bottomAnchor, constant: -2),

        ])

    }

}
