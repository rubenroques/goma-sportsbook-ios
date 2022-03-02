//
//  Router.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

import UIKit
import Combine
import SwiftUI

class Router {

    var rootWindow: UIWindow
    var rootViewController: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }

    private var cancellables = Set<AnyCancellable>()
    private var showingDebugViewController: Bool = false

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
        self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle

        let splashViewController = SplashViewController(loadingCompleted: {
            self.showPostLoadingFlow()
        })
        self.rootWindow.rootViewController = splashViewController
        self.rootWindow.makeKeyAndVisible()
    }

    func showPostLoadingFlow() {

        self.subscribeToUserActionBlockers()
        self.subscribeToUserActionRedirects()

        var bootRootViewController: UIViewController
        if UserSessionStore.isUserLogged() || UserSessionStore.didSkipLoginFlow() {
            bootRootViewController = Router.mainScreenViewControllerFlow()
        }
        else {
            bootRootViewController = Router.createLoginViewControllerFlow()
        }

        self.rootWindow.rootViewController = bootRootViewController
//        let viewModel =  OutrightMarketDetailsViewModel(competition:
//                                                            Competition(id: "157127366340038656",
//                                                                        name: "F1",
//                                                                        outrightMarkets: 0),
//                                                        store: OutrightMarketDetailsStore())
//        self.rootWindow.rootViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
        
    }

    func subscribeToUserActionBlockers() {
        Env.businessSettingsSocket.maintenanceModePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
                if let messageValue = message {
                    self.showUnderMaintenanceScreen(withReason: messageValue)
                }
                else {
                    self.hideUnderMaintenanceScreen()
                }
            }
            .store(in: &cancellables)

        Env.businessSettingsSocket.requiredVersionPublisher
            .receive(on: DispatchQueue.main)
            .delay(for: 3, scheduler: DispatchQueue.main)
            .sink { serverVersion in

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
            .receive(on: DispatchQueue.main)
            .sink { locationStatus in

                Logger.log("Router.locationManager received \(locationStatus)")

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

    func subscribeToUserActionRedirects() {
        Publishers.CombineLatest(Env.urlSchemaManager.redirectPublisher, Env.everyMatrixClient.serviceStatusPublisher)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] urlSubject, serviceStatus in

                        if serviceStatus == .connected {

                            if Env.everyMatrixClient.manager.isConnected {
                                if let urlSubject = urlSubject["gamedetail"] {

                                    self?.showMatchDetailScreen(matchId: urlSubject)

                                }
                                else if let urlSubject = urlSubject["bet"] {

                                    self?.subscribeBetslipSharedTicketStatus(betToken: urlSubject)
                                }
                            }
                        }
                    })
                    .store(in: &cancellables)
    }

    // MaintenanceScreen
    func showUnderMaintenanceScreen(withReason reason: String) {

        if let presentedViewController = self.rootViewController?.presentedViewController {
            if !(presentedViewController is MaintenanceViewController) {
                presentedViewController.dismiss(animated: false, completion: nil)
            }
        }

        let maintenanceViewController = MaintenanceViewController()
        maintenanceViewController.isModalInPresentation = true
        self.rootViewController?.present(maintenanceViewController, animated: true, completion: nil)
    }

    func hideUnderMaintenanceScreen() {
        if let presentedViewController = self.rootViewController?.presentedViewController,
           presentedViewController is MaintenanceViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    // Required Update Screen
    func showRequiredUpdateScreen() {
        let versionUpdateViewController = VersionUpdateViewController(required: true)
        versionUpdateViewController.isModalInPresentation = true
        self.rootViewController?.present(versionUpdateViewController, animated: true, completion: nil)
    }

    func hideRequiredUpdateScreen() {

        if let presentedViewController = self.rootViewController?.presentedViewController,
           presentedViewController is VersionUpdateViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    // Update Screen
    func showAvailableUpdateScreen() {
        let versionUpdateViewController = VersionUpdateViewController(required: false)
        versionUpdateViewController.isModalInPresentation = false
        self.rootViewController?.present(versionUpdateViewController, animated: true, completion: nil)
    }

    static func shouldShowUpdateAppPopUpScreen() -> Bool {
        guard
            let currentVersion = Bundle.main.versionNumber,
            let serverVersion = Env.businessSettingsSocket.clientSettings?.currentAppVersion else {
                return false
            }

        return currentVersion.compare(serverVersion, options: .numeric) == .orderedAscending
    }

    func hideLocationScreen() {
        if let presentedViewController = self.rootViewController?.presentedViewController {
            if presentedViewController is ForbiddenLocationViewController ||
                presentedViewController is RequestLocationAccessViewController ||
                presentedViewController is RefusedAccessViewController {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
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

    func showMatchDetailScreen(matchId: String) {
        if self.rootViewController?.presentedViewController?.isModal == true {
            self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        let matchDetailViewController = MatchDetailsViewController(matchId: matchId)
        matchDetailViewController.isModalInPresentation = true
        self.rootViewController?.present(matchDetailViewController, animated: true, completion: nil)
    }

    func showBetslip() {
        if self.rootViewController?.presentedViewController?.isModal == true {
            self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }

        let betslipViewController = BetslipViewController()
        betslipViewController.isModalInPresentation = true

        Env.urlSchemaManager.showBetslipPublisher.send(false)

        self.rootViewController?.present(betslipViewController, animated: true, completion: nil)

    }

    func subscribeBetslipSharedTicketStatus(betToken: String) {

        Env.urlSchemaManager.getBetslipTicketData(betToken: betToken)

        Env.urlSchemaManager.showBetslipPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] showBetslip in
                if showBetslip {
                    self?.showBetslip()
                }
            })
            .store(in: &cancellables)
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
        return Router.navigationController(with: TestsViewController())
    }

    static func navigationController(with viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        return navigationController
    }

}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.bootstrap.router.showDebugView()
        }
    }
}

extension Router {
    func showDebugView() {
        if showingDebugViewController {
            return
        }

        Logger.log("Debug screen called")
        showingDebugViewController = true

        if TargetVariables.environmentType == .dev {

            let debugViewController = DebugViewController()
            debugViewController.isBeingDismissedAction = { [weak self] _ in
                self?.showingDebugViewController = false
            }
            let navigationController = UINavigationController(rootViewController: debugViewController)
            navigationController.modalPresentationStyle = .fullScreen
            rootWindow.rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
}
