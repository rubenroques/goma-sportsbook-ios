//
//  FooterResponsibleGamingView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/03/2023.
//

import Foundation
import UIKit

class FooterResponsibleGamingView: UIView {

    private lazy var baseStackView: UIStackView = Self.createBaseStackView()

    private lazy var topView: UIView = Self.createTopView()
    private lazy var topLabel: UILabel = Self.createTopLabel()
    private lazy var bottomLabel: UILabel = Self.createBottomLabel()

    private lazy var ageBaseView: UIView = Self.createAgeBaseView()
    private lazy var ageLabel: UILabel = Self.createAgeLabel()

    private lazy var linksBaseView: UIView = Self.createView()
    private lazy var linksStackView: UIStackView = Self.createLinksStackView()

    private lazy var affiliateSystemLabel: UILabel = Self.createLinkLabel()
    private lazy var privacyPolicyLabel: UILabel = Self.createLinkLabel()
    private lazy var securityRulesLabel: UILabel = Self.createLinkLabel()
    private lazy var cookiePolicyLabel: UILabel = Self.createLinkLabel()
    private lazy var sportsBettingRulesLabel: UILabel = Self.createLinkLabel()
    private lazy var termsAndConditionsLabel: UILabel = Self.createLinkLabel()
    private lazy var aboutLabel: UILabel = Self.createLinkLabel()
    private lazy var faqLabel: UILabel = Self.createLinkLabel()
    private lazy var responsibleGamblingLabel: UILabel = Self.createLinkLabel()

    private lazy var socialBaseView: UIView = Self.createView()
    private lazy var socialStackView: UIStackView = Self.createSocialStackView()

    private lazy var facebookSocialButton: UIButton = Self.createSocialButton()
    private lazy var youtubeSocialButton: UIButton = Self.createSocialButton()
    private lazy var instagramSocialButton: UIButton = Self.createSocialButton()
    private lazy var twitterSocialButton: UIButton = Self.createSocialButton()

