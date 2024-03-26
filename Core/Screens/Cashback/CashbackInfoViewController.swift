//
//  CashbackInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2023.
//

import UIKit

class CashbackInfoViewController: UIViewController {

    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationTitleLabel: UILabel = Self.createNavigationTitleLabel()

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

    private lazy var bottomBannerImageView: UIImageView = Self.createBottomBannerImageView()

    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private lazy var termsContainerView: UIView = Self.createTermsContainerView()
    private lazy var termsView: UIView = Self.createTermsView()
    private lazy var termsTitleLabel: UILabel = Self.createTermsTitleLabel()
    private lazy var termsToggleButton: UIButton = Self.createTermsToggleButton()
    private lazy var termsDescriptionLabel: UILabel = Self.createTermsDescriptionLabel()

    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()

    private lazy var bottomBannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBottomBannerImageViewFixedHeightConstraint()
    private lazy var bottomBannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBottomBannerImageViewDynamicHeightConstraint()

    private lazy var termsViewBottomConstraint: NSLayoutConstraint = Self.createTermsViewBottomConstraint()
    private lazy var termsDescriptionLabelBottomConstraint: NSLayoutConstraint = Self.createTermsDescriptionLabelBottomConstraint()

    private var aspectRatio: CGFloat = 1.0

    var isTermsCollapsed = true {
        didSet {
            if isTermsCollapsed {
                self.termsToggleButton.setImage(UIImage(named: "arrow_down_icon"), for: .normal)

                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.termsDescriptionLabel.alpha = 0
                }, completion: { _ in
                    self.termsDescriptionLabel.isHidden = true
                })
                self.termsViewBottomConstraint.isActive = true
                self.termsDescriptionLabelBottomConstraint.isActive = false

            }
            else {
                self.termsToggleButton.setImage(UIImage(named: "arrow_up_icon"), for: .normal)

                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    if self.termsDescriptionLabel.alpha != self.enabledAlpha && self.termsDescriptionLabel.alpha != 0 {
                        self.termsDescriptionLabel.alpha = self.disabledAlpha
                    }
                    else {
                        self.termsDescriptionLabel.alpha = self.enabledAlpha
                    }
                    self.termsDescriptionLabel.isHidden = false
                }, completion: { _ in
                })
                self.termsViewBottomConstraint.isActive = false
                self.termsDescriptionLabelBottomConstraint.isActive = true

            }
        }
    }

    var disabledAlpha: CGFloat = 0.7
    var enabledAlpha: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.isTermsCollapsed = true

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        let termsToggleTap = UITapGestureRecognizer(target: self, action: #selector(didTapToggleButton))
        self.termsView.addGestureRecognizer(termsToggleTap)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.cashbackInfoBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackBetBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackBalanceBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackUsedBaseView.layer.cornerRadius = CornerRadius.card

        self.cashbackUsedExampleView.layer.cornerRadius = CornerRadius.headerInput

        self.resizeBannerImageView()

        self.resizeBottomBannerImageView()
    }

    private func setupWithTheme() {

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = .clear

        self.navigationTitleLabel.textColor = UIColor.App.textPrimary

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

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.termsContainerView.backgroundColor = .clear

        self.termsView.backgroundColor = .clear

        self.termsTitleLabel.textColor = UIColor.App.textSecondary

        self.termsToggleButton.backgroundColor = .clear
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

    private func resizeBottomBannerImageView() {

        if let bannerImage = self.bannerImageView.image {

            self.aspectRatio = bannerImage.size.width/bannerImage.size.height

            self.bottomBannerImageViewFixedHeightConstraint.isActive = false

            self.bottomBannerImageViewDynamicHeightConstraint =
            NSLayoutConstraint(item: self.bottomBannerImageView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self.bottomBannerImageView,
                               attribute: .width,
                               multiplier: 1/self.aspectRatio,
                               constant: 0)

            self.bottomBannerImageViewDynamicHeightConstraint.isActive = true
        }
    }

    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapToggleButton() {

        self.isTermsCollapsed = !self.isTermsCollapsed
    }
}

