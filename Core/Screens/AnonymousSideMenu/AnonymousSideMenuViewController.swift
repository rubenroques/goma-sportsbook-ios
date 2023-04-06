//
//  AnonymousSideMenuViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/04/2023.
//

import Foundation
import UIKit
import Combine

struct AnonymousSideMenuViewModel {

}

class AnonymousSideMenuViewController: UIViewController {

    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var contentScrollView: UIScrollView = Self.createScrollBaseView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()

    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    private lazy var signUpButtonBaseView: UIView = Self.createView()

    private lazy var menuContainerView: UIView = Self.createView()
    private lazy var menusStackView: UIStackView = Self.createMenusStackView()

    private lazy var versionBaseView: UIView = Self.createView()
    private lazy var versionLabel: UILabel = Self.createVersionLabel()
    private lazy var reservedRightsLabel: UILabel = Self.createReservedRightsLabel()

    private lazy var footerResponsibleGamingView: FooterResponsibleGamingView = Self.createFooterResponsibleGamingView()

    private var viewModel: AnonymousSideMenuViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: AnonymousSideMenuViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()
        self.addMenus()

        if let versionNumber = Bundle.main.versionNumber, let buildNumber = Bundle.main.buildNumber {
            let appVersionRawString = localized("app_version_profile_1")
            let appVersionBuildNumberString = appVersionRawString.replacingOccurrences(of: "{version_1}", with: "(\(buildNumber))")
            let appVersionStringFinal = appVersionBuildNumberString.replacingOccurrences(of: "{version_2}", with: "\(versionNumber)")

            self.versionLabel.text = appVersionStringFinal
            self.reservedRightsLabel.text = localized("app_version_profile_2")
        }

        self.closeButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        self.closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.closeButton.setTitle(localized("close"), for: .normal)
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.closeButton.backgroundColor = .clear
        self.closeButton.setTitleColor( UIColor.App.highlightPrimary, for: .normal)
        self.closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        self.contentBaseView.backgroundColor = .clear
        self.contentStackView.backgroundColor = .clear
        self.menusStackView.backgroundColor = .clear

