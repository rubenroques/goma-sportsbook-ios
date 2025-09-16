//
//  RootTabBarViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine
import LocalAuthentication
import ServicesProvider
import GomaUI

class RootTabBarViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var topBarContainerBaseView: UIView = Self.createTopBarContainerBaseView()
    private var widgetToolBarView: MultiWidgetToolbarView!
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainContainerView: UIView = Self.createMainContainerView()

    private lazy var tabBarView: UIView = Self.createTabBarView()
    private var adaptiveTabBarView: AdaptiveTabBarView!

    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private var combinedTabBarBlurView: UIVisualEffectView?

    // FloatingOverlay
    private var floatingOverlayView: FloatingOverlayView!
    
    // BetslipFloatingView
    private var betslipFloatingView: BetslipFloatingView!

    // WalletStatus Overlay
    private lazy var walletStatusOverlayView: UIView = Self.createWalletStatusOverlayView()
    private var walletStatusView: WalletStatusView!

    // Authentication Views
    private lazy var localAuthenticationBaseView: UIView = Self.createLocalAuthenticationBaseView()
    private lazy var unlockAppButton: UIButton = Self.createUnlockAppButton()
    private lazy var cancelUnlockAppButton: UIButton = Self.createCancelUnlockAppButton()
    private lazy var isLoadingUserSessionView: UIActivityIndicatorView = Self.createLoadingUserSessionView()

    private lazy var blockingWindow: BlockingWindow = Self.createBlockingWindow()

    // 
    //
    // Base views for coordinator-managed view controllers (some dummy ones yet)
    private lazy var nextUpEventsBaseView: UIView = Self.createBaseView()
    private lazy var inPlayEventsBaseView: UIView = Self.createBaseView()
    private lazy var myBetsBaseView: UIView = Self.createBaseView()
    private lazy var searchBaseView: UIView = Self.createBaseView()
    private lazy var casinoHomeBaseView: UIView = Self.createBaseView()
    private lazy var casinoTablesBaseView: UIView = Self.createBaseView()
    private lazy var casinoJackpotsBaseView: UIView = Self.createBaseView()
    private lazy var casinoSearchBaseView: UIView = Self.createBaseView()

    // Loaded flags
    private var nextUpEventsViewControllerLoaded: Bool = false
    private var inPlayEventsViewControllerLoaded: Bool = false
    private var myBetsViewControllerLoaded: Bool = false
    private var searchViewControllerLoaded: Bool = false
    private var casinoHomeViewControllerLoaded: Bool = false
    private var casinoTablesViewControllerLoaded: Bool = false
    private var casinoJackpotsViewControllerLoaded: Bool = false
    private var casinoSearchViewControllerLoaded: Bool = false
    //
    //

    // Constraints
    private var viewModel: RootTabBarViewModel
    
    // MARK: - Tab Switching Coordination
    // Closure called when tabs are selected to enable coordinator-based lazy loading
    var onTabSelected: ((TabItem) -> Void)?
    
    // MARK: - Authentication Navigation Closures
    // Closures called when authentication is requested - handled by coordinator
    var onLoginRequested: (() -> Void)?
    var onRegistrationRequested: (() -> Void)?
    
    // MARK: - Profile Navigation Closure
    // Closure called when profile is requested - handled by coordinator
    var onProfileRequested: (() -> Void)?
    
    // MARK: - Betslip Navigation Closure
    // Closure called when betslip is requested - handled by coordinator
    var onBetslipRequested: (() -> Void)?
    
    // MARK: - Wallet Navigation Closures
    // Closures called when wallet operations are requested - handled by coordinator
    var onDepositRequested: (() -> Void)?
    var onWithdrawRequested: (() -> Void)?

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

    var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and cycle
    init(viewModel: RootTabBarViewModel) {
        self.viewModel = viewModel

        self.adaptiveTabBarView = AdaptiveTabBarView(viewModel: viewModel.adaptiveTabBarViewModel)
        self.adaptiveTabBarView.backgroundMode = .transparent // Use transparent mode with combined blur
        
        self.widgetToolBarView = MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)
        
        self.floatingOverlayView = FloatingOverlayView(viewModel: viewModel.floatingOverlayViewModel)
        self.floatingOverlayView.translatesAutoresizingMaskIntoConstraints = false
        
        self.walletStatusView = WalletStatusView(viewModel: viewModel.walletStatusViewModel)
        self.walletStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        // Initialize betslipFloatingView with view model from RootTabBarViewModel
        self.betslipFloatingView = BetslipFloatingView(viewModel: viewModel.betslipFloatingViewModel)
        self.betslipFloatingView.translatesAutoresizingMaskIntoConstraints = false

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        
        // Setup betslip callback
        viewModel.onBetslipRequested = { [weak self] in
            self?.showBetslip()
        }

        self.blockingWindow.addSubview(self.localAuthenticationBaseView)
        
        NSLayoutConstraint.activate([
            self.localAuthenticationBaseView.leadingAnchor.constraint(equalTo: self.blockingWindow.leadingAnchor),
            self.localAuthenticationBaseView.trailingAnchor.constraint(equalTo: self.blockingWindow.trailingAnchor),
            self.localAuthenticationBaseView.bottomAnchor.constraint(equalTo: self.blockingWindow.bottomAnchor),
            self.localAuthenticationBaseView.topAnchor.constraint(equalTo: self.blockingWindow.topAnchor),
        ])
        self.blockingWindow.isHidden = false

        //
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
        viewModel.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { userProfile in
                if let userProfile = userProfile {
                    // self.screenState = .logged(user: userProfile)
                    self.widgetToolBarView.setLoggedInState(true)
                }
                else {
                    self.widgetToolBarView.setLoggedInState(false)
                }
            }
            .store(in: &cancellables)

        viewModel.isLoadingUserSessionPublisher
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

        // Default screen will be shown by MainCoordinator after startup
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setNeedsStatusBarAppearanceUpdate()
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
        self.combinedTabBarBlurView?.removeFromSuperview()
        
        // Create blur effect - using thin material for subtle effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        // Store reference and add to container view
        self.combinedTabBarBlurView = blurEffectView
        self.containerView.insertSubview(blurEffectView, belowSubview: tabBarView)
        
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
        // Setup tab bar integration - screen presentation now handled by coordinators
        adaptiveTabBarView.onTabSelected = { [weak self] tabItem in
            self?.handleTabSelection(tabItem)
        }
        
        widgetToolBarView.onWidgetSelected = { [weak self] widgetId in
            if widgetId == "loginButton" {
                self?.onLoginRequested?()
            }
            else if widgetId == "joinButton" {
                self?.onRegistrationRequested?()
            }
            else if widgetId == "avatar" {
                self?.onProfileRequested?()
            }
        }
        
        widgetToolBarView.onBalanceTapped = { [weak self] widgetId in
            if widgetId == "wallet" {
                // Add haptic feedback for better UX
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                self?.showWalletStatusOverlay()
            }
        }
        
        widgetToolBarView.onDepositTapped = { [weak self] widgetId in
            if widgetId == "wallet" {
                self?.onDepositRequested?()
            }
        }
        
        // Set up wallet navigation callbacks
        viewModel.walletStatusViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
        }
        
        viewModel.walletStatusViewModel.onWithdrawRequested = { [weak self] in
            self?.onWithdrawRequested?()
        }
        
        // Set up wallet widget deposit callback (from MultiWidgetToolbarView)
        viewModel.multiWidgetToolbarViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
        }
        
    }

    // MARK: - Tab Bar Integration
    private func handleTabSelection(_ tabItem: TabItem) {
        // Notify the coordinator for lazy loading and business logic
        // MainCoordinator will handle all screen presentation through Coordinator Integration API methods
        onTabSelected?(tabItem)
    }
    
    // MARK: - Coordinator Integration API
    // Methods for MainCoordinator to show specific screens
    func showNextUpEventsScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: nextUpEventsBaseView, loadedFlag: &nextUpEventsViewControllerLoaded)
        nextUpEventsBaseView.isHidden = false
        
        betslipFloatingView.isHidden = false

    }
    
    func showInPlayEventsScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: inPlayEventsBaseView, loadedFlag: &inPlayEventsViewControllerLoaded)
        inPlayEventsBaseView.isHidden = false
    }
    
    func showMyBetsScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: myBetsBaseView, loadedFlag: &myBetsViewControllerLoaded)
        myBetsBaseView.isHidden = false
    }
    
    func showSearchScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: searchBaseView, loadedFlag: &searchViewControllerLoaded)
        searchBaseView.isHidden = false
    }
    
    func showCasinoHomeScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: casinoHomeBaseView, loadedFlag: &casinoHomeViewControllerLoaded)
        casinoHomeBaseView.isHidden = false
        
        betslipFloatingView.isHidden = true

    }
    
    func showCasinoVirtualSportsScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: casinoTablesBaseView, loadedFlag: &casinoTablesViewControllerLoaded)
        casinoTablesBaseView.isHidden = false
    }
    
    func showCasinoAviatorGameScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: casinoJackpotsBaseView, loadedFlag: &casinoJackpotsViewControllerLoaded)
        casinoJackpotsBaseView.isHidden = false
    }
    
    func showCasinoSearchScreen(with viewController: UIViewController) {
        hideAllScreens()
        embedViewControllerIfNeeded(viewController, in: casinoSearchBaseView, loadedFlag: &casinoSearchViewControllerLoaded)
        casinoSearchBaseView.isHidden = false
    }
    
    private func embedViewControllerIfNeeded(_ viewController: UIViewController, in containerView: UIView, loadedFlag: inout Bool) {
        guard !loadedFlag else { return } // Already embedded
        
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        viewController.didMove(toParent: self)
        loadedFlag = true
    }

    func openExternalBrowser(onURL url: URL) {
        UIApplication.shared.open(url)
    }
    
    // MARK: - Wallet Status Overlay
    private func showWalletStatusOverlay() {
        walletStatusOverlayView.alpha = 0
        walletStatusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        walletStatusOverlayView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.walletStatusOverlayView.alpha = 1.0
            self.walletStatusView.transform = CGAffineTransform.identity
        }
    }
    
    private func hideWalletStatusOverlay() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.walletStatusOverlayView.alpha = 0
            self.walletStatusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            self.walletStatusOverlayView.isHidden = true
        }
    }
    
    @objc private func overlayTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: walletStatusOverlayView)
        let walletViewFrame = walletStatusView.frame
        
        // Only dismiss if tap is outside the wallet status view
        if !walletViewFrame.contains(location) {
            hideWalletStatusOverlay()
        }
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

    // User functions
    func authenticateUser() {

        if viewModel.shouldAuthenticateUser() {
            print("LocalAuth shouldAuthenticateUser yes")
        }
        else {
            print("LocalAuth shouldAuthenticateUser no")
            self.unlockAppWithUser()
            return
        }

        if !viewModel.shouldRequestBiometrics() {
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
        myBetsBaseView.isHidden = true
        searchBaseView.isHidden = true
        casinoHomeBaseView.isHidden = true
        casinoTablesBaseView.isHidden = true
        casinoJackpotsBaseView.isHidden = true
        casinoSearchBaseView.isHidden = true
    }


}

