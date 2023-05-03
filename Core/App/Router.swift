//
//  Router.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

import UIKit
import Combine
import SwiftUI
import RegisterFlow

enum Route {
    case openBet(id: String)
    case resolvedBet(id: String)
    case event(id: String)
    case ticket(id: String)
    case chatMessage(id: String)
    case chatNotifications
    case none
}

class Router {

    var rootWindow: UIWindow
    var rootViewController: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }

    private var cancellables = Set<AnyCancellable>()
    private var showingDebugViewController: Bool = false

    var blockerViewController: UIViewController?
    var screenBlocker: ScreenBlocker = .none
    var startingRoute: Route = .none
    var appSharedState: AppSharedState?

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

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

    }

    func makeKeyAndVisible() {

        if TargetVariables.supportedThemes == Theme.allCases {
            self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        }
        else if TargetVariables.supportedThemes == [Theme.dark] {
            self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
        }
        else if TargetVariables.supportedThemes == [Theme.light] {
            self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        }
        else {
            self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        }

        let splashViewController = SplashViewController(loadingCompleted: {
            self.showPostLoadingFlow()
        })

        self.rootWindow.rootViewController = splashViewController

//        #if DEBUG
//        self.rootWindow.rootViewController = AnonymousSideMenuViewController(viewModel: AnonymousSideMenuViewModel())
//        #endif

        self.rootWindow.makeKeyAndVisible()
    }

    @objc func applicationDidBecomeActive(notification: NSNotification) {

    }

    func showPostLoadingFlow() {
        
        self.subscribeToUserActionBlockers()
        self.subscribeToURLRedirects()
        self.subscribeToNotificationsOpened()

        var bootRootViewController: UIViewController
        if Env.userSessionStore.isUserLogged() || UserSessionStore.didSkipLoginFlow() {
            bootRootViewController = Router.mainScreenViewControllerFlow()
        }
        else {
            bootRootViewController = Router.createLoginViewControllerFlow()
        }

        self.rootWindow.rootViewController = bootRootViewController
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

        Env.userSessionStore.acceptedTrackingPublisher
            .receive(on: DispatchQueue.main)
            .sink { acceptedTrackingState in

                switch acceptedTrackingState {
                case .unkown:
                    self.showUserTrackingViewController()
                case .accepted:
                    self.hideUserTrackingViewController()
                case .skipped:
                    self.hideUserTrackingViewController()
                }
            }
            .store(in: &self.cancellables)

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
                    () // Skip location updates
                case .notRequired:
                    () // Skip location updates
                }
            }
            .store(in: &cancellables)
    }

    func subscribeToURLRedirects() {
        Publishers.CombineLatest(Env.urlSchemaManager.redirectPublisher, Env.servicesProvider.eventsConnectionStatePublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] urlSubject, serviceStatus in
                if serviceStatus == .connected {
                    if let urlSubject = urlSubject["gamedetail"] {
                        self?.showMatchDetailScreen(matchId: urlSubject)
                    }
                    else if let urlSubject = urlSubject["bet"] {
                        self?.subscribeBetslipSharedTicketStatus(betToken: urlSubject)
                    }
                }
            })
            .store(in: &cancellables)
    }

    func subscribeToNotificationsOpened() {
        Env.servicesProvider.eventsConnectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] serviceStatus in
                if let requestStartingRoute = self?.requestStartingRoute(),
                   serviceStatus == .connected {
                    self?.appSharedState = .inactiveApp
                    self?.openRoute(requestStartingRoute)
                }
            })
            .store(in: &cancellables)
    }

    // Open from notifications
    func configureStartingRoute(_ route: Route) {
        self.startingRoute = route
    }

    func requestStartingRoute() -> Route {
        let tempStartingRoute = self.startingRoute
        self.startingRoute = .none
        return tempStartingRoute
    }

    func openedNotificationRouteWhileActive(_ route: Route) {
        self.appSharedState = .activeApp
        self.openRoute(route)
    }

    func openRoute(_ route: Route) {
        switch route {
        case .openBet(let id):
            self.showMyTickets(ticketType: MyTicketsType.opened, ticketId: id)
        case .resolvedBet(let id):
            self.showMyTickets(ticketType: MyTicketsType.resolved, ticketId: id)
        case .event(let id):
            self.showMatchDetailScreen(matchId: id)
        case .ticket(let id):
            self.showBetslipWithTicket(token: id)
        case .chatMessage(let id):
            self.showChatDetails(withId: id)
        case .chatNotifications:
            self.showChatNotifications()
        case .none:
            ()
        }
    }

    // MaintenanceScreen
    func showUnderMaintenanceScreen(withReason reason: String) {

        if let presentedViewController = self.rootViewController?.presentedViewController {
            if !(presentedViewController is MaintenanceViewController) {
                presentedViewController.dismiss(animated: false, completion: nil)
            }
        }

        let maintenanceViewController = MaintenanceViewController()
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
        let versionUpdateViewController = VersionUpdateViewController(updateRequired: true)
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
        let versionUpdateViewController = VersionUpdateViewController(updateRequired: false)
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
        self.rootViewController?.present(forbiddenAccessViewController, animated: true, completion: nil)
    }

    func showRequestLocationScreen() {
        self.hideLocationScreen()

        let permissionAccessViewController = RequestLocationAccessViewController()
        self.rootViewController?.present(permissionAccessViewController, animated: true, completion: nil)
    }

    func showRequestDeniedLocationScreen() {
        self.hideLocationScreen()

        let refusedAccessViewController = RefusedAccessViewController()
        self.rootViewController?.present(refusedAccessViewController, animated: true, completion: nil)
    }

    func showMatchDetailScreen(matchId: String) {
        if self.rootViewController?.presentedViewController?.isModal == true {
            self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        let matchDetailsViewController = MatchDetailsViewController(viewModel: MatchDetailsViewModel(matchId: matchId))
        self.rootViewController?.present(matchDetailsViewController, animated: true, completion: nil)
    }

    func showMyTickets(ticketType: MyTicketsType, ticketId: String) {
        if self.rootViewController?.presentedViewController?.isModal == true {
            self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }

        let betslipViewController = BetslipViewController.init(startScreen: .myTickets(ticketType, ticketId))
        let navigationViewController = Router.navigationController(with: betslipViewController)
        self.rootViewController?.present(navigationViewController, animated: true, completion: nil)
    }

    func showBetslip() {
        if self.rootViewController?.presentedViewController?.isModal == true {
            self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }

        let betslipViewController = BetslipViewController()
        let navigationViewController = Router.navigationController(with: betslipViewController)
        self.rootViewController?.present(navigationViewController, animated: true, completion: nil)
    }

    func showBetslipWithTicket(token: String) {

        if self.rootViewController?.presentedViewController?.isModal == true {
            self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        }

        if let appSharedState = self.appSharedState {
            switch appSharedState {
            case .inactiveApp:
                let betslipViewController = BetslipViewController(startScreen: .sharedBet(token))
                let navigationViewController = Router.navigationController(with: betslipViewController)
                self.rootViewController?.present(navigationViewController, animated: true, completion: nil)
            case .activeApp:

                Env.servicesProvider.eventsConnectionStatePublisher
                    .filter({ $0 == .connected })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in

                    }, receiveValue: { [weak self] _ in
                        let betslipViewController = BetslipViewController(startScreen: .sharedBet(token))
                        let navigationViewController = Router.navigationController(with: betslipViewController)
                        self?.rootViewController?.present(navigationViewController, animated: true, completion: nil)
                    })
                    .store(in: &cancellables)
            }
        }

    }

    //
    // User actions tracking
    func showUserTrackingViewController() {
        if let presentedViewController = self.rootViewController?.presentedViewController {
            if !(presentedViewController is UserTrackingViewController) {
                presentedViewController.dismiss(animated: false, completion: nil)
            }
        }
        let userTrackingViewController = UserTrackingViewController(viewModel: UserTrackingViewModel())
        let navigationController = Router.navigationController(with: userTrackingViewController)
        navigationController.isModalInPresentation = true
        self.rootViewController?.present(navigationController, animated: true, completion: nil)
    }

    func hideUserTrackingViewController() {
        if let presentedViewController = self.rootViewController?.presentedViewController,
           presentedViewController is UserTrackingViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
        else if let presentedViewController = self.rootViewController?.presentedViewController,
                let navigationController = presentedViewController as? UINavigationController,
                navigationController.rootViewController is UserTrackingViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    //
    // Chat
    func showChatNotifications() {
        let chatNotificationsViewController = ChatNotificationsViewController()
        self.showIntoSocialViewControllerModal(chatNotificationsViewController)
    }

    func showChatDetails(withId id: String) {
        guard let chatId = Int(id) else {return}

        let conversationDetailViewModel = ConversationDetailViewModel(chatId: chatId)
        let conversationDetailViewController = ConversationDetailViewController(viewModel: conversationDetailViewModel)
        self.showIntoSocialViewControllerModal(conversationDetailViewController)
    }

    private func showIntoSocialViewControllerModal(_ viewController: UIViewController) {
        if let rootNavigationViewController = self.rootViewController?.presentedViewController as? UINavigationController,
           rootNavigationViewController.rootViewController is SocialViewController {
            rootNavigationViewController.popToRootViewController(animated: true)

            rootNavigationViewController.pushViewController(viewController, animated: true)
        }
        else {
            if self.rootViewController?.presentedViewController?.isModal == true {
                self.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
            }

            let socialViewController = SocialViewController(viewModel: SocialViewModel())

            let navigationViewController = Router.navigationController(with: socialViewController)
            navigationViewController.pushViewController(viewController, animated: false)

            self.rootViewController?.present(navigationViewController, animated: true, completion: nil)
        }
    }

    //
    func subscribeBetslipSharedTicketStatus(betToken: String) {

        Env.urlSchemaManager.getBetslipTicketData(betToken: betToken)

        Env.urlSchemaManager.shouldShowBetslipPublisher
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
        return RootViewController(defaultSport: Env.sportsStore.defaultSport)
    }

    static func mainScreenViewControllerFlow() -> UIViewController {
        return Router.navigationController(with: RootViewController(defaultSport: Env.sportsStore.defaultSport) )
    }

}

extension Router {

    static func createDebugFeatureNavigation() -> UIViewController {
        let navigationController = UINavigationController(rootViewController: DebugViewController() )
        return navigationController
    }

    static func createLoginViewControllerFlow() -> UIViewController {

        let rootViewController = RootViewController(defaultSport: Env.sportsStore.defaultSport)

        let loginViewController = LoginViewController()

        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.viewControllers = [rootViewController, loginViewController]

        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true

        return navigationController
    }

    static func createRootViewControllerNavigation() -> UIViewController {
        return Router.navigationController(with: TestsViewController())
    }

    static func navigationController(with viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
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

enum AppSharedState {
    case inactiveApp
    case activeApp
}

