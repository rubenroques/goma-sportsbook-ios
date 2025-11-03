//
//  InPlayEventsCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit
import ServicesProvider
import GomaUI

class InPlayEventsCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Navigation Closures for MainCoordinator
    var onShowMatchDetail: ((Match) -> Void) = { _ in }
    var onShowSportsSelector: (() -> Void) = { }
    var onShowFilters: (() -> Void) = { }
    var onShowCasinoTab: ((QuickLinkType) -> Void) = { _ in }
    
    // MARK: - Properties
    private let environment: Environment
    private var inPlayEventsViewModel: InPlayEventsViewModel?
    private var inPlayEventsViewController: InPlayEventsViewController?
    
    // Public accessor for MainCoordinator
    var viewController: UIViewController? {
        return inPlayEventsViewController
    }
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Navigation Methods
    
    private func showMatchDetail(for match: Match) {
        onShowMatchDetail(match)
    }
    
    private func showSportsSelector() {
        onShowSportsSelector()
    }
    
    private func showFilters() {
        onShowFilters()
    }
    
    private func showCasinoTab(for quickLinkType: QuickLinkType) {
        onShowCasinoTab(quickLinkType)
    }

    // MARK: - Footer Navigation (External Links)

    /// Opens URL in external Safari browser
    private func openExternalURL(_ url: URL) {
        print("🚀 [InPlayEventsCoordinator] Opening external URL: \(url)")
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("✅ [InPlayEventsCoordinator] Successfully opened URL")
            } else {
                print("❌ [InPlayEventsCoordinator] Failed to open URL")
            }
        }
    }

    /// Opens email in user's default email client via mailto: URL
    private func openEmailClient(email: String) {
        guard let mailtoURL = URL(string: "mailto:\(email)") else {
            print("❌ [InPlayEventsCoordinator] Invalid email address: \(email)")
            return
        }

        print("📧 [InPlayEventsCoordinator] Opening email client for: \(email)")
        UIApplication.shared.open(mailtoURL, options: [:]) { success in
            if success {
                print("✅ [InPlayEventsCoordinator] Successfully opened email client")
            } else {
                print("❌ [InPlayEventsCoordinator] Failed to open email client")
            }
        }
    }

    // MARK: - Coordinator Protocol
    func start() {
        
        // Create view model with injected dependencies
        let viewModel = InPlayEventsViewModel(
            sport: Env.sportsStore.defaultSport,
            servicesProvider: environment.servicesProvider
        )
        self.inPlayEventsViewModel = viewModel
        
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
        
        viewModel.onCasinoQuickLinkSelected = { [weak self] quickLinkType in
            self?.showCasinoTab(for: quickLinkType)
        }
        
        // Create view controller
        let viewController = InPlayEventsViewController(viewModel: viewModel)
        self.inPlayEventsViewController = viewController

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
        inPlayEventsViewController = nil
        inPlayEventsViewModel = nil
    }
    
    // MARK: - Public Methods for MainTabBarCoordinator
    func refresh() {
        inPlayEventsViewModel?.reloadEvents(forced: true)
    }
        
    func updateSport(_ sport: Sport) {
        inPlayEventsViewModel?.updateSportType(sport)
    }
    
    func updateFilters(_ filters: AppliedEventsFilters) {
        inPlayEventsViewModel?.updateFilters(filters)
    }
    
    func findMatch(withId matchId: String) -> Match? {
        return inPlayEventsViewModel?.getMatch(withId: matchId)
    }
}
