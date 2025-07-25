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

    var startingRoute: Route = .none
    var appSharedState: AppSharedState?

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

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    func makeKeyAndVisible() {
        
        // MIGRATED
        // self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        
//        #if DEBUG
//        // manual theme override
//        self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
//        //
//        #else
//        if TargetVariables.supportedThemes == AppearanceMode.allCases {
//            self.rootWindow.overrideUserInterfaceStyle = UserDefaults.standard.appearanceMode.userInterfaceStyle
//        }
//        else if TargetVariables.supportedThemes == [AppearanceMode.dark] {
//            self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
//        }
//        else if TargetVariables.supportedThemes == [AppearanceMode.light] {
//            self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
//        }
//        else {
//            self.rootWindow.overrideUserInterfaceStyle = UIUserInterfaceStyle.unspecified
//        }
//        #endif

//
//        let splashInformativeViewController = SplashInformativeViewController(loadingCompleted: {
//            self.showPostLoadingFlow()
//        })
//        self.rootWindow.rootViewController = splashInformativeViewController
//        self.rootWindow.makeKeyAndVisible()
    }

    @objc func applicationDidBecomeActive(notification: NSNotification) {

    }

    func showPostLoadingFlow() {
        // MIGRATED
//        var bootRootViewController: UIViewController
//        
//        let viewModel = RootAdaptiveScreenViewModel()
//        let rootViewController = RootAdaptiveViewController(viewModel: viewModel)
//        self.rootActionable = rootViewController
//        bootRootViewController = Router.mainScreenViewControllerFlow(rootViewController)
//
//        //
//        self.subscribeToUserActionBlockers()
//        
//        self.subscribeToURLRedirects()
//        
//        self.subscribeToNotificationsOpened()
//        
//        self.rootWindow.rootViewController = bootRootViewController
    }

    func subscribeToUserActionBlockers() {
        // MIGRATED
//        Env.businessSettingsSocket.maintenanceModePublisher
//            .receive(on: DispatchQueue.main)
//            .sink { maintenanceMode in
//
//                switch maintenanceMode {
//                case .enabled(let message):
//                    self.showUnderMaintenanceScreen(withReason: message)
//                case .disabled:
//                    self.hideUnderMaintenanceScreen()
//                case .unknown:
//                    break
//                }
//            }
//            .store(in: &self.cancellables)
//
//        Env.businessSettingsSocket.requiredVersionPublisher
//            .receive(on: DispatchQueue.main)
//            .delay(for: 3, scheduler: DispatchQueue.main)
//            .sink { serverVersion in
//
//                guard
//                    let currentVersion = Bundle.main.versionNumber,
//                    let serverRequiredVersion = serverVersion.required,
//                    let serverCurrentVersion = serverVersion.current
//                else {
//                    return
//                }
//
//                if currentVersion.compare(serverRequiredVersion, options: .numeric) == .orderedAscending {
//                    self.showRequiredUpdateScreen()
//                }
//                else if currentVersion.compare(serverCurrentVersion, options: .numeric) == .orderedAscending {
//                    self.showAvailableUpdateScreen()
//                }
//                else {
//                    self.hideRequiredUpdateScreen()
//                }
//            }
//            .store(in: &cancellables)

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

    func openPushNotificationRoute(_ route: Route) {
        Publishers.CombineLatest(Env.servicesProvider.eventsConnectionStatePublisher, Env.userSessionStore.isLoadingUserSessionPublisher)
            .filter({ connection, isLoading in
                connection == .connected && isLoading == false
            })
            .receive(on: DispatchQueue.main)
            .first()
            .sink(receiveValue: { [weak self] _ in
                self?.appSharedState = .inactiveApp
                self?.openRoute(route)
            })
            .store(in: &cancellables)
    }

    func openRoute(_ route: Route) {

        switch route {
        case .openBet(_):
            // self.showMyTickets(ticketType: MyTicketsType.opened, ticketId: id)
            break
        case .resolvedBet(_):
            // self.showMyTickets(ticketType: MyTicketsType.resolved, ticketId: id)
            break
        case .event(let id):
            self.showMatchDetailScreen(matchId: id)
        case .ticket(let id):
            self.showBetslipWithTicket(token: id)
        case .chatMessage(_):
            // self.showChatDetails(withId: id)
            break
        case .chatNotifications:
            // self.showChatNotifications()
            break
        case .competition(_):
            // self.showCompetitionDetailsScreen(competitionId: id)
            break
        case .contactSettings:
            self.showContactSettings()
        case .betSwipe:
            break
        case .deposit:
            self.showDeposit()
        case .bonus:
            self.showBonus()
        case .documents:
            self.showDocuments()
        case .customerSupport:
            self.showCustomerSupport()
        case .favorites:
            self.showFavorites()
        case .promotions:
            self.showPromotions()
        case .referral(let code):
            self.showRegisterWithCode(code: code)
        case .responsibleForm:
            self.showResponsibleForm()
        case .none:
            break
        
        }
    }

    // MaintenanceScreen
    func showUnderMaintenanceScreenOnBoot() {
        let maintenanceViewController = MaintenanceViewController()
        self.rootWindow.rootViewController = maintenanceViewController
        self.rootWindow.makeKeyAndVisible()
    }

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

    func showMatchDetailScreen(matchId: String) {

    }

    func showBetslip() {
    
    }

    func showBetslipWithTicket(token: String) {

    }

    func showCompetitionDetails(competitionId: String) {

    }

    func showContactSettings() {

    }

    func showDeposit() {

    }

    func showBonus() {

    }

    func showDocuments() {

    }

    func showCustomerSupport() {

    }

    func showFavorites() {

    }

    func showPromotions() {

    }

    func showRegisterWithCode(code: String) {

    }

    func showResponsibleForm() {

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

    static func mainScreenViewControllerFlow(_ viewController: UIViewController) -> UIViewController {
        return Router.navigationController(with: viewController)
    }

}

extension Router {


    static func navigationController(with viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = false
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        return navigationController
    }

}
