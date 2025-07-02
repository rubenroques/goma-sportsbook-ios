//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine
import LocalAuthentication
import ServicesProvider
import GomaUI

class RootAdaptiveScreenViewModel {

    @Published var currentScreen: ScreenType?

    var multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol
    var adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol
    var floatingOverlayViewModel: FloatingOverlayViewModelProtocol

    private var cancellables = Set<AnyCancellable>()
    private var lastActiveTabBarID: TabBarIdentifier?

    init(multiWidgetToolbarViewModel: MultiWidgetToolbarViewModelProtocol = MockMultiWidgetToolbarViewModel.defaultMock,
         adaptiveTabBarViewModel: AdaptiveTabBarViewModelProtocol = MockAdaptiveTabBarViewModel.defaultMock,
         floatingOverlayViewModel: FloatingOverlayViewModelProtocol = MockFloatingOverlayViewModel())
    {
        self.multiWidgetToolbarViewModel = multiWidgetToolbarViewModel
        self.adaptiveTabBarViewModel = adaptiveTabBarViewModel
        self.floatingOverlayViewModel = floatingOverlayViewModel

        setupTabBarBinding()
    }

    // MARK: - Screen Management
    func presentScreen(_ screenType: ScreenType) {
        currentScreen = screenType
    }

    func hideCurrentScreen() {
        currentScreen = nil
    }

    // MARK: - Private Methods
    private func setupTabBarBinding() {
        // Listen to tab bar active bar id changes
        adaptiveTabBarViewModel.displayStatePublisher
            .sink { [weak self] displayState in
                self?.lastActiveTabBarID = displayState.activeTabBarID
            }
            .store(in: &cancellables)

        // Listen to tab bar state changes
        adaptiveTabBarViewModel.displayStatePublisher
            .dropFirst()
            .sink { [weak self] displayState in
                self?.handleTabBarChange(displayState)
            }
            .store(in: &cancellables)
    }

    private func handleTabBarChange(_ displayState: AdaptiveTabBarDisplayState) {

        if lastActiveTabBarID != displayState.activeTabBarID {
            switch displayState.activeTabBarID {
            case .home:
                // Switched to Sportsbook
                floatingOverlayViewModel.show(mode: .sportsbook, duration: 3.0)
            case .casino:
                // Switched to Casino
                floatingOverlayViewModel.show(mode: .casino, duration: 3.0)
            }
        }
    }

}

enum ScreenType {
    // Sportsbook tab items
    case home
    case nextUpEvents
    case inPlayEvents
    case myBets
    case search

    // Casino tab items
    case casinoHome
    case casinoVirtualSports
    case casinoAviatorGame
    case casinoSearch
}

class RootAdaptiveViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var topBarContainerBaseView: UIView = Self.createTopBarContainerBaseView()
    private var widgetToolBarView: MultiWidgetToolbarView!
    private lazy var orangePlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.App.topBarGradient1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainContainerView: UIView = Self.createMainContainerView()

    private lazy var tabBarView: UIView = Self.createTabBarView()
    private var adaptiveTabBarView: AdaptiveTabBarView!

    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private var combinedTabBarBlurView: UIVisualEffectView?

    // FloatingOverlay
    private var floatingOverlayView: FloatingOverlayView!

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

    // Dummy view controllers for unimplemented screens
    private lazy var inPlayDummyViewController = DummyViewController(displayText: "Live Events")
    private lazy var myBetsDummyViewController = DummyViewController(displayText: "My Bets")
    private lazy var searchDummyViewController = DummyViewController(displayText: "Search")
    private lazy var casinoHomeDummyViewController = DummyViewController(displayText: "Casino Home")
    private lazy var casinoTablesDummyViewController = DummyViewController(displayText: "Virtual Sports")
    private lazy var casinoJackpotsDummyViewController = DummyViewController(displayText: "Aviator")
    private lazy var casinoSearchDummyViewController = DummyViewController(displayText: "Casino Search")

    // Base views for dummy screens
    private lazy var myBetsBaseView: UIView = Self.createBaseView()
    private lazy var searchBaseView: UIView = Self.createBaseView()
    private lazy var casinoHomeBaseView: UIView = Self.createBaseView()
    private lazy var casinoTablesBaseView: UIView = Self.createBaseView()
    private lazy var casinoJackpotsBaseView: UIView = Self.createBaseView()
    private lazy var casinoSearchBaseView: UIView = Self.createBaseView()

    // Loaded flags
    private var myBetsViewControllerLoaded: Bool = false
    private var searchViewControllerLoaded: Bool = false
    private var casinoHomeViewControllerLoaded: Bool = false
    private var casinoTablesViewControllerLoaded: Bool = false
    private var casinoJackpotsViewControllerLoaded: Bool = false
    private var casinoSearchViewControllerLoaded: Bool = false

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
        self.adaptiveTabBarView.backgroundMode = .transparent // Use transparent mode with combined blur
        self.widgetToolBarView = MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)
        self.floatingOverlayView = FloatingOverlayView(viewModel: viewModel.floatingOverlayViewModel)
        self.floatingOverlayView.translatesAutoresizingMaskIntoConstraints = false

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

        self.topSafeAreaView.backgroundColor = UIColor.App.topBarGradient1
        self.setupCombinedTabBarBlur()

        self.topBarContainerBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        // Tab bar background is handled by setupCombinedTabBarBlur()

        self.mainContainerView.backgroundColor = UIColor.App.backgroundPrimary

        //
        self.isLoadingUserSessionView.tintColor = UIColor.App.textSecondary
        self.isLoadingUserSessionView.color = UIColor.App.textSecondary

        self.unlockAppButton.backgroundColor = UIColor.App.highlightPrimary
        self.unlockAppButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)

        self.cancelUnlockAppButton.backgroundColor = .systemGray
        self.cancelUnlockAppButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
    }

    private func setupCombinedTabBarBlur() {
        // Clear backgrounds for both tab bar and bottom safe area
        self.tabBarView.backgroundColor = .clear
        self.bottomSafeAreaView.backgroundColor = .clear
        
        // Remove existing blur if any
        combinedTabBarBlurView?.removeFromSuperview()
        
        // Create blur effect - using thin material for subtle effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        // Store reference and add to container view
        combinedTabBarBlurView = blurEffectView
        containerView.insertSubview(blurEffectView, belowSubview: tabBarView)
        
        // Constrain blur view to span from tab bar top to bottom safe area bottom
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomSafeAreaView.bottomAnchor)
        ])
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
        // Sportsbook tabs
        case .nextUpEvents:
            viewModel.presentScreen(.nextUpEvents)
        case .inPlayEvents:
            viewModel.presentScreen(.inPlayEvents)
        case .myBets:
            viewModel.presentScreen(.myBets)
        case .sportsSearch:
            viewModel.presentScreen(.search)

        // Casino tabs
        case .casinoHome:
            viewModel.presentScreen(.casinoHome)
        case .casinoVirtualSports:
            viewModel.presentScreen(.casinoVirtualSports)
        case .casinoAviatorGame:
            viewModel.presentScreen(.casinoAviatorGame)
        case .casinoSearch:
            viewModel.presentScreen(.casinoSearch)

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
        homeBaseView.isHidden = true
        myBetsBaseView.isHidden = true
        searchBaseView.isHidden = true
        casinoHomeBaseView.isHidden = true
        casinoTablesBaseView.isHidden = true
        casinoJackpotsBaseView.isHidden = true
        casinoSearchBaseView.isHidden = true
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
            // Use dummy instead of real controller
            presentChildViewController(
                inPlayDummyViewController,
                in: inPlayEventsBaseView,
                loadedFlag: &inPlayEventsViewControllerLoaded
            )
        case .myBets:
            presentChildViewController(
                myBetsDummyViewController,
                in: myBetsBaseView,
                loadedFlag: &myBetsViewControllerLoaded
            )
        case .search:
            presentChildViewController(
                searchDummyViewController,
                in: searchBaseView,
                loadedFlag: &searchViewControllerLoaded
            )
        case .casinoHome:
            presentChildViewController(
                casinoHomeDummyViewController,
                in: casinoHomeBaseView,
                loadedFlag: &casinoHomeViewControllerLoaded
            )
        case .casinoVirtualSports:
            presentChildViewController(
                casinoTablesDummyViewController,
                in: casinoTablesBaseView,
                loadedFlag: &casinoTablesViewControllerLoaded
            )
        case .casinoAviatorGame:
            presentChildViewController(
                casinoJackpotsDummyViewController,
                in: casinoJackpotsBaseView,
                loadedFlag: &casinoJackpotsViewControllerLoaded
            )
        case .casinoSearch:
            presentChildViewController(
                casinoSearchDummyViewController,
                in: casinoSearchBaseView,
                loadedFlag: &casinoSearchViewControllerLoaded
            )
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

    private static func createBaseView() -> UIView {
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
        topBarContainerBaseView.addSubview(orangePlaceholderView)

        view.addSubview(containerView)
        view.addSubview(bottomSafeAreaView)
        view.addSubview(localAuthenticationBaseView)

        tabBarView.addSubview(adaptiveTabBarView)

        // Setup container views
        containerView.addSubview(mainContainerView)

        // Add base views for child view controllers
        mainContainerView.addSubview(homeBaseView)
        mainContainerView.addSubview(nextUpEventsBaseView)
        mainContainerView.addSubview(inPlayEventsBaseView)
        mainContainerView.addSubview(myBetsBaseView)
        mainContainerView.addSubview(searchBaseView)
        mainContainerView.addSubview(casinoHomeBaseView)
        mainContainerView.addSubview(casinoTablesBaseView)
        mainContainerView.addSubview(casinoJackpotsBaseView)
        mainContainerView.addSubview(casinoSearchBaseView)

        // Setup tab bar
        containerView.addSubview(tabBarView)

        localAuthenticationBaseView.addSubview(unlockAppButton)
        localAuthenticationBaseView.addSubview(cancelUnlockAppButton)
        localAuthenticationBaseView.addSubview(isLoadingUserSessionView)

        view.bringSubviewToFront(topBarContainerBaseView)

        // Add floating overlay at the top of the view hierarchy
        view.addSubview(floatingOverlayView)
        
        // TEST REGISTER
        // Double-tap: open PhoneLoginViewController
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(openPhoneLogin))
        doubleTapGesture.numberOfTapsRequired = 2

        // Triple-tap: open PhoneRegistrationViewController (your current one)
        let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(openPhoneRegistration))
        tripleTapGesture.numberOfTapsRequired = 3
        
        let quadrupleTapGesture = UITapGestureRecognizer(target: self, action: #selector(openFirstDeposits))
        quadrupleTapGesture.numberOfTapsRequired = 4

        // Ensure double-tap waits for triple-tap to fail
        doubleTapGesture.require(toFail: tripleTapGesture)
        tripleTapGesture.require(toFail: quadrupleTapGesture)

        // Add both to your view
        orangePlaceholderView.addGestureRecognizer(doubleTapGesture)
        orangePlaceholderView.addGestureRecognizer(tripleTapGesture)
        orangePlaceholderView.addGestureRecognizer(quadrupleTapGesture)

        initConstraints()
    }
    
    @objc private func openPhoneLogin() {
        let loginVC = PhoneLoginViewController()
        let navController = Router.navigationController(with: loginVC)
        present(navController, animated: true)
    }
    
    @objc private func openPhoneRegistration() {
        let registrationVC = PhoneRegistrationViewController()
        present(registrationVC, animated: true)
        
    }
    
    @objc private func openFirstDeposits() {
        let firstDepositPromotionsVC = FirstDepositPromotionsViewController()
        present(firstDepositPromotionsVC, animated: true)
        
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
            
            // Orange placeholder view (same constraints as widget toolbar)
            self.orangePlaceholderView.leadingAnchor.constraint(equalTo: self.topBarContainerBaseView.leadingAnchor),
            self.orangePlaceholderView.trailingAnchor.constraint(equalTo: self.topBarContainerBaseView.trailingAnchor),
            self.orangePlaceholderView.bottomAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.orangePlaceholderView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.topAnchor),

            // Container View
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            // Main Container View - extend behind tab bar for blur effect
            self.mainContainerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.mainContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.mainContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.mainContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

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

            // Home Base View
            self.homeBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.homeBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.homeBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.homeBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // My Bets Base View
            self.myBetsBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.myBetsBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.myBetsBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.myBetsBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // Search Base View
            self.searchBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.searchBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.searchBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.searchBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // Casino Home Base View
            self.casinoHomeBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.casinoHomeBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.casinoHomeBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.casinoHomeBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // Casino Tables Base View
            self.casinoTablesBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.casinoTablesBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.casinoTablesBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.casinoTablesBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // Casino Jackpots Base View
            self.casinoJackpotsBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.casinoJackpotsBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.casinoJackpotsBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.casinoJackpotsBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

            // Casino Search Base View
            self.casinoSearchBaseView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor),
            self.casinoSearchBaseView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor),
            self.casinoSearchBaseView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor),
            self.casinoSearchBaseView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor),

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

            // Floating Overlay View
            self.floatingOverlayView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.floatingOverlayView.bottomAnchor.constraint(equalTo: self.adaptiveTabBarView.topAnchor, constant: -32),
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