extension CashbackInfoViewController {

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "arrow_back_icon")
        button.setImage(image, for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 20)
        label.text = localized("replay")
        label.textAlignment = .center
        return label
    }

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
        imageView.image = UIImage(named: "replay_big_banner")
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
        label.text = localized("replay_page_section_1_title")
        label.textAlignment = .left
        return label
    }

    private static func createCashbackInfoDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("replay_page_section_1_description")
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
        label.text = localized("replay_page_section_2_title")
        label.textAlignment = .left
        return label
    }

    private static func createCashbackBetDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("replay_page_section_2_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createCashbackBetIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_big_blue_icon")
        imageView.contentMode = .scaleAspectFit
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
        label.text = localized("replay_page_section_3_title")
        label.textAlignment = .left
        return label
    }

    private static func createCashbackBalanceDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("replay_page_section_3_description_1")
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
        label.text = localized("replay_page_section_3_description_2")
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
        label.text = localized("replay_page_section_4_title")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createCashbackUsedDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("replay_page_section_4_description")
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

    private static func createBottomBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "replay_bottom_banner")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTermsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTermsView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTermsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.text = localized("terms_and_conditions")
        label.textAlignment = .center
        return label
    }

    private static func createTermsToggleButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_down_icon"), for: .normal)
        return button
    }

    private static func createTermsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = localized("promotions_replay_terms_and_conditions")
        label.textAlignment = .left
        label.numberOfLines = 0

        let text = localized("promotions_replay_terms_and_conditions")
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: localized("promotions_replay_terms_and_conditions"))
        var range = (text as NSString).range(of: "•")

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.lineSpacing = 2
        paragraphStyle.alignment = .left

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.textPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .bold, size: 14), range: fullRange)

        while range.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)
            range = (text as NSString).range(of: "•", range: NSRange(location: range.location + 1, length: text.count - range.location - 1))
        }

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString

        return label
    }

    // Constraints
    private static func createNavigationTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createScrollTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBottomBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBottomBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createTermsViewBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createTermsDescriptionLabelBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.navigationTitleLabel)

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

        self.containerView.addSubview(self.bottomBannerImageView)

        self.containerView.addSubview(self.separatorLineView)

        self.containerView.addSubview(self.termsContainerView)

        self.termsContainerView.addSubview(self.termsView)

        self.termsView.addSubview(self.termsTitleLabel)
        self.termsView.addSubview(self.termsToggleButton)

        self.termsContainerView.addSubview(self.termsDescriptionLabel)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.heightAnchor.constraint(equalTo: self.backButton.widthAnchor),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 50),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -50),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([

            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
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

            self.cashbackBetIconImageView.widthAnchor.constraint(equalToConstant: 25),
            self.cashbackBetIconImageView.heightAnchor.constraint(equalTo: self.cashbackBetIconImageView.widthAnchor),
            self.cashbackBetIconImageView.topAnchor.constraint(equalTo: self.cashbackBetDescriptionLabel.bottomAnchor, constant: 4),
            self.cashbackBetIconImageView.bottomAnchor.constraint(equalTo: self.cashbackBetBaseView.bottomAnchor, constant: -16),
            self.cashbackBetIconImageView.centerXAnchor.constraint(equalTo: self.cashbackBetBaseView.centerXAnchor)
        ])

        // Cashback Balance
        NSLayoutConstraint.activate([
            self.cashbackBalanceBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.cashbackBalanceBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.cashbackBalanceBaseView.topAnchor.constraint(equalTo: self.bottomBannerImageView.bottomAnchor, constant: 16),

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

        // Bottom banner
        NSLayoutConstraint.activate([
            self.bottomBannerImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bottomBannerImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bottomBannerImageView.topAnchor.constraint(equalTo: self.cashbackBetBaseView.bottomAnchor, constant: 20),
        ])

        // Terms info
        NSLayoutConstraint.activate([
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.separatorLineView.topAnchor.constraint(equalTo: self.cashbackUsedBaseView.bottomAnchor, constant: 20),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.termsContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.termsContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.termsContainerView.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 20),
            self.termsContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.termsView.topAnchor.constraint(equalTo: self.termsContainerView.topAnchor),
            self.termsView.centerXAnchor.constraint(equalTo: self.termsContainerView.centerXAnchor),

            self.termsTitleLabel.leadingAnchor.constraint(equalTo: self.termsView.leadingAnchor),
            self.termsTitleLabel.topAnchor.constraint(equalTo: self.termsView.topAnchor, constant: 10),
            self.termsTitleLabel.bottomAnchor.constraint(equalTo: self.termsView.bottomAnchor, constant: -10),

            self.termsToggleButton.leadingAnchor.constraint(equalTo: self.termsTitleLabel.trailingAnchor, constant: 5),
            self.termsToggleButton.trailingAnchor.constraint(equalTo: self.termsView.trailingAnchor),
            self.termsToggleButton.heightAnchor.constraint(equalToConstant: 20),
            self.termsToggleButton.centerYAnchor.constraint(equalTo: self.termsTitleLabel.centerYAnchor),

            self.termsDescriptionLabel.leadingAnchor.constraint(equalTo: self.termsContainerView.leadingAnchor),
            self.termsDescriptionLabel.trailingAnchor.constraint(equalTo: self.termsContainerView.trailingAnchor),
            self.termsDescriptionLabel.topAnchor.constraint(equalTo: self.termsView.bottomAnchor, constant: 5)

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

        self.bottomBannerImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bottomBannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.bottomBannerImageViewFixedHeightConstraint.isActive = true

        self.bottomBannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bottomBannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bottomBannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.bottomBannerImageViewDynamicHeightConstraint.isActive = false

        self.termsViewBottomConstraint =
        NSLayoutConstraint(item: self.termsView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.termsContainerView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0)
        self.termsViewBottomConstraint.isActive = true

        self.termsDescriptionLabelBottomConstraint =
        NSLayoutConstraint(item: self.termsDescriptionLabel,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.termsContainerView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0)
        self.termsDescriptionLabelBottomConstraint.isActive = false
    }
}
