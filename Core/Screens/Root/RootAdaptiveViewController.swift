//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine
import WebKit
import LocalAuthentication
import RegisterFlow
import Adyen
import AdyenDropIn
import AdyenComponents
import OptimoveSDK
import ServicesProvider

protocol RootAdaptiveScreenViewModelProtocol {
    
}

class RootAdaptiveScreenViewModel: RootAdaptiveScreenViewModelProtocol {
    
}

class RootAdaptiveViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var topBarContainerBaseView: UIView = Self.createTopBarContainerBaseView()
    private lazy var topBarView: UIView = Self.createTopBarView()

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainContainerView: UIView = Self.createMainContainerView()

    private lazy var tabBarView: UIView = Self.createTabBarView()
 
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    
    // Authentication Views
    private lazy var localAuthenticationBaseView: UIView = Self.createLocalAuthenticationBaseView()
    private lazy var unlockAppButton: UIButton = Self.createUnlockAppButton()
    private lazy var cancelUnlockAppButton: UIButton = Self.createCancelUnlockAppButton()
    private lazy var isLoadingUserSessionView: UIActivityIndicatorView = Self.createLoadingUserSessionView()

    private lazy var blockingWindow: BlockingWindow = Self.createBlockingWindow()

    // Constraints
    private var viewModel: RootAdaptiveScreenViewModelProtocol


    // General properties
    var isLocalAuthenticationCoveringView: Bool = true {
        didSet {
            if isLocalAuthenticationCoveringView {
                self.localAuthenticationBaseView.isHidden = false
                self.blockingWindow.isHidden = false
            }
            else {
                self.localAuthenticationBaseView.isHidden = true
                self.blockingWindow.isHidden = true

            }
        }
    }

    var screenState: ScreenState = .anonymous {
        didSet {
            self.setupWithState(self.screenState)
        }
    }

    static let casinoButtonWidth: CGFloat = 66

    var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and cycle
    init(viewModel: RootAdaptiveScreenViewModelProtocol ) {
        
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

        self.blockingWindow.addSubview(self.localAuthenticationBaseView, anchors: [.leading(0), .trailing(0), .top(0), .bottom(0)])
        self.blockingWindow.isHidden = false

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.windowDidResignKeyNotification(_:)),
                                               name: UIWindow.didResignKeyNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.windowDidBecomeKeyNotification(_:)),
                                               name: UIWindow.didBecomeKeyNotification,
                                               object: nil)

        //
        // UIApplication States
        //
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        //
        self.setupWithTheme()

        // Detects a new login
        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { userProfile in
                if let userProfile = userProfile {
                    // self.screenState = .logged(user: userProfile)

                }
                else {
                    self.screenState = .anonymous

                }
            }
            .store(in: &cancellables)

        Env.userSessionStore
            .isLoadingUserSessionPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingUserSession in

                if !isLoadingUserSession {
                    self?.isLocalAuthenticationCoveringView = false
                }

                self?.isLoadingUserSessionView.isHidden = !isLoadingUserSession
                self?.unlockAppButton.isHidden = isLoadingUserSession
                self?.cancelUnlockAppButton.isHidden = isLoadingUserSession
            }
            .store(in: &self.cancellables)

        self.isLoadingUserSessionView.isHidden = true

        // Add blur effect
        self.localAuthenticationBaseView.backgroundColor = .clear

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false

        self.localAuthenticationBaseView.insertSubview(blurEffectView, at: 0)

        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: self.localAuthenticationBaseView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.localAuthenticationBaseView.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: self.localAuthenticationBaseView.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.localAuthenticationBaseView.bottomAnchor),
        ])

        self.localAuthenticationBaseView.alpha = 1.0
        self.showLocalAuthenticationCoveringViewIfNeeded()

        self.authenticateUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setNeedsStatusBarAppearanceUpdate()

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                    //
                }
                else {
                    
                }
            }
            .store(in: &cancellables)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    // MARK: Layout and theme
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let barStyle: UIStatusBarStyle = traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
        return barStyle
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setNeedsStatusBarAppearanceUpdate()
        self.setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        if TargetVariables.shouldUseGradientBackgrounds {
            self.topSafeAreaView.backgroundColor = .clear
            self.topBarView.backgroundColor = .clear

            self.containerView.backgroundColor = .clear
            self.mainContainerView.backgroundColor = .clear
        }
        else {
            self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
            self.topBarView.backgroundColor = UIColor.App.backgroundPrimary

            self.containerView.backgroundColor = .clear
            self.mainContainerView.backgroundColor = UIColor.App.backgroundPrimary
        }

        if TargetVariables.shouldUseBlurEffectTabBar {
            self.tabBarView.backgroundColor = .clear
            self.bottomSafeAreaView.backgroundColor = .clear
        }
        else {
            self.tabBarView.backgroundColor = UIColor.App.backgroundSecondary
            self.bottomSafeAreaView.backgroundColor = UIColor.App.backgroundSecondary
        }

        self.isLoadingUserSessionView.tintColor = UIColor.App.textSecondary
        self.isLoadingUserSessionView.color = UIColor.App.textSecondary

        self.unlockAppButton.backgroundColor = UIColor.App.highlightPrimary
        self.unlockAppButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.cancelUnlockAppButton.backgroundColor = .systemGray
        self.cancelUnlockAppButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
    }

    // MARK: Functions
    func setupWithState(_ screenState: ScreenState) {
        switch screenState {
        case .logged:
            ()
        case .anonymous:
           ()
        }
    }

    // Open screens functions
    func openBetslipModal() {
        let betslipViewModel = BetslipViewModel()
        let betslipViewController = BetslipViewController(viewModel: betslipViewModel)

        betslipViewController.willDismissAction = { [weak self] in
            self?.reloadChildViewControllersData()
        }
        self.present(Router.navigationController(with: betslipViewController), animated: true, completion: nil)
    }

    func openChatModal() {
        if Env.userSessionStore.isUserLogged() {
            let socialViewController = SocialViewController()
            self.present(Router.navigationController(with: socialViewController), animated: true, completion: nil)
        }
        else {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
    }

    func openInternalWebview(onURL url: URL) {
        let internalBrowserViewController = InternalBrowserViewController(url: url, fullscreen: true)
        let navigationViewController = Router.navigationController(with: internalBrowserViewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }

    func openExternalBrowser(onURL url: URL) {
        UIApplication.shared.open(url)
    }


    // Login and register
    private func presentLoginScreen() {
        let loginViewController = Router.navigationController(with: LoginViewController())
        self.present(loginViewController, animated: true, completion: nil)
    }

    private func presentRegisterScreen(withReferralCode: String? = nil) {
        let loginViewController = Router.navigationController(with: LoginViewController(shouldPresentRegisterFlow: true, referralCode: withReferralCode))
        self.present(loginViewController, animated: true, completion: nil)
    }

    // Reload data
    func reloadChildViewControllersData() {
//        if preLiveViewControllerLoaded {
//            self.preLiveViewController.reloadData()
//        }
//        if liveEventsViewControllerLoaded {
//            self.liveEventsViewController.reloadData()
//        }
//        if homeViewControllerLoaded {
//            self.homeViewController.reloadData()
//        }
    }


    // Load data
    func loadChildViewControllerIfNeeded(tab: RootViewModel.TabItem) {
//        if case .preLive = tab, !preLiveViewControllerLoaded {
//            // Iniciar prelive vc
//            self.addChildViewController(self.preLiveViewController, toView: self.preLiveBaseView)
//
//            self.preLiveViewController.didChangeSport = { [weak self] newSport in
//                self?.didChangedPreLiveSport(newSport)
//            }
//            self.preLiveViewController.didTapChatButtonAction = { [weak self] in
//                self?.openChatModal()
//            }
//            self.preLiveViewController.didTapBetslipButtonAction = { [weak self] in
//                self?.openBetslipModal()
//            }
//            preLiveViewControllerLoaded = true
//        }
    }

    // User functions
    func authenticateUser() {

        if Env.userSessionStore.shouldAuthenticateUser {
            print("LocalAuth shouldAuthenticateUser yes")
        }
        else {
            print("LocalAuth shouldAuthenticateUser no")
            self.unlockAppWithUser()
            return
        }

        if !Env.userSessionStore.shouldRequestBiometrics() {
            self.unlockAppAnonymous()
            return
        }

        let context = LAContext()

        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error) {

            // Device can use biometric authentication
            context.evaluatePolicy(
                LAPolicy.deviceOwnerAuthentication,
                localizedReason: localized("access_requires_authentication"),
                reply: { success, error in
                    DispatchQueue.main.async {
                        if let err = error {
                            switch err._code {
                            case LAError.Code.systemCancel.rawValue:
                                self.notifyUser(localized("session_cancelled"), errorMessage: err.localizedDescription)
                            case LAError.Code.userCancel.rawValue:
                                self.notifyUser(localized("please_try_again"), errorMessage: err.localizedDescription)
                            case LAError.Code.userFallback.rawValue:
                                self.notifyUser(localized("authentication"), errorMessage: localized("password_option_selected"))
                            default:
                                self.notifyUser(localized("authentication_failed"), errorMessage: err.localizedDescription)
                            }
                        }
                        else {
                            self.unlockAppWithUser()
                        }
                    }
            })
        }
        else {
            // Device cannot use biometric authentication
            if let err = error {
                switch err.code {
                case LAError.Code.biometryNotEnrolled.rawValue:
                    notifyUser(localized("user_not_enrolled"), errorMessage: err.localizedDescription)
                case LAError.Code.passcodeNotSet.rawValue:
                    notifyUser(localized("passcode_not_set"), errorMessage: err.localizedDescription)
                case LAError.Code.biometryNotAvailable.rawValue:
                    notifyUser(localized("biometric_auth_not_available"), errorMessage: err.localizedDescription)
                default:
                    notifyUser(localized("unknown_error"), errorMessage: err.localizedDescription)
                }
            }

        }

    }

    func notifyUser(_ title: String, errorMessage: String?) {
        let alert = UIAlertController(title: title,
                                      message: errorMessage,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localized("ok"),
                                         style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func didTapSearchButton() {
        let searchViewModel = SearchViewModel()

        let searchViewController = SearchViewController(viewModel: searchViewModel)

        let navigationViewController = Router.navigationController(with: searchViewController)
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc func didTapLogoImageView() {

    }

    @objc private func didTapLoginButton() {
        self.presentLoginScreen()
    }

    @objc private func didTapLoginAlternateButton() {
        self.presentLoginScreen()
    }

    @objc private func didTapProfileButton() {
        
    }

    @objc private func didTapAccountValue() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)
        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc private func didTapAnonymousButton() {
        
    }

}

// MARK: App States
extension RootAdaptiveViewController {

    // App States
    func unlockAppWithUser() {
        // Unlock the app

        Env.userSessionStore.startUserSession()
    }

    func unlockAppAnonymous() {
        Env.userSessionStore.logout()
        self.isLocalAuthenticationCoveringView = false
    }

    func showLocalAuthenticationCoveringViewIfNeeded() {
        if Env.userSessionStore.shouldRequestBiometrics() {
            self.isLocalAuthenticationCoveringView = true
        }
    }

    // App states actions
    @objc private func didTapUnlockButton() {
        self.authenticateUser()
    }

    @objc private func didTapCancelUnlockButton() {
        self.unlockAppAnonymous()
    }

    @objc func appWillEnterForeground() {
        if Env.userSessionStore.shouldRequestBiometrics() {
            self.authenticateUser()
        }
        else if Env.userSessionStore.isUserLogged() {

        }
        print("LocalAuth Foreground")
    }

    @objc func appDidEnterBackground() {
//        Env.userSessionStore.shouldAuthenticateUser = true
//
//        self.showLocalAuthenticationCoveringViewIfNeeded()
//        print("LocalAuth Background")
    }

    @objc func appDidBecomeActive() {
        // self.authenticateUser()
        print("LocalAuth Active")

        self.reloadChildViewControllersData()
    }

    @objc func appWillResignActive() {
        // self.showLocalAuthenticationCoveringViewIfNeeded()
        print("LocalAuth Inactive")
    }
    
    //
    //
    
    // MARK: Actions
    @objc private func windowDidResignKeyNotification(_ notification: NSNotification) {
        if let actorWindow = notification.object as? UIWindow {
            //
        }
    }

    @objc private func windowDidBecomeKeyNotification(_ notification: NSNotification) {
        if let actorWindow = notification.object as? UIWindow {
           //
        }
    }
    
}


// MARK: - Shake Gesture Handling
extension RootAdaptiveViewController {

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.presentColorDebugPanel()
        }
    }

    private func presentColorDebugPanel() {
//        let colorDebugVC = ColorDebugViewController()
//        let navController = UINavigationController(rootViewController: colorDebugVC)
//        navController.modalPresentationStyle = .formSheet
//        present(navController, animated: true)
    }
}

