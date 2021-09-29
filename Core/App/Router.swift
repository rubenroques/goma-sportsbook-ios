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

    private var showingDebug: Bool = false

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

        let splashViewController = SplashViewController {
            self.showPostLoadingFlow()
        }

        //        #if DEBUG
        //        self.rootWindow.rootViewController = Router.navigationController(with: HomeViewController() )
        //        #else
        //        self.rootWindow.rootViewController = bootRootViewController
        //        #endif

        self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        //self.rootWindow.rootViewController = splashViewController
        self.rootWindow.rootViewController = RootViewController()
        self.rootWindow.makeKeyAndVisible()

        self.subscribeToUserActionBlockers()
    }

    func showPostLoadingFlow() {

        var bootRootViewController: UIViewController
        if UserSessionStore.isUserLogged() || UserSessionStore.didSkipLoginFlow() {
            bootRootViewController = Router.mainScreenViewControllerFlow()
        }
        else {
            bootRootViewController = Router.createLoginViewControllerFlow()
        }
        self.rootWindow.rootViewController = bootRootViewController
    }


    func subscribeToUserActionBlockers() {
        Env.businessSettingsSocket.maintenanceModePublisher
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

        Env.businessSettingsSocket.requiredVersionPublisher
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

}

extension Router {

    func presentViewControllerAsRoot(_ viewController: UIViewController) {
        self.rootWindow.rootViewController = rootViewController
    }

    static func mainScreenViewController() -> UIViewController {
        return HomeViewController()
    }

    static func mainScreenViewControllerFlow() -> UIViewController {
        return Router.navigationController(with: HomeViewController() )
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



extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.bootstrap.router.showDebugView()
        }
    }
}


extension Router {
    func showDebugView() {
        if showingDebug {
            return
        }

        Logger.log("Debug screen called")
        showingDebug = true

        if TargetVariables.environmentType == .dev {

            let debugViewController = DebugViewController()
            debugViewController.isBeingDismissedAction = { [weak self] _ in
                self?.showingDebug = false
            }
            let navigationController = UINavigationController(rootViewController: debugViewController)
            navigationController.modalPresentationStyle = .fullScreen
            rootWindow.rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
}



class TestViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "TestViewController-1"
        self.view.backgroundColor = .systemBlue
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        executeDelayed(2) {
            self.showModal()
        }
    }

    func showModal() {
        let testVc = Test2ViewController()
        let navigationController = UINavigationController(rootViewController: testVc)
        self.present(navigationController, animated: true, completion: nil)
    }
}

class Test2ViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "TestViewController-2"
        self.view.backgroundColor = .systemRed
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        executeDelayed(2) {
            self.push()
        }
    }

    func push() {
        self.navigationController?.pushViewController(Test3ViewController(), animated: true)
    }
}

class Test3ViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "TestViewController 3"
        self.view.backgroundColor = .systemRed

        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
    }

}
