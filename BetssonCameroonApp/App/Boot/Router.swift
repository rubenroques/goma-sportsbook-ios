//
//  Router.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

/*
 1. Router is NOT actively used - The app uses AppCoordinator instead
 2. Bootstrap creates an AppCoordinator (not Router) in line 26
 3. AppCoordinator is where the theme is actually applied to the window (line 48)

 The Router class exists in the codebase but its makeKeyAndVisible() method is never called. The changes I made to Router.swift won't have any effect because:
 - The Router is not instantiated anywhere
 - Bootstrap uses AppCoordinator instead
 - The theme logic in Router's makeKeyAndVisible() is never executed
 */

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
    }

    func makeKeyAndVisible() {

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
