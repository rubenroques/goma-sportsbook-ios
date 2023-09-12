//
//  CashbackRootViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 22/06/2023.
//

import UIKit

class CashbackRootViewController: UIViewController {

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()

    private lazy var cashbackInfoBaseView: UIView = Self.createCashbackInfoBaseView()
    private lazy var cashbackInfoTitleLabel: UILabel = Self.createCashbackInfoTitleLabel()
    private lazy var cashbackInfoDescriptionLabel: UILabel = Self.createCashbackInfoDescriptionLabel()

    private lazy var cashbackBetBaseView: UIView = Self.createCashbackBetBaseView()
    private lazy var cashbackBetTitleLabel: UILabel = Self.createCashbackBetTitleLabel()
    private lazy var cashbackBetDescriptionLabel: UILabel = Self.createCashbackBetDescriptionLabel()
    private lazy var cashbackBetIconImageView: UIImageView = Self.createCashbackBetIconImageView()

    private lazy var cashbackBalanceBaseView: UIView = Self.createCashbackBalanceBaseView()
    private lazy var cashbackBalanceTitleLabel: UILabel = Self.createCashbackBalanceTitleLabel()
    private lazy var cashbackBalanceDescriptionLabel: UILabel = Self.createCashbackBalanceDescriptionLabel()
    private lazy var cashbackBalanceExampleView: CashbackBalanceView = Self.createCashbackBalanceExampleView()
    private lazy var cashbackBalanceEndingLabel: UILabel = Self.createCashbackBalanceEndingLabel()

    private lazy var cashbackUsedBaseView: UIView = Self.createCashbackUsedBaseView()
    private lazy var cashbackUsedTitleLabel: UILabel = Self.createCashbackUsedTitleLabel()
    private lazy var cashbackUsedDescriptionLabel: UILabel = Self.createCashbackUsedDescriptionLabel()
    private lazy var cashbackUsedExampleView: UIView = Self.createCashbackUsedExampleView()
    private lazy var cashbackUsedExampleTitleLabel: UILabel = Self.createCashbackUsedExampleTitleLabel()

    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()

    private var aspectRatio: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.cashbackInfoBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackBetBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackBalanceBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackUsedBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackUsedExampleView.layer.cornerRadius = CornerRadius.headerInput

