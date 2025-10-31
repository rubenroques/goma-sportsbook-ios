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
}
