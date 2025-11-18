//
//  NextUpEventsCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit
import ServicesProvider
import GomaUI

class NextUpEventsCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Navigation Closures for MainCoordinator
    var onShowMatchDetail: ((Match) -> Void) = { _ in }
    var onShowSportsSelector: (() -> Void) = { }
    var onShowFilters: (() -> Void) = { }
    var onShowBetslip: (() -> Void) = { }
    var onShowCasinoTab: ((QuickLinkType) -> Void) = { _ in }
    var onShowBannerURL: ((String, String?) -> Void) = { _, _ in }

    // MARK: - Properties
    private let environment: Environment
    private var nextUpEventsViewModel: NextUpEventsViewModel?
    private var nextUpEventsViewController: NextUpEventsViewController?
    
    // Public accessor for MainCoordinator
    var viewController: UIViewController? {
        return nextUpEventsViewController
    }
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Navigation Methods
    
    private func showMatchDetail(for match: Match) {
        self.onShowMatchDetail(match)
    }
    
    private func showSportsSelector() {
        onShowSportsSelector()
    }
    
    private func showFilters() {
        onShowFilters()
    }
    
    private func showBetslip() {
        onShowBetslip()
    }
    
    private func showCasinoTab(for quickLinkType: QuickLinkType) {
        onShowCasinoTab(quickLinkType)
    }

    // MARK: - Footer Navigation (External Links)

    /// Opens URL in external Safari browser
    private func openExternalURL(_ url: URL) {
        print("🚀 [NextUpEventsCoordinator] Opening external URL: \(url)")
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("✅ [NextUpEventsCoordinator] Successfully opened URL")
            } else {
                print("❌ [NextUpEventsCoordinator] Failed to open URL")
            }
        }
    }

    /// Opens email in user's default email client via mailto: URL
    private func openEmailClient(email: String) {
        guard let mailtoURL = URL(string: "mailto:\(email)") else {
            print("❌ [NextUpEventsCoordinator] Invalid email address: \(email)")
            return
        }

        print("📧 [NextUpEventsCoordinator] Opening email client for: \(email)")
        UIApplication.shared.open(mailtoURL, options: [:]) { success in
            if success {
                print("✅ [NextUpEventsCoordinator] Successfully opened email client")
            } else {
                print("❌ [NextUpEventsCoordinator] Failed to open email client")
            }
        }
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Create view model with injected dependencies
        let viewModel = NextUpEventsViewModel(
            sport: Env.sportsStore.defaultSport,
            servicesProvider: environment.servicesProvider
        )
        self.nextUpEventsViewModel = viewModel
        
        // Setup MVVM-C navigation closures - ViewModels signal navigation intent
        viewModel.onMatchSelected = { [weak self] match in
            self?.showMatchDetail(for: match)
        }
        
        viewModel.onSportsSelectionRequested = { [weak self] in
            self?.showSportsSelector()
        }
        
        viewModel.onFiltersRequested = { [weak self] in
            self?.showFilters()
        }
        
        viewModel.onBetslipRequested = { [weak self] in
            self?.showBetslip()
        }
        
        viewModel.onCasinoQuickLinkSelected = { [weak self] quickLinkType in
            self?.showCasinoTab(for: quickLinkType)
        }

        viewModel.onBannerURLRequested = { [weak self] url, target in
            self?.onShowBannerURL(url, target)
        }

        // Create view controller
        let viewController = NextUpEventsViewController(viewModel: viewModel)
        self.nextUpEventsViewController = viewController

        // Setup footer navigation closures - Coordinator decides how to open URLs
        viewController.onURLOpenRequested = { [weak self] url in
            self?.openExternalURL(url)
        }

        viewController.onEmailRequested = { [weak self] email in
            self?.openEmailClient(email: email)
        }

        // MainTabBarCoordinator will handle embedding
    }
    
    func finish() {
        childCoordinators.removeAll()
        nextUpEventsViewController = nil
        nextUpEventsViewModel = nil
    }
    
    // MARK: - Public Methods for MainTabBarCoordinator
    func refresh() {
        let isLoggedIn = environment.userSessionStore.loggedUserProfile != nil
        print("[SessionExpiredDebug] 🔃 NextUpEventsCoordinator.refresh() - User logged in: \(isLoggedIn), calling reloadEvents(forced: true)")
        nextUpEventsViewModel?.reloadEvents(forced: true)
    }
    
    func updateSport(_ sport: Sport) {
        nextUpEventsViewModel?.updateSportType(sport)
    }
    
    func updateFilters(_ filters: AppliedEventsFilters) {
        nextUpEventsViewModel?.updateFilters(filters)
    }
    
    func findMatch(withId matchId: String) -> Match? {
        return nextUpEventsViewModel?.getMatch(withId: matchId)
    }
}