        self.resizeBannerImageView()
    }

    private func setupWithTheme() {

        self.scrollView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.cashbackInfoBaseView.backgroundColor = UIColor.App.backgroundCards

        self.cashbackInfoTitleLabel.textColor = UIColor.App.highlightPrimary

        self.cashbackInfoDescriptionLabel.textColor = UIColor.App.textPrimary

        self.cashbackBetBaseView.backgroundColor = UIColor.App.backgroundCards

        self.cashbackBetTitleLabel.textColor = UIColor.App.highlightPrimary

        self.cashbackBetDescriptionLabel.textColor = UIColor.App.textPrimary

        self.cashbackBalanceBaseView.backgroundColor = UIColor.App.backgroundCards

        self.cashbackBalanceTitleLabel.textColor = UIColor.App.highlightPrimary

        self.cashbackBalanceDescriptionLabel.textColor = UIColor.App.textPrimary

        self.cashbackBalanceEndingLabel.textColor = UIColor.App.textPrimary

        self.cashbackUsedBaseView.backgroundColor = UIColor.App.backgroundCards

        self.cashbackUsedTitleLabel.textColor = UIColor.App.highlightPrimary

        self.cashbackUsedDescriptionLabel.textColor = UIColor.App.textPrimary

        self.cashbackUsedExampleView.backgroundColor = UIColor.App.highlightSecondary

        self.cashbackUsedExampleTitleLabel.textColor = UIColor.App.buttonTextPrimary

    }

    private func resizeBannerImageView() {

        if let bannerImage = self.bannerImageView.image {

            self.aspectRatio = bannerImage.size.width/bannerImage.size.height

            self.bannerImageViewFixedHeightConstraint.isActive = false

            self.bannerImageViewDynamicHeightConstraint =
            NSLayoutConstraint(item: self.bannerImageView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self.bannerImageView,
                               attribute: .width,
                               multiplier: 1/self.aspectRatio,
                               constant: 0)

            self.bannerImageViewDynamicHeightConstraint.isActive = true
        }
    }

    func scrollToTop() {

        let topOffset = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
        self.scrollView.setContentOffset(topOffset, animated: true)

    }

    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CashbackRootViewController {

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView

    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betsson_banner")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createCashbackInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackInfoTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("first_info_title_replay")
        label.textAlignment = .left
        return label
    }

    private static func createCashbackInfoDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("first_info_descrition_replay")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createCashbackBetBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackBetTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("second_info_title_replay")
        label.textAlignment = .left
        return label
    }

    private static func createCashbackBetDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("second_info_descrition_replay")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createCashbackBetIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_big_blue_icon")
        imageView.contentMode = .center
        return imageView
    }

    private static func createCashbackBalanceBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackBalanceTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("third_info_title_replay")
        label.textAlignment = .left
        return label
    }

    private static func createCashbackBalanceDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("third_info_descrition_one_replay")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createCashbackBalanceExampleView() -> CashbackBalanceView {
        let cashbackBalanceView = CashbackBalanceView()
        cashbackBalanceView.translatesAutoresizingMaskIntoConstraints = false
        cashbackBalanceView.isInteractionEnabled = false
        cashbackBalanceView.isSwitchOn = true
        return cashbackBalanceView
    }

    private static func createCashbackBalanceEndingLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("third_info_descrition_two_replay")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createCashbackUsedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackUsedTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("fourth_info_title_replay")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createCashbackUsedDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("fourth_info_descrition_replay")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createCashbackUsedExampleView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackUsedExampleTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.text = localized("used_replay").uppercased()
        label.textAlignment = .left
        return label
    }

    // Constraints
    private static func createBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.containerView)

        self.containerView.addSubview(self.bannerImageView)

        self.containerView.addSubview(self.cashbackInfoBaseView)

        self.cashbackInfoBaseView.addSubview(self.cashbackInfoTitleLabel)
        self.cashbackInfoBaseView.addSubview(self.cashbackInfoDescriptionLabel)

        self.containerView.addSubview(self.cashbackBetBaseView)

        self.cashbackBetBaseView.addSubview(self.cashbackBetTitleLabel)
        self.cashbackBetBaseView.addSubview(self.cashbackBetDescriptionLabel)
        self.cashbackBetBaseView.addSubview(self.cashbackBetIconImageView)

        self.containerView.addSubview(self.cashbackBalanceBaseView)

        self.cashbackBalanceBaseView.addSubview(self.cashbackBalanceTitleLabel)
        self.cashbackBalanceBaseView.addSubview(self.cashbackBalanceDescriptionLabel)
        self.cashbackBalanceBaseView.addSubview(self.cashbackBalanceExampleView)
        self.cashbackBalanceBaseView.addSubview(self.cashbackBalanceEndingLabel)

        self.containerView.addSubview(self.cashbackUsedBaseView)

        self.cashbackUsedBaseView.addSubview(self.cashbackUsedTitleLabel)
        self.cashbackUsedBaseView.addSubview(self.cashbackUsedDescriptionLabel)
        self.cashbackUsedBaseView.addSubview(self.cashbackUsedExampleView)

        self.cashbackUsedExampleView.addSubview(self.cashbackUsedExampleTitleLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.containerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

            self.bannerImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bannerImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor)
        ])

        // Cashback Info
        NSLayoutConstraint.activate([
            self.cashbackInfoBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.cashbackInfoBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.cashbackInfoBaseView.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 35),

            self.cashbackInfoTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackInfoBaseView.leadingAnchor, constant: 16),
            self.cashbackInfoTitleLabel.trailingAnchor.constraint(equalTo: self.cashbackInfoBaseView.trailingAnchor, constant: -16),
            self.cashbackInfoTitleLabel.topAnchor.constraint(equalTo: self.cashbackInfoBaseView.topAnchor, constant: 16),

            self.cashbackInfoDescriptionLabel.leadingAnchor.constraint(equalTo: self.cashbackInfoTitleLabel.leadingAnchor),
            self.cashbackInfoDescriptionLabel.trailingAnchor.constraint(equalTo: self.cashbackInfoTitleLabel.trailingAnchor),
            self.cashbackInfoDescriptionLabel.topAnchor.constraint(equalTo: self.cashbackInfoTitleLabel.bottomAnchor, constant: 7),
            self.cashbackInfoDescriptionLabel.bottomAnchor.constraint(equalTo: self.cashbackInfoBaseView.bottomAnchor, constant: -16)
        ])

        // Cashback bet
        NSLayoutConstraint.activate([
            self.cashbackBetBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.cashbackBetBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.cashbackBetBaseView.topAnchor.constraint(equalTo: self.cashbackInfoBaseView.bottomAnchor, constant: 16),

            self.cashbackBetTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackBetBaseView.leadingAnchor, constant: 16),
            self.cashbackBetTitleLabel.trailingAnchor.constraint(equalTo: self.cashbackBetBaseView.trailingAnchor, constant: -16),
            self.cashbackBetTitleLabel.topAnchor.constraint(equalTo: self.cashbackBetBaseView.topAnchor, constant: 16),

            self.cashbackBetDescriptionLabel.leadingAnchor.constraint(equalTo: self.cashbackBetTitleLabel.leadingAnchor),
            self.cashbackBetDescriptionLabel.trailingAnchor.constraint(equalTo: self.cashbackBetTitleLabel.trailingAnchor),
            self.cashbackBetDescriptionLabel.topAnchor.constraint(equalTo: self.cashbackBetTitleLabel.bottomAnchor, constant: 7),

            self.cashbackBetIconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.cashbackBetIconImageView.heightAnchor.constraint(equalTo: self.cashbackBetIconImageView.widthAnchor),
            self.cashbackBetIconImageView.topAnchor.constraint(equalTo: self.cashbackBetDescriptionLabel.bottomAnchor, constant: 4),
            self.cashbackBetIconImageView.bottomAnchor.constraint(equalTo: self.cashbackBetBaseView.bottomAnchor, constant: -16),
            self.cashbackBetIconImageView.centerXAnchor.constraint(equalTo: self.cashbackBetBaseView.centerXAnchor)
        ])

        // Cashback Balance
        NSLayoutConstraint.activate([
            self.cashbackBalanceBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.cashbackBalanceBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.cashbackBalanceBaseView.topAnchor.constraint(equalTo: self.cashbackBetBaseView.bottomAnchor, constant: 16),

            self.cashbackBalanceTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackBalanceBaseView.leadingAnchor, constant: 16),
            self.cashbackBalanceTitleLabel.trailingAnchor.constraint(equalTo: self.cashbackBalanceBaseView.trailingAnchor, constant: -16),
            self.cashbackBalanceTitleLabel.topAnchor.constraint(equalTo: self.cashbackBalanceBaseView.topAnchor, constant: 16),

            self.cashbackBalanceDescriptionLabel.leadingAnchor.constraint(equalTo: self.cashbackBalanceTitleLabel.leadingAnchor),
            self.cashbackBalanceDescriptionLabel.trailingAnchor.constraint(equalTo: self.cashbackBalanceTitleLabel.trailingAnchor),
            self.cashbackBalanceDescriptionLabel.topAnchor.constraint(equalTo: self.cashbackBalanceTitleLabel.bottomAnchor, constant: 7),

            self.cashbackBalanceExampleView.leadingAnchor.constraint(greaterThanOrEqualTo: self.cashbackBalanceBaseView.leadingAnchor, constant: 16),
            self.cashbackBalanceExampleView.trailingAnchor.constraint(lessThanOrEqualTo: self.cashbackBalanceBaseView.trailingAnchor, constant: -16),
            self.cashbackBalanceExampleView.topAnchor.constraint(equalTo: self.cashbackBalanceDescriptionLabel.bottomAnchor, constant: 10),
            self.cashbackBalanceExampleView.centerXAnchor.constraint(equalTo: self.cashbackBalanceBaseView.centerXAnchor),

            self.cashbackBalanceEndingLabel.leadingAnchor.constraint(equalTo: self.cashbackBalanceTitleLabel.leadingAnchor),
            self.cashbackBalanceEndingLabel.trailingAnchor.constraint(equalTo: self.cashbackBalanceTitleLabel.trailingAnchor),
            self.cashbackBalanceEndingLabel.topAnchor.constraint(equalTo: self.cashbackBalanceExampleView.bottomAnchor, constant: 10),
            self.cashbackBalanceEndingLabel.bottomAnchor.constraint(equalTo: self.cashbackBalanceBaseView.bottomAnchor, constant: -16)

        ])

        // Cashback Used
        NSLayoutConstraint.activate([
            self.cashbackUsedBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.cashbackUsedBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.cashbackUsedBaseView.topAnchor.constraint(equalTo: self.cashbackBalanceBaseView.bottomAnchor, constant: 16),
            self.cashbackUsedBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.cashbackUsedTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackUsedBaseView.leadingAnchor, constant: 16),
            self.cashbackUsedTitleLabel.trailingAnchor.constraint(equalTo: self.cashbackUsedBaseView.trailingAnchor, constant: -16),
            self.cashbackUsedTitleLabel.topAnchor.constraint(equalTo: self.cashbackUsedBaseView.topAnchor, constant: 16),

            self.cashbackUsedDescriptionLabel.leadingAnchor.constraint(equalTo: self.cashbackUsedTitleLabel.leadingAnchor),
            self.cashbackUsedDescriptionLabel.trailingAnchor.constraint(equalTo: self.cashbackUsedTitleLabel.trailingAnchor),
            self.cashbackUsedDescriptionLabel.topAnchor.constraint(equalTo: self.cashbackUsedTitleLabel.bottomAnchor, constant: 7),

            self.cashbackUsedExampleView.topAnchor.constraint(equalTo: self.cashbackUsedDescriptionLabel.bottomAnchor, constant: 4),
            self.cashbackUsedExampleView.bottomAnchor.constraint(equalTo: self.cashbackUsedBaseView.bottomAnchor, constant: -16),
            self.cashbackUsedExampleView.centerXAnchor.constraint(equalTo: self.cashbackUsedBaseView.centerXAnchor),

            self.cashbackUsedExampleTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackUsedExampleView.leadingAnchor, constant: 8),
            self.cashbackUsedExampleTitleLabel.trailingAnchor.constraint(equalTo: self.cashbackUsedExampleView.trailingAnchor, constant: -8),
            self.cashbackUsedExampleTitleLabel.topAnchor.constraint(equalTo: cashbackUsedExampleView.topAnchor, constant: 3),
            self.cashbackUsedExampleTitleLabel.bottomAnchor.constraint(equalTo: self.cashbackUsedExampleView.bottomAnchor, constant: -3)

        ])

        self.bannerImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.bannerImageViewFixedHeightConstraint.isActive = true

        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false
    }
}
