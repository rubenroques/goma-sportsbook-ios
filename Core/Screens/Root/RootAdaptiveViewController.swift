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
import GomaUI

class RootAdaptiveScreenViewModel {

    @Published var currentScreen: ScreenType?

    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    var adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol

    init(multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol = MockMultiWidgetToolbarViewModel.defaultMock,
         adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol = MockAdaptiveTabBarViewModel.defaultMock)
    {
        self.multiWidgetToolbarViewModel = multiWidgetToolbarViewModel
        self.adaptiveTabBarViewModel = adaptiveTabBarViewModel
    }

    // MARK: - Screen Management
    func presentScreen(_ screenType: ScreenType) {
        currentScreen = screenType
    }

    func hideCurrentScreen() {
        currentScreen = nil
    }

}

enum ScreenType {
    case home
    case nextUpEvents
    case inPlayEvents
    // Add more screens here as needed
    // case preLive
    // case live
    // case tips
    // case casino
    // etc.
}

class RootAdaptiveViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var topBarContainerBaseView: UIView = Self.createTopBarContainerBaseView()
    private var widgetToolBarView: MultiWidgetToolbarView!

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainContainerView: UIView = Self.createMainContainerView()

    private lazy var tabBarView: UIView = Self.createTabBarView()
    private var adaptiveTabBarView: AdaptiveTabBarView!

    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    // Authentication Views
    private lazy var localAuthenticationBaseView: UIView = Self.createLocalAuthenticationBaseView()
    private lazy var unlockAppButton: UIButton = Self.createUnlockAppButton()
    private lazy var cancelUnlockAppButton: UIButton = Self.createCancelUnlockAppButton()
    private lazy var isLoadingUserSessionView: UIActivityIndicatorView = Self.createLoadingUserSessionView()

    private lazy var blockingWindow: BlockingWindow = Self.createBlockingWindow()

    //
    // Embeded View Controllers
    private lazy var homeBaseView: UIView = Self.createHomeBaseView()
    private lazy var homeViewController = HomeViewController()
    private var homeViewControllerLoaded: Bool = false

    private lazy var nextUpEventsBaseView: UIView = Self.createNextUpEventsBaseView()
    private lazy var nextUpEventsViewController: NextUpEventsViewController = {
        let viewModel = NextUpEventsViewModel()
        return NextUpEventsViewController(viewModel: viewModel)
    }()
    private var nextUpEventsViewControllerLoaded: Bool = false

    private lazy var inPlayEventsBaseView: UIView = Self.createInPlayEventsBaseView()
    private lazy var inPlayEventsViewController: InPlayEventsViewController = {
        let viewModel = InPlayEventsViewModel()
        return InPlayEventsViewController(viewModel: viewModel)
    }()
    private var inPlayEventsViewControllerLoaded: Bool = false

    // Constraints
    private var viewModel: RootAdaptiveScreenViewModel

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
    init(viewModel: RootAdaptiveScreenViewModel) {
        self.viewModel = viewModel

        self.adaptiveTabBarView = AdaptiveTabBarView(viewModel: viewModel.adaptiveTabBarViewModel)
        self.widgetToolBarView = MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)

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

        // MARK: - Reactive Bindings for Screen Management
        self.setupScreenBindings()

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

        // Set default screen on startup
        DispatchQueue.main.async {
            self.viewModel.presentScreen(.nextUpEvents)
        }
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

        #if DEBUG
        self.topSafeAreaView.backgroundColor = .purple
        self.bottomSafeAreaView.backgroundColor = .blue

        self.topBarContainerBaseView.backgroundColor = .orange
        self.containerView.backgroundColor = .green

        self.tabBarView.backgroundColor = .red
        #endif

        self.mainContainerView.backgroundColor = UIColor.App.backgroundPrimary

        //
        self.isLoadingUserSessionView.tintColor = UIColor.App.textSecondary
        self.isLoadingUserSessionView.color = UIColor.App.textSecondary

        self.unlockAppButton.backgroundColor = UIColor.App.highlightPrimary
        self.unlockAppButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.cancelUnlockAppButton.backgroundColor = .systemGray
        self.cancelUnlockAppButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
    }

    //

    // MARK: - Reactive Bindings for Screen Management
    private func setupScreenBindings() {
        // React to screen changes
        viewModel.$currentScreen
            .receive(on: DispatchQueue.main)
            .sink { [weak self] screenType in
                if let screenType = screenType {
                    self?.presentScreen(screenType)
                } else {
                    self?.hideAllScreens()
                }
            }
            .store(in: &cancellables)

        // Setup tab bar integration
        adaptiveTabBarView.onTabSelected = { [weak self] tabItem in
            self?.handleTabSelection(tabItem)
        }
    }

    // MARK: - Tab Bar Integration
    private func handleTabSelection(_ tabItem: TabItem) {
        switch tabItem.identifier {
        case .nextUpEvents:
            viewModel.presentScreen(.nextUpEvents)
        case .inPlayEvents:
            viewModel.presentScreen(.inPlayEvents)
        case .sportsHome:
            viewModel.presentScreen(.home)
        default:
            // Handle other tab selections or keep current screen
            break
        }
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

    // MARK: - Generic Screen Presentation
    private func presentChildViewController<T: UIViewController>(
        _ viewController: T,
        in baseView: UIView,
        loadedFlag: inout Bool
    )
    {
        guard !loadedFlag else {
            baseView.isHidden = false
            return
        }

        guard let subView = viewController.view  else {
            return
        }

        viewController.willMove(toParent: self)

        self.addChild(viewController)

        baseView.addSubview(subView)

        subView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: baseView.topAnchor),
            subView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            subView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
        loadedFlag = true

        baseView.isHidden = false
    }


    private func hideAllScreens() {
        nextUpEventsBaseView.isHidden = true
        inPlayEventsBaseView.isHidden = true
        // Add more base views here as you add more screens
        // homeBaseView.isHidden = true
        // preLiveBaseView.isHidden = true
        // etc.
    }

    private func presentScreen(_ screenType: ScreenType) {
        self.hideAllScreens()

        switch screenType {
        case .home:
            presentChildViewController(
                homeViewController,
                in: homeBaseView,
                loadedFlag: &homeViewControllerLoaded
            )
        case .nextUpEvents:
            presentChildViewController(
                nextUpEventsViewController,
                in: nextUpEventsBaseView,
                loadedFlag: &nextUpEventsViewControllerLoaded
            )
        case .inPlayEvents:
            presentChildViewController(
                inPlayEventsViewController,
                in: inPlayEventsBaseView,
                loadedFlag: &inPlayEventsViewControllerLoaded
            )
        // Add more cases here as you add more screens
        }
    }

    @objc private func didTapShowEventsButton() {
        viewModel.presentScreen(.nextUpEvents)
    }

    @objc private func didTapShowInPlayEventsButton() {
        viewModel.presentScreen(.inPlayEvents)
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

    private static func createNextUpEventsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createInPlayEventsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShowEventsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Next Up Events", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }

    private static func createShowInPlayEventsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show In-Play Events", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
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
    private static func createBlockingWindow() -> BlockingWindow {
        var blockingWindow: BlockingWindow = BlockingWindow(frame: UIScreen.main.bounds)
        blockingWindow.windowLevel = .statusBar
        return blockingWindow
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

        topBarContainerBaseView.addSubview(widgetToolBarView)

        view.addSubview(containerView)
        view.addSubview(bottomSafeAreaView)
        view.addSubview(localAuthenticationBaseView)

        tabBarView.addSubview(adaptiveTabBarView)

        // Setup container views
        containerView.addSubview(mainContainerView)

        // Add base views for child view controllers
        mainContainerView.addSubview(nextUpEventsBaseView)
        mainContainerView.addSubview(inPlayEventsBaseView)

        // Setup tab bar
        containerView.addSubview(tabBarView)

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
            // self.topBarContainerBaseView.heightAnchor.constraint(equalToConstant: 64),

            self.widgetToolBarView.leadingAnchor.constraint(equalTo: self.topBarContainerBaseView.leadingAnchor),
            self.widgetToolBarView.trailingAnchor.constraint(equalTo: self.topBarContainerBaseView.trailingAnchor),
            self.widgetToolBarView.bottomAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.widgetToolBarView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.topAnchor),

            // Container View
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            // Main Container View
            self.mainContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.mainContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.mainContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.mainContainerView.bottomAnchor.constraint(equalTo: self.tabBarView.topAnchor),

            // Next Up Events Base View
            self.nextUpEventsBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.nextUpEventsBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.nextUpEventsBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.nextUpEventsBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // In Play Events Base View
            self.inPlayEventsBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.inPlayEventsBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.inPlayEventsBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.inPlayEventsBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // Tab Bar
            self.tabBarView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.tabBarView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.tabBarView.bottomAnchor.constraint(equalTo: self.bottomSafeAreaView.topAnchor),
            self.tabBarView.heightAnchor.constraint(equalToConstant: 56),

            self.adaptiveTabBarView.leadingAnchor.constraint(equalTo: self.tabBarView.leadingAnchor),
            self.adaptiveTabBarView.trailingAnchor.constraint(equalTo: self.tabBarView.trailingAnchor),
            self.adaptiveTabBarView.bottomAnchor.constraint(equalTo: self.tabBarView.bottomAnchor),
            self.adaptiveTabBarView.topAnchor.constraint(equalTo: self.tabBarView.topAnchor),

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
            self.isLoadingUserSessionView.centerYAnchor.constraint(equalTo: self.localAuthenticationBaseView.centerYAnchor),

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
