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

    var requestBetSwipeAction: () -> Void = { }
    var requestHomeAction: () -> Void = { }
    var requestLiveAction: () -> Void = { }
    var requestContactSettingsAction: () -> Void = { }

    var requestRegisterAction: () -> Void = { }
    var requestLoginAction: () -> Void = { }

    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var contentScrollView: UIScrollView = Self.createScrollBaseView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()

    private lazy var contentStackView: UIStackView = Self.createContentStackView()

    private lazy var signUpButtonsBaseView: UIView = Self.createView()
    private lazy var signUpButtonsStackView: UIStackView = Self.createButtonsStackView()

    private lazy var registerButton: UIButton = Self.createButton()
    private lazy var loginButton: UIButton = Self.createButton()

    private lazy var menuContainerView: UIView = Self.createView()
    private lazy var menusStackView: UIStackView = Self.createMenusStackView()

    private lazy var versionBaseView: UIView = Self.createView()
    private lazy var versionLabel: UILabel = Self.createVersionLabel()
    private lazy var reservedRightsLabel: UILabel = Self.createReservedRightsLabel()

    private lazy var footerResponsibleGamingView: FooterResponsibleGamingView = Self.createFooterResponsibleGamingView()

    private var viewModel: AnonymousSideMenuViewModel
    private var cancellables = Set<AnyCancellable>()

    // Debug screen tap
    private var tapCounter = 0
    private var lastTapTime: Date?
    
    var didTapBetslipButtonAction: (() -> Void)?
    var addBetToBetslipAction: ((BetSwipeData) -> Void)?

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

        self.registerButton.setTitle(localized("register"), for: .normal)
        self.loginButton.setTitle(localized("login"), for: .normal)

        self.registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .primaryActionTriggered)
        self.loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .primaryActionTriggered)

        let versionBaseViewTap = UITapGestureRecognizer(target: self, action: #selector(handleDebugTap))
        self.versionBaseView.addGestureRecognizer(versionBaseViewTap)
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

        self.signUpButtonsBaseView.backgroundColor = .clear

        StyleHelper.styleButton(button: self.registerButton)
        StyleHelper.styleButton(button: self.loginButton)
    }

    private func addMenus() {

        let replayView = NavigationCardView()
        replayView.hasNotifications = true
        replayView.setupView(title: localized("cashback"), iconTitle: "cashback_icon")
        let replayTap = UITapGestureRecognizer(target: self, action: #selector(replayViewTapped))
        replayView.addGestureRecognizer(replayTap)

        let betSwipeView = NavigationCardView()
        betSwipeView.hasNotifications = true
        betSwipeView.setupView(title: localized("bet_swipe"), iconTitle: "betswipe_profile_icon")
        let betSwipeTap = UITapGestureRecognizer(target: self, action: #selector(betSwipeViewTapped))
        betSwipeView.addGestureRecognizer(betSwipeTap)

        let promotionsView = NavigationCardView()
        promotionsView.hasNotifications = true
        promotionsView.setupView(title: localized("promotions"), iconTitle: "promotion_icon")
        let messagesTap = UITapGestureRecognizer(target: self, action: #selector(promotionsViewTapped))
        promotionsView.addGestureRecognizer(messagesTap)

        let recruitFriendView = NavigationCardView()
        recruitFriendView.setupView(title: localized("referal_friend"), iconTitle: "recruit_icon")
        let recruitFriendTap = UITapGestureRecognizer(target: self, action: #selector(recruitFriendViewTapped))
        recruitFriendView.addGestureRecognizer(recruitFriendTap)

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

        self.menusStackView.addArrangedSubview(responsibleGamingView)
        self.menusStackView.addArrangedSubview(replayView)
        self.menusStackView.addArrangedSubview(betSwipeView)
        self.menusStackView.addArrangedSubview(promotionsView)
        self.menusStackView.addArrangedSubview(recruitFriendView)
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

    @objc func handleDebugTap() {
        if let lastTapTime = lastTapTime, Date().timeIntervalSince(lastTapTime) > 2 {
            // Reset the counter if more than a second has passed since the last tap
            tapCounter = 0
        }

        self.tapCounter += 1
        self.lastTapTime = Date()

        if tapCounter >= 7 {
            // If 10 taps have been detected in less than a second, show the developer screen
            self.showDeveloperScreen()
            self.tapCounter = 0
        }
    }

    private func showDeveloperScreen() {
        let debugViewController = DebugViewController()

        let navigationController = UINavigationController(rootViewController: debugViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private func openRecruitScreen() {
        let recruitAFriendViewModel = RecruitAFriendViewModel()
        
        let recruitAFriendViewController = RecruitAFriendViewController(viewModel: recruitAFriendViewModel)

        recruitAFriendViewController.fromAnonymousMenu = true

        self.navigationController?.pushViewController(recruitAFriendViewController, animated: true)
    }

}

extension AnonymousSideMenuViewController {

    @objc func didTapRegisterButton() {
        self.requestRegisterAction()
    }

    @objc func didTapLoginButton() {
        self.requestLoginAction()
    }

    @objc func promotionsViewTapped() {
        let promotionsWebViewModel = PromotionsWebViewModel()
        let appLanguage = "fr"
        let isDarkTheme = self.traitCollection.userInterfaceStyle == .dark ? true : false
        let urlString = TargetVariables.generatePromotionsPageUrlString(forAppLanguage: appLanguage, isDarkTheme: isDarkTheme)

        if let url = URL(string: urlString) {
            let promotionsWebViewController = PromotionsWebViewController(url: url, viewModel: promotionsWebViewModel)
            promotionsWebViewController.openBetSwipeAction = { [weak self] in
                self?.requestBetSwipeAction()
            }
            promotionsWebViewController.openRegisterAction = { [weak self] in
                self?.requestRegisterAction()
            }
            promotionsWebViewController.openHomeAction = { [weak self] in
                self?.requestHomeAction()
            }
            promotionsWebViewController.openRecruitAction = { [weak self] in
                self?.openRecruitScreen()
            }
            promotionsWebViewController.openLiveAction = { [weak self] in
                self?.requestLiveAction()
            }
            promotionsWebViewController.openContactSettingsAction = { [weak self] in
                self?.requestContactSettingsAction()
            }
            self.navigationController?.pushViewController(promotionsWebViewController, animated: true)
        }
    }

    @objc private func responsibleGamingViewTapped() {
        let responsibleGamingViewController = ResponsibleGamingViewController()
        self.navigationController?.pushViewController(responsibleGamingViewController, animated: true)
    }

    @objc private func appSettingsViewTapped() {
        let appSettingsViewController = AppSettingsViewController()
        self.navigationController?.pushViewController(appSettingsViewController, animated: true)
    }

    @objc private func supportViewTapped() {
//        let supportViewController = SupportPageViewController(viewModel: SupportPageViewModel())
//        self.navigationController?.pushViewController(supportViewController, animated: true)
        
        if let url = URL(string: TargetVariables.links.support.helpCenter) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func replayViewTapped() {
        let cashbackInfoViewController = CashbackInfoViewController()
        self.navigationController?.pushViewController(cashbackInfoViewController, animated: true)
    }

    @objc private func recruitFriendViewTapped() {
        let recruitAFriendViewModel = RecruitAFriendViewModel()

        let recruitAFriendViewController = RecruitAFriendViewController(viewModel: recruitAFriendViewModel)
        
        recruitAFriendViewController.fromAnonymousMenu = true
        
        self.navigationController?.pushViewController(recruitAFriendViewController, animated: true)
    }

    @objc private func betSwipeViewTapped() {
        
//        let betSelectorViewConroller = InternalBrowserViewController(fileName: "TinderStyleBetBuilder", fileType: "html", fullscreen: true)
//        self.navigationController?.pushViewController(betSelectorViewConroller, animated: true)
        
        let userId = Env.userSessionStore.loggedUserProfile?.userIdentifier ?? "0"
        let iframeURL = URL(string: "\(TargetVariables.clientBaseUrl)/betswipe.html?user=\(userId)&mobile=true&language=fr")!
        
        let betSelectorViewConroller = BetslipProxyWebViewController(url: iframeURL)
        let navigationViewController = Router.navigationController(with: betSelectorViewConroller)
        navigationViewController.modalPresentationStyle = .fullScreen
        
        betSelectorViewConroller.showsBetslip = { [weak self] in
            navigationViewController.dismiss(animated: true) {
                self?.didTapBetslipButtonAction?()
            }
        }
        
        betSelectorViewConroller.closeBetSwipe = {
            navigationViewController.dismiss(animated: true)
        }
        
        betSelectorViewConroller.addToBetslip = { [weak self] betSwipeData in
            //self?.addBetToBetslip(withBetSwipeData: betSwipeData)
            self?.addBetToBetslipAction?(betSwipeData)
        }
        
        self.present(navigationViewController, animated: true, completion: nil)
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

    private static func createButtonsStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillEqually
        view.axis = .horizontal
        view.spacing = 8
        return view
    }

    private static func createButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
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
        view.showLinksView()
        view.showSocialView()
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

        self.signUpButtonsStackView.addArrangedSubview(self.loginButton)
        self.signUpButtonsStackView.addArrangedSubview(self.registerButton)

        self.signUpButtonsBaseView.addSubview(self.signUpButtonsStackView)

        self.contentStackView.addArrangedSubview(self.signUpButtonsBaseView)
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
            self.signUpButtonsStackView.heightAnchor.constraint(equalToConstant: 50),

            self.signUpButtonsStackView.leadingAnchor.constraint(equalTo: self.signUpButtonsBaseView.leadingAnchor, constant: 36),
            self.signUpButtonsStackView.centerXAnchor.constraint(equalTo: self.signUpButtonsBaseView.centerXAnchor),
            self.signUpButtonsStackView.topAnchor.constraint(equalTo: self.signUpButtonsBaseView.topAnchor, constant: 12),
            self.signUpButtonsStackView.bottomAnchor.constraint(equalTo: self.signUpButtonsBaseView.bottomAnchor, constant: -12),
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