// MARK: App States
extension RootTabBarViewController {

    // App States
    func unlockAppWithUser() {
        // Unlock the app

        viewModel.unlockAppWithUser()
    }

    func unlockAppAnonymous() {
        viewModel.unlockAppAnonymous()
        self.isLocalAuthenticationCoveringView = false
    }

    func showLocalAuthenticationCoveringViewIfNeeded() {
        if viewModel.shouldRequestBiometrics() {
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
        if viewModel.handleAppWillEnterForeground() {
            self.authenticateUser()
        }
        else if viewModel.isUserLogged() {

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
extension RootTabBarViewController {

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

extension RootTabBarViewController {
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
    
    private static func createWalletStatusOverlayView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }

    private static func createMainContainerView() -> UIView {
        let view = UIView()
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

        //
        view.addSubview(containerView)
        
        // Add main container views
        view.addSubview(topSafeAreaView)
        view.addSubview(topBarContainerBaseView)

        topBarContainerBaseView.addSubview(widgetToolBarView)

        //
        view.addSubview(bottomSafeAreaView)
        view.addSubview(localAuthenticationBaseView)

        tabBarView.addSubview(adaptiveTabBarView)

        // Setup container views
        containerView.addSubview(mainContainerView)

        // Add base views for child view controllers
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
        
        // Add betslip floating view
        view.addSubview(betslipFloatingView)
        
        // Add wallet status overlay (initially hidden)
        view.addSubview(walletStatusOverlayView)
        walletStatusOverlayView.addSubview(walletStatusView)
        walletStatusOverlayView.isHidden = true
        
        // Add tap gesture to dismiss overlay
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped(_:)))
        walletStatusOverlayView.addGestureRecognizer(tapGesture)

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

            // Main Container View - extend behind tab bar for blur effect
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
            
            // Betslip Floating View
            self.betslipFloatingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.betslipFloatingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            
            // Wallet Status Overlay
            self.walletStatusOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.walletStatusOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.walletStatusOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.walletStatusOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            // Wallet Status View (anchored below top bar)
            self.walletStatusView.leadingAnchor.constraint(equalTo: self.walletStatusOverlayView.leadingAnchor, constant: 50),
            self.walletStatusView.trailingAnchor.constraint(equalTo: self.walletStatusOverlayView.trailingAnchor, constant: -32),
            self.walletStatusView.topAnchor.constraint(equalTo: self.topBarContainerBaseView.bottomAnchor, constant: 16),
        ])

    }
    
    // MARK: - Betslip Navigation
    private func showBetslip() {
        onBetslipRequested?()
    }

}

// MARK: - Navigation Integration
// Navigation is handled by coordinators via closures:
// - onLoginRequested and onRegistrationRequested for authentication
// - onProfileRequested for profile navigation
// - onBetslipRequested for betslip presentation