    // MARK: - Lifetime and Cycle
    init() {
        super.init(frame: .zero)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.setupSubviews()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBaseView))
        self.topView.addGestureRecognizer(tapGestureRecognizer)

        // Set text for each label
        self.affiliateSystemLabel.text = localized("affiliate_system")
        self.privacyPolicyLabel.text = localized("privacy_policy")
        self.securityRulesLabel.text = localized("security_rules_footer_link")
        self.cookiePolicyLabel.text = localized("cookie_policy")
        self.sportsBettingRulesLabel.text = localized("sport_betting_rules")
        self.termsAndConditionsLabel.text = localized("terms_and_conditions")
        self.aboutLabel.text = localized("about_us")
        self.faqLabel.text = localized("faqs")
        self.responsibleGamblingLabel.text = localized("responsible_gambling")

        self.addTapGestureRecognizer(to: self.affiliateSystemLabel, action: #selector(openAffiliateSystemURL))
        self.addTapGestureRecognizer(to: self.responsibleGamblingLabel, action: #selector(openResponsibleGamblingURL))
        self.addTapGestureRecognizer(to: self.privacyPolicyLabel, action: #selector(openPrivacyPolicyURL))
        self.addTapGestureRecognizer(to: self.cookiePolicyLabel, action: #selector(openCookiePolicyURL))
        self.addTapGestureRecognizer(to: self.sportsBettingRulesLabel, action: #selector(openSportsBettingRulesURL))
        self.addTapGestureRecognizer(to: self.termsAndConditionsLabel, action: #selector(openTermsAndConditionsURL))
        self.addTapGestureRecognizer(to: self.aboutLabel, action: #selector(openAboutURL))
        self.addTapGestureRecognizer(to: self.faqLabel, action: #selector(openFAQsURL))

        self.facebookSocialButton.setImage(UIImage(named: "facebook_icon_mono")?.withRenderingMode(.alwaysTemplate),
                                           for: .normal)
        self.youtubeSocialButton.setImage(UIImage(named: "youtube_icon_mono")?.withRenderingMode(.alwaysTemplate),
                                          for: .normal)
        self.instagramSocialButton.setImage(UIImage(named: "instagram_icon_mono")?.withRenderingMode(.alwaysTemplate),
                                            for: .normal)
        self.twitterSocialButton.setImage(UIImage(named: "twitter_icon_mono")?.withRenderingMode(.alwaysTemplate),
                                          for: .normal)

        self.facebookSocialButton.addTarget(self, action: #selector(openFacebookURL), for: .primaryActionTriggered)
        self.youtubeSocialButton.addTarget(self, action: #selector(openYoutubeURL), for: .primaryActionTriggered)
        self.instagramSocialButton.addTarget(self, action: #selector(openIntagramURL), for: .primaryActionTriggered)
        self.twitterSocialButton.addTarget(self, action: #selector(openTwitterURL), for: .primaryActionTriggered)

        self.hideLinksView()
        self.hideSocialView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.baseStackView.backgroundColor = .clear

        self.affiliateSystemLabel.textColor = UIColor.App.textPrimary
        self.privacyPolicyLabel.textColor = UIColor.App.textPrimary
        self.securityRulesLabel.textColor = UIColor.App.textPrimary
        self.cookiePolicyLabel.textColor = UIColor.App.textPrimary
        self.sportsBettingRulesLabel.textColor = UIColor.App.textPrimary
        self.termsAndConditionsLabel.textColor = UIColor.App.textPrimary
        self.aboutLabel.textColor = UIColor.App.textPrimary
        self.faqLabel.textColor = UIColor.App.textPrimary
        self.responsibleGamblingLabel.textColor = UIColor.App.textPrimary

        self.facebookSocialButton.tintColor = UIColor.App.textPrimary
        self.youtubeSocialButton.tintColor = UIColor.App.textPrimary
        self.instagramSocialButton.tintColor = UIColor.App.textPrimary
        self.twitterSocialButton.tintColor = UIColor.App.textPrimary
    }

    func hideLinksView() {
        self.linksBaseView.isHidden = true
    }

    func hideSocialView() {
        self.socialBaseView.isHidden = true
    }

    func showLinksView() {
        self.linksBaseView.isHidden = false
    }

    func showSocialView() {
        self.socialBaseView.isHidden = false
    }

    @objc func didTapBaseView() {
        if let url = URL(string: "https://www.joueurs-info-service.fr/") {
            UIApplication.shared.open(url)
        }
    }

    @objc func openAffiliateSystemURL() {
        self.openURL("http://www.partenaire-betsson.fr/")
    }

    @objc func openResponsibleGamblingURL() {
        let url = "\(TargetVariables.clientBaseUrl)/fr/jeu-responsable"
        self.openURL(url)
    }

    @objc func openPrivacyPolicyURL() {
        let url = "\(TargetVariables.clientBaseUrl)/fr/politique-de-confidentialite"
        self.openURL(url)
    }

    @objc func openCookiePolicyURL() {
        let url = "\(TargetVariables.clientBaseUrl)/fr/politique-de-confidentialite/#cookies"
        self.openURL(url)
    }

    @objc func openSportsBettingRulesURL() {
        let url = "\(TargetVariables.clientBaseUrl)/betting-rules.pdf"
        self.openURL(url)
    }

    @objc func openTermsAndConditionsURL() {
        let url = "\(TargetVariables.clientBaseUrl)/terms-and-conditions.pdf"
        self.openURL(url)
    }

    @objc func openAboutURL() {
        let url = "\(TargetVariables.clientBaseUrl)/fr/about"
        self.openURL(url)
    }

    @objc func openFAQsURL() {
        self.openURL("https://betssonfrance.zendesk.com/hc/fr")
    }

    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func openFacebookURL() {
        self.openURL("https://www.facebook.com/profile.php?id=61551148828863&locale=fr_FR")
    }

    @objc func openYoutubeURL() {
        self.openURL("https://www.youtube.com/channel/UCVYLZg-cDBbe1h8ege0N5Eg")
    }

    @objc func openIntagramURL() {
        self.openURL("https://www.instagram.com/betssonfrance/")
    }

    @objc func openTwitterURL() {
        self.openURL("https://twitter.com/BetssonFR")
    }
}

extension FooterResponsibleGamingView {

    func addTapGestureRecognizer(to label: UILabel, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
    }

    func createViewWithLabels(leftLabel: UILabel, rightLabel: UILabel) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false

        leftLabel.textAlignment = .left
        rightLabel.textAlignment = .right

        containerView.addSubview(leftLabel)
        containerView.addSubview(rightLabel)

        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 14),
            leftLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            rightLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        return containerView
    }

}

extension FooterResponsibleGamingView {

    private static func createBaseStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLinksStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLinkLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = AppFont.with(type: .semibold, size: 9)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }

    private static func createSocialStackView() -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSocialButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: 0x040626)
        return view
    }

    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = localized("gambling_warning_footer_link")
        label.font = AppFont.with(type: .semibold, size: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }

    private static func createBottomLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = localized("minors_prohibition_footer_link")
        label.font = AppFont.with(type: .semibold, size: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x5559b4)
        return label
    }

    private static func createAgeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 13
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(hex: 0x5559b4).cgColor
        return view
    }

    private static func createAgeLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "+18"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x5559b4)
        return label
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.topView.addSubview(self.topLabel)
        self.topView.addSubview(self.bottomLabel)

        self.topView.addSubview(self.ageBaseView)
        self.ageBaseView.addSubview(self.ageLabel)

        self.baseStackView.addArrangedSubview(self.topView)

        let view1 = self.createViewWithLabels(leftLabel: self.affiliateSystemLabel, rightLabel: self.aboutLabel)
        let view2 = self.createViewWithLabels(leftLabel: self.responsibleGamblingLabel, rightLabel: self.cookiePolicyLabel)
        let view3 = self.createViewWithLabels(leftLabel: self.privacyPolicyLabel, rightLabel: self.termsAndConditionsLabel)
        let view4 = self.createViewWithLabels(leftLabel: self.sportsBettingRulesLabel, rightLabel: self.faqLabel)

        self.linksStackView.addArrangedSubview(view1)
        self.linksStackView.addArrangedSubview(view2)
        self.linksStackView.addArrangedSubview(view3)
        self.linksStackView.addArrangedSubview(view4)

        self.linksBaseView.addSubview(self.linksStackView)
        self.baseStackView.addArrangedSubview(self.linksBaseView)

        self.socialStackView.addArrangedSubview(self.facebookSocialButton)
        self.socialStackView.addArrangedSubview(self.youtubeSocialButton)
        self.socialStackView.addArrangedSubview(self.instagramSocialButton)
        self.socialStackView.addArrangedSubview(self.twitterSocialButton)

        self.socialBaseView.addSubview(self.socialStackView)

        self.baseStackView.addArrangedSubview(self.socialBaseView)

        self.addSubview(self.baseStackView)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            self.baseStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            self.baseStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
        ])

        NSLayoutConstraint.activate([
            self.topLabel.topAnchor.constraint(equalTo: self.topView.topAnchor, constant: 12),
            self.topLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 16),
            self.topLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -16),

            self.topLabel.bottomAnchor.constraint(equalTo: self.bottomLabel.topAnchor, constant: -18),

            self.bottomLabel.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor),
            self.bottomLabel.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: -16),
            self.bottomLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.topView.leadingAnchor),

            self.ageLabel.centerYAnchor.constraint(equalTo: self.ageBaseView.centerYAnchor),
            self.ageLabel.centerXAnchor.constraint(equalTo: self.ageBaseView.centerXAnchor),

            self.ageBaseView.leadingAnchor.constraint(greaterThanOrEqualTo: self.topView.leadingAnchor, constant: 8),
            self.ageBaseView.widthAnchor.constraint(equalToConstant: 26),
            self.ageBaseView.widthAnchor.constraint(equalTo: self.ageBaseView.heightAnchor),
            self.ageBaseView.centerYAnchor.constraint(equalTo: self.bottomLabel.centerYAnchor),
            self.ageBaseView.trailingAnchor.constraint(equalTo: self.bottomLabel.leadingAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            self.linksStackView.leadingAnchor.constraint(equalTo: self.linksBaseView.leadingAnchor),
            self.linksStackView.trailingAnchor.constraint(equalTo: self.linksBaseView.trailingAnchor),
            self.linksStackView.topAnchor.constraint(equalTo: self.linksBaseView.topAnchor),
            self.linksStackView.bottomAnchor.constraint(equalTo: self.linksBaseView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            self.socialStackView.centerXAnchor.constraint(equalTo: self.socialBaseView.centerXAnchor),
            self.socialStackView.topAnchor.constraint(equalTo: self.socialBaseView.topAnchor),
            self.socialStackView.bottomAnchor.constraint(equalTo: self.socialBaseView.bottomAnchor),

            self.facebookSocialButton.heightAnchor.constraint(equalToConstant: 30),
            self.facebookSocialButton.heightAnchor.constraint(equalTo: self.facebookSocialButton.widthAnchor),

            self.youtubeSocialButton.heightAnchor.constraint(equalToConstant: 30),
            self.youtubeSocialButton.heightAnchor.constraint(equalTo: self.youtubeSocialButton.widthAnchor),

            self.instagramSocialButton.heightAnchor.constraint(equalToConstant: 30),
            self.instagramSocialButton.heightAnchor.constraint(equalTo: self.instagramSocialButton.widthAnchor),

            self.twitterSocialButton.heightAnchor.constraint(equalToConstant: 30),
            self.twitterSocialButton.heightAnchor.constraint(equalTo: self.twitterSocialButton.widthAnchor),
        ])
    }
}
