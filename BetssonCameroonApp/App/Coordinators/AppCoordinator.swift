//
//  AppCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit
import Combine

class AppCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let window: UIWindow
    private let environment: Environment
    private let appStateManager: AppStateManager
    private var cancellables = Set<AnyCancellable>()
    
    // Child coordinators
    private var splashCoordinator: SplashCoordinator?
    private var maintenanceCoordinator: MaintenanceCoordinator?
    private var updateCoordinator: UpdateCoordinator?
    private var mainTabBarCoordinator: MainTabBarCoordinator?
    
    // MARK: - Initialization
    
    init(window: UIWindow, environment: Environment, appStateManager: AppStateManager) {
        self.window = window
        self.environment = environment
        self.appStateManager = appStateManager
        self.navigationController = UINavigationController()
        
        // Configure navigation controller (from Router.swift:375-382)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        // Apply saved theme preference or use default
        if TargetVariables.supportedThemes == AppearanceMode.allCases {
            // Use user's saved preference
            self.window.overrideUserInterfaceStyle = UserDefaults.standard.appearanceMode.userInterfaceStyle
        }
        else if TargetVariables.supportedThemes == [AppearanceMode.dark] {
            // Force dark mode if only dark is supported
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
        }
        else if TargetVariables.supportedThemes == [AppearanceMode.light] {
            // Force light mode if only light is supported
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
        else {
            // Default to system preference
            self.window.overrideUserInterfaceStyle = UIUserInterfaceStyle.unspecified
        }
        
        print("🎨 Theme applied: \(UserDefaults.standard.appearanceMode) -> \(self.window.overrideUserInterfaceStyle.rawValue)")


        setupStateObservation()
        setupSessionExpirationObservation()
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Initialize app state manager
        appStateManager.initialize()
    }
    
    func finish() {
        childCoordinators.removeAll()
        cancellables.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func setupStateObservation() {
        appStateManager.currentStatePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }

    private func setupSessionExpirationObservation() {
        print("[AppCoordinator] 👂 Setting up session expiration observation")

        environment.userSessionStore.sessionExpirationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] expirationReason in
                print("[AppCoordinator] 🚨 Session expiration event received: \(expirationReason)")
                self?.showSessionExpiredAlert(reason: expirationReason)
            }
            .store(in: &cancellables)
    }
    
    private func handleStateChange(_ state: AppState) {
        print("AppCoordinator: State changed to \(state)")
        switch state {
        case .initializing:
            // Do nothing, waiting for state manager to initialize
            break
            
        case .splashLoading:
            showSplashScreen()
            
        case .networkUnavailable:
            showNetworkUnavailableAlert()
            
        case .maintenanceMode(let message):
            showMaintenanceScreen(message: message)
            
        case .updateRequired:
            showUpdateScreen(isRequired: true)
            
        case .updateAvailable:
            showUpdateScreen(isRequired: false)
            
        case .servicesConnecting:
            // Keep splash screen visible while services are connecting
            break
            
        case .ready:
            showMainApp()
            
        case .error(let error):
            showErrorState(error: error)
        }
    }
    
    // MARK: - State Handlers
    
    private func showSplashScreen() {
        let splashCoordinator = SplashCoordinator(navigationController: navigationController)
        self.splashCoordinator = splashCoordinator
        addChildCoordinator(splashCoordinator)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        splashCoordinator.start()
    }
    
    private func showNetworkUnavailableAlert() {
        // Show network alert over splash screen (moved from SplashInformativeViewController)
        guard let topViewController = navigationController.topViewController else { return }
        
        let alert = UIAlertController(
            title: localized("no_internet"),
            message: localized("no_internet_connection_found_check_settings"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        topViewController.present(alert, animated: true, completion: nil)
    }
    
    private func showMaintenanceScreen(message: String) {
        // Remove all other coordinators
        cleanupChildCoordinators()
        
        let maintenanceCoordinator = MaintenanceCoordinator(
            navigationController: navigationController,
            message: message
        )
        
        self.maintenanceCoordinator = maintenanceCoordinator
        addChildCoordinator(maintenanceCoordinator)
        
        // For maintenance, replace root view controller entirely (full screen root)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        maintenanceCoordinator.start()
    }
    
    private func showUpdateScreen(isRequired: Bool) {
        let updateCoordinator = UpdateCoordinator(
            navigationController: navigationController,
            isRequired: isRequired
        )
        
        if !isRequired {
            updateCoordinator.onDismiss = { [weak self] in
                self?.appStateManager.dismissAvailableUpdate()
                self?.removeChildCoordinator(updateCoordinator)
            }
        }
        
        self.updateCoordinator = updateCoordinator
        addChildCoordinator(updateCoordinator)
        
        updateCoordinator.start()
    }
    
    private func showMainApp() {
        // Clean up splash coordinator
        if let splashCoordinator = splashCoordinator {
            removeChildCoordinator(splashCoordinator)
            self.splashCoordinator = nil
        }
        
        // Create main coordinator (equivalent to Router.showPostLoadingFlow)
        let mainTabBarCoordinator = MainTabBarCoordinator(
            navigationController: navigationController,
            environment: environment
        )
        
        self.mainTabBarCoordinator = mainTabBarCoordinator
        addChildCoordinator(mainTabBarCoordinator)
        
        // Set up main app root view controller
        window.rootViewController = navigationController
        
        mainTabBarCoordinator.start()
        
        // Start runtime monitoring after main app is shown
        // (equivalent to Router.subscribeToUserActionBlockers call in showPostLoadingFlow)
        appStateManager.startRuntimeMonitoring()
    }
    
    private func showErrorState(error: AppError) {
        // For now, we could show an error screen or retry mechanism
        // This could be expanded based on the type of error
        print("App Error: \(error)")
    }
    
    private func cleanupChildCoordinators() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
        
        // Reset specific coordinator references
        splashCoordinator = nil
        maintenanceCoordinator = nil
        updateCoordinator = nil
        mainTabBarCoordinator = nil
    }
    
    func openSharedRoute(_ route: Route) {
        print("BA ROUTE: \(route)")
        
        Publishers.CombineLatest3(environment.servicesProvider.eventsConnectionStatePublisher, environment.userSessionStore.isLoadingUserSessionPublisher, appStateManager.currentStatePublisher)
            .filter({ connection, isLoading, state in
                connection == .connected && isLoading == false && state == .ready
            })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
//                self?.appSharedState = .inactiveApp
                self?.openRoute(route)
            })
            .store(in: &cancellables)
    }
    
    func openRoute(_ route: Route) {
        
        switch route {
        case .register:
            self.showRegister()
            break
        case .login:
            self.showLogin()
        case .sportsHome:
            self.showSportsHome()
        case .liveGames:
            self.showLiveGames()
        case .myBets:
            self.showMyBets()
        case .sportsSearch:
            self.showSportsSearch()
        case .casinoHome:
            self.showCasinoHome()
        case .casinoVirtuals:
            self.showCasinoVirtual()
        case .casinoGame(let gameId):
            self.showCasinoGame(gameId: gameId)
        case .none:
            break
        default:
            break
        }
    }
    
    // Universal links routes show screens
    private func showRegister() {
        
        self.mainTabBarCoordinator?.showRegistration()
    }
    
    private func showLogin() {
        self.mainTabBarCoordinator?.showLogin()
    }
    
    private func showSportsHome() {
        let isLoggedIn = environment.userSessionStore.loggedUserProfile != nil
        print("[SessionExpiredDebug] ➡️ showSportsHome() - User logged in: \(isLoggedIn), calling showNextUpEventsScreen()")

        self.mainTabBarCoordinator?.showNextUpEventsScreen()
    }
    
    private func showLiveGames() {
        self.mainTabBarCoordinator?.showInPlayEventsScreen()
    }
    
    private func showMyBets() {
        self.mainTabBarCoordinator?.showMyBetsScreen()
    }
    
    private func showSportsSearch() {
        self.mainTabBarCoordinator?.showSearchScreen()
    }
    
    private func showCasinoHome() {
        self.mainTabBarCoordinator?.showCasinoHomeScreen()
    }
    
    private func showCasinoVirtual() {
        self.mainTabBarCoordinator?.showCasinoVirtualSportsScreen()
    }
    
    private func showCasinoGame(gameId: String) {
        if gameId == "32430" {
            self.mainTabBarCoordinator?.showCasinoAviatorGameScreen()
        }
        else {
            // TODO: Open specific games
        }
    }
    
    private func showCasinoSearch() {
        self.mainTabBarCoordinator?.showCasinoSearchScreen()
    }

    private func showDeposit() {
        self.mainTabBarCoordinator?.presentDepositFlow()
    }

    // MARK: - Session Expiration Alert

    private func showSessionExpiredAlert(reason: SessionExpirationReason) {
        print("[AppCoordinator] 🔔 Showing session expired alert")

        // Get top view controller to present alert
        guard let topViewController = navigationController.topViewController else {
            print("[AppCoordinator] ⚠️ No top view controller to present alert")
            return
        }

        // Check if an alert is already being presented
        if topViewController.presentedViewController is UIAlertController {
            print("[AppCoordinator] ⚠️ Alert already presented, skipping")
            return
        }

        // Create alert
        let alert = UIAlertController(
            title: localized("you_are_logged_out"),  // "You are logged out"
            message: localized("your_session_has_ended"),  // "Your session has ended"
            preferredStyle: .alert
        )

        // "Go Home" button (default style)
        let goHomeAction = UIAlertAction(
            title: localized("go_home"),  // "Go Home"
            style: .default
        ) { [weak self] _ in
            print("[AppCoordinator] 👤 User tapped 'Go Home' after session expiration")
            self?.handleGoHomeAfterExpiration()
        }

        // "Login" button (default style, will be bold via preferredAction)
        let loginAction = UIAlertAction(
            title: localized("login"),  // "Login"
            style: .default
        ) { [weak self] _ in
            print("[AppCoordinator] 🔐 User tapped 'Login' after session expiration")
            self?.handleLoginAfterExpiration()
        }

        alert.addAction(goHomeAction)
        alert.addAction(loginAction)

        // Set preferred action (makes it bold/primary)
        alert.preferredAction = loginAction

        print("[AppCoordinator] 📱 Presenting session expiration alert")
        topViewController.present(alert, animated: true) {
            print("[AppCoordinator] ✅ Session expiration alert presented")
        }
    }

    private func handleGoHomeAfterExpiration() {
        print("[AppCoordinator] 🏠 Navigating to home after session expiration")

        let isLoggedIn = environment.userSessionStore.loggedUserProfile != nil
        print("[SessionExpiredDebug] 🔘 handleGoHomeAfterExpiration() - User logged in: \(isLoggedIn)")

        // Navigate to splash/landing screen (user is already logged out)
        showSportsHome()
    }

    private func handleLoginAfterExpiration() {
        print("[AppCoordinator] 🔐 Navigating to login after session expiration")

        // Navigate to splash which will show login screen (user is already logged out)
        showLogin()
    }
}

extension AppCoordinator {
    static func navigationController(with viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        return navigationController
    }
}