extension RootAdaptiveViewController {
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopBarContainerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopBarView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfileStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private static func createAccountStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        return stackView
    }

    private static func createTopGradientBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMainContainerView() -> UIView {
        let view = UIView()
        
        #if DEBUG
        view.backgroundColor = .systemBlue
        #endif
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMainContainerGradientView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsBookContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHomeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPreLiveBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLiveBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTicketsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeaturedCompetitionBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTabBarView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTabBarStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoBottomView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_sports_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSportsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("sports")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createHomeButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHomeIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_home_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createHomeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("home")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createLiveButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLiveIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_live_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createLiveTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("live")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createTipsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTipsIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_tips_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTipsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("tips")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createCashbackButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "cashback_bar_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCashbackTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("cashback")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createMyTicketsButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMyTicketsIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "tabbar_my_tickets"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createMyTicketsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("my_tickets")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createFeaturedCompetitionButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeaturedCompetitionIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createFeaturedCompetitionTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("featured_competition")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createCasinoButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCasinoIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "casino_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCasinoTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("casino")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createSportsbookButtonBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSportsbookIconImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "sportsbook_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSportsbookTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized("sportsbook")
        label.font = AppFont.with(type: .bold, size: 10)
        return label
    }

    private static func createProfileBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }

    private static func createProfilePictureBaseInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "empty_user_image"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private static func createAnonymousUserMenuBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAnonymousUserMenuImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "side_menu_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createSearchButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "search_bar_icon"), for: .normal)
        return button
    }

    private static func createLogoImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "logo_horizontal_left"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createLoginBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoginButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("login"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 13)
        button.setTitleColor(UIColor.App.bubblesPrimary, for: .normal)
        return button
    }

    private static func createAccountValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    private static func createAccountValueView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.layer.cornerRadius = 13.5
        view.clipsToBounds = true
        return view
    }

    private static func createAccountPlusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.highlightSecondary
        view.layer.cornerRadius = 9.5
        view.clipsToBounds = true
        return view
    }

    private static func createAccountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("loading")
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }

    private static func createAccountPlusImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "plus_small_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createNotificationCounterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNotificationCounterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .center
        return label
    }

    private static func createLocalAuthenticationBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createUnlockAppButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("unlock_app"), for: .normal)
        button.layer.cornerRadius = CornerRadius.button
        return button
    }

    private static func createCancelUnlockAppButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel_unlock_app"), for: .normal)
        button.layer.cornerRadius = CornerRadius.button
        return button
    }

    private static func createLoadingUserSessionView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }

    //
    private static func createOverlayWindow() -> PassthroughWindow {
        var overlayWindow: PassthroughWindow = PassthroughWindow(frame: UIScreen.main.bounds)
        overlayWindow.windowLevel = .alert
        return overlayWindow
    }

    private static func createBlockingWindow() -> BlockingWindow {
        var blockingWindow: BlockingWindow = BlockingWindow(frame: UIScreen.main.bounds)
        blockingWindow.windowLevel = .statusBar
        return blockingWindow
    }

    private static func createTopBarAlternateView() -> TopBarView {
        let topBar = TopBarView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        return topBar
    }

    // Constraints
    private static func createLeadingSportsBookContentConstriant() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createLogoImageWidthConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createLogoImageHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        // Add main container views
        view.addSubview(topSafeAreaView)
        view.addSubview(topBarContainerBaseView)
        view.addSubview(containerView)
        view.addSubview(bottomSafeAreaView)
        view.addSubview(localAuthenticationBaseView)

        // Add top bar elements
        topBarContainerBaseView.addSubview(topBarView)

        // Setup container views
        containerView.addSubview(mainContainerView)

        // Setup tab bar
        mainContainerView.addSubview(tabBarView)

        localAuthenticationBaseView.addSubview(unlockAppButton)
        localAuthenticationBaseView.addSubview(cancelUnlockAppButton)
        localAuthenticationBaseView.addSubview(isLoadingUserSessionView)

        view.bringSubviewToFront(topBarContainerBaseView)

        initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            // Top Safe Area
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            // Top Bar Container
            self.topBarContainerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBarContainerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBarContainerBaseView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),

            self.topBarView.leadingAnchor.constraint(equalTo: self.topBarContainerBaseView.leadingAnchor),
            self.topBarView.trailingAnchor.constraint(equalTo: self.topBarContainerBaseView.trailingAnchor),
            self.topBarView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.topAnchor),
            self.topBarView.bottomAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.topBarView.heightAnchor.constraint(equalToConstant: 64),

            // Container View
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),

            // Main Container View
            self.mainContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
