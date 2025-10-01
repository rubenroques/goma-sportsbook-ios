//
//  SportsSearchCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Andre on 27/01/2025.
//

import UIKit
import ServicesProvider
import GomaUI

class SportsSearchCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Navigation Closures for RootTabBarCoordinator
    var onShowMatchDetail: ((Match) -> Void) = { _ in }
    var onShowSportsSelector: (() -> Void) = { }
    var onShowFilters: (() -> Void) = { }
    
    // MARK: - Properties
    private let environment: Environment
    private var sportsSearchViewController: SportsSearchViewController?
    private var sportsSearchViewModel: SportsSearchViewModelProtocol?
    
    // Public accessor for RootTabBarCoordinator
    var viewController: UIViewController? {
        return sportsSearchViewController
    }
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Create the view model with dependencies
        let viewModel = SportsSearchViewModel(userSessionStore: environment.userSessionStore)
        
        // Create the view controller
        let viewController = SportsSearchViewController(viewModel: viewModel)
        
        // Store references
        self.sportsSearchViewModel = viewModel
        self.sportsSearchViewController = viewController
        
        print("🔍 SportsSearchCoordinator: Started sports search screen")
    }
    
    func finish() {
        sportsSearchViewController = nil
        sportsSearchViewModel = nil
        childCoordinators.removeAll()
    }
    
    // MARK: - Public Methods for RootTabBarCoordinator
    
    func refresh() {
        // Refresh search results if needed
        print("🔍 SportsSearchCoordinator: Refreshing search screen")
    }
    
    func updateSport(_ sport: Sport) {
        // Update sport filter for search if needed
        print("🔍 SportsSearchCoordinator: Updated sport to: \(sport.name)")
    }
    
    func updateFilters(_ filters: AppliedEventsFilters) {
        // Update search filters if needed
        print("🔍 SportsSearchCoordinator: Updated filters")
    }
    
    func findMatch(withId matchId: String) -> Match? {
        // Find match in search results if available
        // For now, return nil as search doesn't maintain match state
        return nil
    }
}