        self.signUpButtonBaseView.backgroundColor = .blue
    }

    private func addMenus() {

        let promotionsView = NavigationCardView()
        promotionsView.hasNotifications = true
        promotionsView.setupView(title: localized("promotions"), iconTitle: "promotion_icon")
        let messagesTap = UITapGestureRecognizer(target: self, action: #selector(promotionsViewTapped))
        promotionsView.addGestureRecognizer(messagesTap)

        let responsibleGamingView = NavigationCardView()
        responsibleGamingView.setupView(title: localized("responsible_gaming"), iconTitle: "responsible_gaming_icon")
        let responsibleGamingTap = UITapGestureRecognizer(target: self, action: #selector(responsibleGamingViewTapped))
        responsibleGamingView.addGestureRecognizer(responsibleGamingTap)

        let settingsView = NavigationCardView()
        settingsView.setupView(title: localized("app_settings"), iconTitle: "app_settings_profile_icon")
        let settingsTap = UITapGestureRecognizer(target: self, action: #selector(appSettingsViewTapped))
        settingsView.addGestureRecognizer(settingsTap)

        let supportView = NavigationCardView()
        supportView.setupView(title: localized("support"), iconTitle: "support_profile_icon")
        let supportTap = UITapGestureRecognizer(target: self, action: #selector(supportViewTapped))
        supportView.addGestureRecognizer(supportTap)

        self.menusStackView.addArrangedSubview(promotionsView)
        self.menusStackView.addArrangedSubview(responsibleGamingView)
        self.menusStackView.addArrangedSubview(settingsView)
        self.menusStackView.addArrangedSubview(supportView)
    }

    // MARK: - Actions

    @objc func didTapBackButton() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}


extension AnonymousSideMenuViewController {

    @objc func promotionsViewTapped() {
        let promotionsWebViewModel = PromotionsWebViewModel()

        // TODO: Change to prod url when fixed
        let gomaBaseUrl = GomaGamingEnv.stage.baseUrl
        let appLanguage = Locale.current.languageCode

        let isDarkTheme = self.traitCollection.userInterfaceStyle == .dark ? true : false

        let urlString = "\(gomaBaseUrl)/\(appLanguage ?? "fr")/in-app/promotions?dark=\(isDarkTheme)"

        if let url = URL(string: urlString) {

            let promotionsWebViewController = PromotionsWebViewController(url: url, viewModel: promotionsWebViewModel)

            self.navigationController?.pushViewController(promotionsWebViewController, animated: true)
        }
    }

    @objc func responsibleGamingViewTapped() {
        let responsibleGamingViewController = ResponsibleGamingViewController()
        self.navigationController?.pushViewController(responsibleGamingViewController, animated: true)
    }

    @objc func appSettingsViewTapped() {
        let appSettingsViewController = AppSettingsViewController()
        self.navigationController?.pushViewController(appSettingsViewController, animated: true)
    }

    @objc func supportViewTapped() {
        let supportViewController = SupportPageViewController(viewModel: SupportPageViewModel())
        self.navigationController?.pushViewController(supportViewController, animated: true)
    }

}


//
// MARK: - Subviews Initialization and Setup
//
extension AnonymousSideMenuViewController {

    private static func createView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        return button
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Menu"
        titleLabel.font = AppFont.with(type: .bold, size: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollBaseView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createContentStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 26
        return view
    }

    private static func createMenusStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.axis = .vertical
        view.spacing = 8
        return view
    }

    private static func createVersionLabel() -> UILabel {
        let label = UILabel()
        label.text = "App Version"
        label.font = AppFont.with(type: .medium, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label

    }

    private static func createReservedRightsLabel() -> UILabel {
        let label = UILabel()
        label.text = "All Rights Reserved"
        label.font = AppFont.with(type: .medium, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label

    }

    private static func createFooterResponsibleGamingView() -> FooterResponsibleGamingView {
        let view = FooterResponsibleGamingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.closeButton)

        self.versionBaseView.addSubview(self.versionLabel)
        self.versionBaseView.addSubview(self.reservedRightsLabel)

        self.menuContainerView.addSubview(self.menusStackView)

        self.contentStackView.addArrangedSubview(self.signUpButtonBaseView)
        self.contentStackView.addArrangedSubview(menuContainerView)
        self.contentStackView.addArrangedSubview(self.versionBaseView)
        self.contentStackView.addArrangedSubview(self.footerResponsibleGamingView)

        self.contentBaseView.addSubview(self.contentStackView)

        self.contentScrollView.addSubview(self.contentBaseView)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)
        self.view.addSubview(self.contentScrollView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationBaseView.heightAnchor.constraint(equalToConstant: 70),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.closeButton.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.navigationBaseView.trailingAnchor, constant: -27),
            self.closeButton.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        NSLayoutConstraint.activate([
            self.contentScrollView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.contentBaseView.topAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.leadingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.bottomAnchor),

            self.contentBaseView.widthAnchor.constraint(equalTo: self.contentScrollView.frameLayoutGuide.widthAnchor),

            self.contentStackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),
            self.contentStackView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),
        ])


        NSLayoutConstraint.activate([
            self.menusStackView.leadingAnchor.constraint(equalTo: self.menuContainerView.leadingAnchor, constant: 24),
            self.menusStackView.trailingAnchor.constraint(equalTo: self.menuContainerView.trailingAnchor, constant: -24),
            self.menusStackView.bottomAnchor.constraint(equalTo: self.menuContainerView.bottomAnchor),
            self.menusStackView.topAnchor.constraint(equalTo: self.menuContainerView.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.signUpButtonBaseView.heightAnchor.constraint(equalToConstant: 80),
        ])

        NSLayoutConstraint.activate([
            self.versionLabel.topAnchor.constraint(equalTo: self.versionBaseView.topAnchor, constant: 8),
            self.versionLabel.heightAnchor.constraint(equalToConstant: 14),
            self.versionLabel.leadingAnchor.constraint(equalTo: self.versionBaseView.leadingAnchor, constant: 8),
            self.versionLabel.centerXAnchor.constraint(equalTo: self.versionBaseView.centerXAnchor),

            self.reservedRightsLabel.topAnchor.constraint(equalTo: self.versionLabel.bottomAnchor, constant: 2),

            self.reservedRightsLabel.heightAnchor.constraint(equalToConstant: 14),
            self.reservedRightsLabel.leadingAnchor.constraint(equalTo: self.versionBaseView.leadingAnchor, constant: 8),
            self.reservedRightsLabel.centerXAnchor.constraint(equalTo: self.versionBaseView.centerXAnchor),
            self.reservedRightsLabel.bottomAnchor.constraint(equalTo: self.versionBaseView.bottomAnchor, constant: -2),
        ])

    }

}