//            self.mainContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
//            self.mainContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.mainContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.mainContainerView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor),

            // Tab Bar
            self.tabBarView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.tabBarView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),

            self.tabBarView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),
            self.tabBarView.heightAnchor.constraint(equalToConstant: 52),

            // Bottom Safe Area
            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            // Local Authentication Base View
            self.localAuthenticationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.localAuthenticationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.localAuthenticationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.localAuthenticationBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            // Unlock App Button
            self.unlockAppButton.centerXAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerXAnchor),
            self.unlockAppButton.centerYAnchor.constraint(equalTo: localAuthenticationBaseView.centerYAnchor, constant: -20),
            self.unlockAppButton.heightAnchor.constraint(equalToConstant: 35),

            // Cancel Unlock App Button
            self.cancelUnlockAppButton.centerXAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerXAnchor),
            self.cancelUnlockAppButton.topAnchor.constraint(equalTo: self.unlockAppButton.bottomAnchor, constant: 30),
            self.cancelUnlockAppButton.heightAnchor.constraint(equalToConstant: 35),

            // Loading User Session View
            self.isLoadingUserSessionView.centerXAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerXAnchor),
            self.isLoadingUserSessionView.centerYAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerYAnchor)
        ])

    }

}

extension RootAdaptiveViewController: RootActionable {
    func openMatchDetail(matchId: String) {
        
    }
    
    func openBetslipModalWithShareData(ticketToken: String) {
        
    }
    
    func openCompetitionDetail(competitionId: String) {
        
    }
    
    func openContactSettings() {
        
    }
    
    func openBetswipe() {
        
    }
    
    func openDeposit() {
        
    }
    
    func openBonus() {
        
    }
    
    func openDocuments() {
        
    }
    
    func openCustomerSupport() {
        
    }
    
    func openFavorites() {
        
    }
    
    func openPromotions() {
        
    }
    
    func openRegisterWithCode(code: String) {
        
    }
    
    func openResponsibleForm() {
        
    }
    
}
