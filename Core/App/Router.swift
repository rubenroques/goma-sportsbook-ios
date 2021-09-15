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
    var rootViewController: UIViewController?

    var cancellables = Set<AnyCancellable>()

    var blockerViewController: UIViewController?

    init(window: UIWindow) {
        self.rootWindow = window
    }

    func bootstrap() {

        var bootRootViewController: UIViewController
        if UserSessionStore.isUserLogged() {
            bootRootViewController = RootViewController()
        }
        else {
            bootRootViewController = LoginViewController()
        }
        self.rootViewController = bootRootViewController

        self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        self.rootWindow.rootViewController = bootRootViewController

        self.subscribeToUserActionBlockers()

        self.rootWindow.makeKeyAndVisible()
    }

    func subscribeToUserActionBlockers() {
        Env.clientSettingsSocket.maintenanceModePublisher.receive(on: RunLoop.main).sink { value in
            if let messageValue = value {
                self.showUnderMaintenancePage(withReason: messageValue)
            }
            else {
                self.hideUnderMaintenancePage()
            }
        }
        .store(in: &cancellables)
    }

    func showUnderMaintenancePage(withReason reason: String) {
        let maintenanceViewController = MaintenanceViewController()
        //maintenanceViewController.modalPresentationStyle = .fullScreen
        maintenanceViewController.isModalInPresentation = true
        self.rootViewController?.present(maintenanceViewController, animated: true, completion: nil)
    }

    func hideUnderMaintenancePage() {
        if let blockerViewController = blockerViewController {
            blockerViewController.dismiss(animated: true) { [weak self] in
                self?.blockerViewController = nil
            }
        }
    }

}

extension Router {

    static func createDebugFeatureNavigation() -> UIViewController {
        let navigationController = UINavigationController(rootViewController: DebugViewController() )
        return navigationController
    }

}
