//
//  MainCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 24/07/2025.
//

import UIKit
import ServicesProvider
import GomaUI

class RootTabBarCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    private let environment: Environment
    private var rootTabBarViewController: RootTabBarViewController?
    
    // MARK: - Lazy Screen Coordinators
    // These are only created when the user navigates to the respective tabs
    
    private var nextUpEventsCoordinator: NextUpEventsCoordinator?
    private var inPlayEventsCoordinator: InPlayEventsCoordinator?
    private var casinoCoordinator: CasinoCoordinator?
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Create the main screen structure (equivalent to Router.showPostLoadingFlow)
        let viewModel = RootTabBarViewModel(userSessionStore: environment.userSessionStore)
        let rootTabBarViewController = RootTabBarViewController(viewModel: viewModel)
        
        
        rootTabBarViewController.onTabSelected = { [weak self] tabItem in
            self?.handleTabSelection(tabItem)
        }
        self.rootTabBarViewController = rootTabBarViewController
        navigationController.setViewControllers([rootTabBarViewController], animated: false)
        
        // Show default screen on startup (NextUpEvents)
        self.showNextUpEventsScreen()
    }
    
    func finish() {
        childCoordinators.removeAll()
        
        // Clean up lazy coordinators
        nextUpEventsCoordinator = nil
        inPlayEventsCoordinator = nil
        casinoCoordinator = nil
        rootTabBarViewController = nil
    }
    
    // MARK: - Private Methods
  
        
    // MARK: - Tab Selection Handling
    
    private func handleTabSelection(_ tabItem: TabItem) {
        // Show the selected screen through coordinator
        // RootTabBarViewController will handle hiding other screens internally
        switch tabItem.identifier {
        case .nextUpEvents:
            showNextUpEventsScreen()
        case .inPlayEvents:
            showInPlayEventsScreen()
        case .myBets:
            showMyBetsScreen()
        case .sportsSearch:
            showSearchScreen()
        case .casinoHome:
            showCasinoHomeScreen()
        case .casinoVirtualSports:
            showCasinoVirtualSportsScreen()
        case .casinoAviatorGame:
            showCasinoAviatorGameScreen()
        case .casinoSearch:
            showCasinoSearchScreen()
        case .sportsHome:
            showNextUpEventsScreen() // Map sportsHome to nextUpEvents
        default:
            break
        }
    }
    
    // MARK: - Lazy Screen Loading
    
    private func showNextUpEventsScreen() {
        // Lazy loading: only create coordinator when needed
        if nextUpEventsCoordinator == nil {
            let coordinator = NextUpEventsCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowMatchDetail = { [weak self] matchId in
                self?.showMatchDetail(match: matchId)
            }
            
            coordinator.onShowSportsSelector = { [weak self] in
                self?.showSportsSelector()
            }
            
            coordinator.onShowFilters = { [weak self] in
                self?.showFilters()
            }
            
            nextUpEventsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        // Show the screen through RootTabBarViewController
        if let viewController = nextUpEventsCoordinator?.viewController {
            rootTabBarViewController?.showNextUpEventsScreen(with: viewController)
        }
        
        // Refresh if needed
        nextUpEventsCoordinator?.refresh()
    }
    
    private func showInPlayEventsScreen() {
        // Lazy loading: only create coordinator when needed
        if inPlayEventsCoordinator == nil {
            let coordinator = InPlayEventsCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowMatchDetail = { [weak self] match in
                self?.showMatchDetail(match: match)
            }
            
            coordinator.onShowSportsSelector = { [weak self] in
                self?.showSportsSelector()
            }
            
            coordinator.onShowFilters = { [weak self] in
                self?.showFilters()
            }
            
            inPlayEventsCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        // Show the screen through RootTabBarViewController
        if let viewController = inPlayEventsCoordinator?.viewController {
            rootTabBarViewController?.showInPlayEventsScreen(with: viewController)
        }
        
        // Refresh if needed
        inPlayEventsCoordinator?.refresh()
    }
    
    // MARK: - Navigation Actions
    // These will be implemented based on the existing Router functionality
    
    private func showMatchDetail(match: Match) {
        let matchDetailsViewModel = MatchDetailsTextualViewModel(
            match: match,
            servicesProvider: environment.servicesProvider
        )
        
        // Setup navigation closures
        matchDetailsViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create and present the MatchDetailsTextualViewController
        let matchDetailsViewController = MatchDetailsTextualViewController(viewModel: matchDetailsViewModel)
        
        // Present the controller using navigation stack
        navigationController.pushViewController(matchDetailsViewController, animated: true)
        print("🚀 MainCoordinator: Navigated to match detail for match: \(match.id)")
    }
   
    private func showSportsSelector() {
        // Create fresh SportSelectorViewModel on-demand
        let sportSelectorViewModel = PreLiveSportSelectorViewModel()
        let sportsViewController = SportTypeSelectorViewController(viewModel: sportSelectorViewModel)
        
        // Use SportSelectorViewModel callback to get full Sport object
        sportSelectorViewModel.onSportSelected = { [weak self] sport in
            self?.updateCurrentSport(sport)
            sportsViewController.dismiss()
        }
        
        // Handle cancellation - presenter manages navigation
        sportsViewController.onCancel = {
            sportsViewController.dismiss()
        }
        
        // Present modally from navigationController
        sportsViewController.presentModally(from: navigationController)
        print("🚀 MainCoordinator: Presented sports selector modal")
    }
    
    private func showFilters() {
        // Create filters configuration and view model
        let configuration = CombinedFiltersViewController.createMockFilterConfiguration()
        let filtersViewModel = MockCombinedFiltersViewModel(filterConfiguration: configuration, contextId: "sports")
        let combinedFiltersViewController = CombinedFiltersViewController(viewModel: filtersViewModel)
        
        // Handle filter application
        combinedFiltersViewController.onApply = { [weak self] combinedGeneralFilterSelection in
            // Update the current filters in the system
            self?.applyFilters(combinedGeneralFilterSelection)
        }
        
        // Present modally from navigationController
        navigationController.present(combinedFiltersViewController, animated: true)
        print("🚀 MainCoordinator: Presented filters modal")
    }
    
    // MARK: - Helper Methods
    
    private func findMatchById(_ matchId: String) -> Match? {
        // Try to find match in NextUpEvents coordinator first
        if let match = nextUpEventsCoordinator?.findMatch(withId: matchId) {
            return match
        }
        
        // Try to find match in InPlayEvents coordinator
        if let match = inPlayEventsCoordinator?.findMatch(withId: matchId) {
            return match
        }
        
        return nil
    }
    
    private func updateCurrentSport(_ sport: Sport) {
        // Update sport in both coordinators if they exist and are active
        nextUpEventsCoordinator?.updateSport(sport)
        inPlayEventsCoordinator?.updateSport(sport)
        print("🚀 MainCoordinator: Updated current sport to: \(sport.name)")
    }
    
    private func applyFilters(_ filterSelection: GeneralFilterSelection) {
        // Update filters in the current system
        // This would typically update Env.filterStorage or similar
        print("🚀 MainCoordinator: Applied filters: \(filterSelection)")
        
        // Refresh current screens with new filters
        nextUpEventsCoordinator?.refresh()
        inPlayEventsCoordinator?.refresh()
    }
    
    // MARK: - Placeholder methods for other screens (using dummy controllers for now)
    
    private func showMyBetsScreen() {
        let dummyViewController = DummyViewController(displayText: "My Bets")
        rootTabBarViewController?.showMyBetsScreen(with: dummyViewController)
    }
    
    private func showSearchScreen() {
        let dummyViewController = DummyViewController(displayText: "Search")
        rootTabBarViewController?.showSearchScreen(with: dummyViewController)
    }
    
    private func showCasinoHomeScreen() {
        // Lazy loading: only create coordinator when needed
        if casinoCoordinator == nil {
            let coordinator = CasinoCoordinator(
                navigationController: self.navigationController,
                environment: self.environment
            )
            
            // Set up navigation closures
            coordinator.onShowGamePlay = { [weak self] gameId in
                print("🎰 Casino: Game play started for game: \(gameId)")
                // Additional game play handling if needed
            }
            
            casinoCoordinator = coordinator
            addChildCoordinator(coordinator)
            coordinator.start()
        }
        
        // Show the screen through RootTabBarViewController
        if let viewController = casinoCoordinator?.viewController {
            rootTabBarViewController?.showCasinoHomeScreen(with: viewController)
        }
        
        // Refresh if needed
        casinoCoordinator?.refresh()
    }
    
    private func showCasinoVirtualSportsScreen() {
        let dummyViewController = DummyViewController(displayText: "Virtual Sports")
        rootTabBarViewController?.showCasinoVirtualSportsScreen(with: dummyViewController)
    }
    
    private func showCasinoAviatorGameScreen() {
        let dummyViewController = DummyViewController(displayText: "Aviator")
        rootTabBarViewController?.showCasinoAviatorGameScreen(with: dummyViewController)
    }
    
    private func showCasinoSearchScreen() {
        let dummyViewController = DummyViewController(displayText: "Casino Search")
        rootTabBarViewController?.showCasinoSearchScreen(with: dummyViewController)
    }
}
