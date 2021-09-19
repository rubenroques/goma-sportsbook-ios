//
//  Router.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

import UIKit
import Combine

class Router {

    var rootWindow: UIWindow
    var rootViewController: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }

    var cancellables = Set<AnyCancellable>()

    var blockerViewController: UIViewController?
    var screenBlocker: ScreenBlocker = .none

    enum ScreenBlocker {
        case maintenance
        case updateRequired
        case updateAvailable
        case offline
        case invalidLocation
        case none
    }

    init(window: UIWindow) {
        self.rootWindow = window
    }

    func makeKeyAndVisible() {

        var bootRootViewController: UIViewController
        if UserSessionStore.isUserLogged() || UserSessionStore.isUserAnonymous() {
            bootRootViewController = Router.mainScreenViewControllerFlow()
        }
        else {
            bootRootViewController = Router.createLoginViewControllerFlow()
        }

        self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        self.rootWindow.rootViewController = bootRootViewController
        self.rootWindow.makeKeyAndVisible()

        self.subscribeToUserActionBlockers()
    }

    func subscribeToUserActionBlockers() {
        Env.clientSettingsSocket.maintenanceModePublisher
            .receive(on: RunLoop.main)
            .sink { message in
            if let messageValue = message {
                self.showUnderMaintenanceScreen(withReason: messageValue)
            }
            else {
                self.hideUnderMaintenanceScreen()
            }
        }
        .store(in: &cancellables)

        Env.clientSettingsSocket.requiredVersionPublisher
            .receive(on: RunLoop.main)
            .delay(for: 3, scheduler: RunLoop.main).sink { serverVersion in

            guard
                let currentVersion = Bundle.main.versionNumber,
                let serverRequiredVersion = serverVersion.required,
                let serverCurrentVersion = serverVersion.current
            else {
                return
            }

            if currentVersion.compare(serverRequiredVersion, options: .numeric) == .orderedAscending {
                self.showRequiredUpdateScreen()
            }
            else if currentVersion.compare(serverCurrentVersion, options: .numeric) == .orderedAscending {
                self.showAvailableUpdateScreen()
            }
            else {
                self.hideRequiredUpdateScreen()
            }
        }
        .store(in: &cancellables)

        Env.locationManager.locationStatus
            .receive(on: RunLoop.main)
            .sink { locationStatus in
            switch locationStatus {
            case .valid:
                self.hideLocationScreen()
            case .invalid:
                self.showInvalidLocationScreen()
            case .notRequested:
                self.showRequestLocationScreen()
            case .notAuthorized:
                self.showRequestDeniedLocationScreen()
            case .notDetermined:
                ()
            }
        }
        .store(in: &cancellables)
    }

    // MaintenanceScreen
    func showUnderMaintenanceScreen(withReason reason: String) {

        if let presentedViewController = self.rootViewController?.presentedViewController {
            presentedViewController.dismiss(animated: false, completion: nil)
        }

        let maintenanceViewController = MaintenanceViewController()
        maintenanceViewController.isModalInPresentation = true
        self.rootViewController?.present(maintenanceViewController, animated: true, completion: nil)

        self.blockerViewController = maintenanceViewController
    }

    func hideUnderMaintenanceScreen() {
        if let presentedViewController = self.rootViewController?.presentedViewController,
           presentedViewController is MaintenanceViewController {
            presentedViewController.dismiss(animated: false, completion: nil)
        }
    }

    // UpdateScreen
    func showRequiredUpdateScreen() {

        if self.blockerViewController.hasValue {
            return
        }
        
        let versionUpdateViewController = VersionUpdateViewController(required: true)
        versionUpdateViewController.isModalInPresentation = true
        self.rootViewController?.present(versionUpdateViewController, animated: true, completion: nil)

        self.blockerViewController = versionUpdateViewController
    }

    func hideRequiredUpdateScreen() {
        if let blockerViewController = blockerViewController {
            blockerViewController.dismiss(animated: true) { [weak self] in
                self?.blockerViewController = nil
            }
        }
    }

    // UpdateScreen
    func showAvailableUpdateScreen() {

        if self.blockerViewController.hasValue {
            return
        }

        let versionUpdateViewController = VersionUpdateViewController(required: false)
        versionUpdateViewController.isModalInPresentation = false
        versionUpdateViewController.dismissCallback = { [weak self] in
            self?.blockerViewController = nil
        }
        self.rootViewController?.present(versionUpdateViewController, animated: true, completion: nil)

        self.blockerViewController = versionUpdateViewController
    }

    static func shouldShowUpdateAppPopUpScreen() -> Bool {
        guard
            let currentVersion = Bundle.main.versionNumber,
            let serverVersion = Env.clientSettingsSocket.clientSettings?.currentAppVersion else {
            return false
        }

        return currentVersion.compare(serverVersion, options: .numeric) == .orderedAscending
    }

    func hideLocationScreen() {
        
        if let presentedViewController = self.rootViewController?.presentedViewController,
           (presentedViewController is ForbiddenLocationViewController ||
            presentedViewController is RequestLocationAccessViewController ||
                presentedViewController is RefusedAccessViewController) {

            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    func showInvalidLocationScreen() {
        self.hideLocationScreen()

        let forbiddenAccessViewController = ForbiddenLocationViewController()
        forbiddenAccessViewController.isModalInPresentation = true
        self.rootViewController?.present(forbiddenAccessViewController, animated: true, completion: nil)
    }

    func showRequestLocationScreen() {
        self.hideLocationScreen()

        let permissionAccessViewController = RequestLocationAccessViewController()
        permissionAccessViewController.isModalInPresentation = true
        self.rootViewController?.present(permissionAccessViewController, animated: true, completion: nil)
    }

    func showRequestDeniedLocationScreen() {
        self.hideLocationScreen()
        
        let refusedAccessViewController = RefusedAccessViewController()
        refusedAccessViewController.isModalInPresentation = true
        self.rootViewController?.present(refusedAccessViewController, animated: true, completion: nil)
    }

}


extension Router {

    func presentViewControllerAsRoot(_ viewController: UIViewController) {
        self.rootWindow.rootViewController = rootViewController
    }

    static func mainScreenViewController() -> UIViewController {
        return RootViewController()
    }

    static func mainScreenViewControllerFlow() -> UIViewController {
        return Router.navigationController(with: RootViewController() )
    }

}


extension Router {

    static func createDebugFeatureNavigation() -> UIViewController {
        let navigationController = UINavigationController(rootViewController: DebugViewController() )
        return navigationController
    }

    static func createLoginViewControllerFlow() -> UIViewController {
        return Router.navigationController(with: LoginViewController())
    }

    static func createRootViewControllerNavigation() -> UIViewController {
        return Router.navigationController(with: RootViewController())
    }

    static func navigationController(with viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        return navigationController
    }

}
