//
//  CasinoCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import ServicesProvider

class CasinoCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Navigation Closures for RootTabBarCoordinator
    var onShowGamePlay: ((String) -> Void) = { _ in }
    
    // MARK: - Properties
    private let environment: Environment
    private var casinoCategoriesListViewController: CasinoCategoriesListViewController?
    private var casinoCategoryGamesListViewController: CasinoCategoryGamesListViewController?
    private var casinoGamePlayViewController: CasinoGamePlayViewController?
    
    // Public accessor for RootTabBarCoordinator
    var viewController: UIViewController? {
        return casinoCategoriesListViewController
    }
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Navigation Methods
    
    private func showCategoryGamesList(categoryId: String, categoryTitle: String) {
        
        // Create category games list view model
        let categoryGamesViewModel = CasinoCategoryGamesListViewModel(
            categoryId: categoryId,
            categoryTitle: categoryTitle,
            servicesProvider: environment.servicesProvider
        )
        
        // Setup navigation closures
        categoryGamesViewModel.onGameSelected = { [weak self] gameId in
            self?.showGamePlay(gameId: gameId)
        }
        
        categoryGamesViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create view controller
        let categoryGamesViewController = CasinoCategoryGamesListViewController(viewModel: categoryGamesViewModel)
        self.casinoCategoryGamesListViewController = categoryGamesViewController
        
        // Navigate using the existing navigation controller
        self.navigationController.pushViewController(categoryGamesViewController, animated: true)
    }
    
    private func showGamePlay(gameId: String) {
        // Create game play view model
        let gamePlayViewModel = CasinoGamePlayViewModel(
            gameId: gameId,
            servicesProvider: environment.servicesProvider
        )
        
        // Setup navigation closures
        gamePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create view controller
        let gamePlayViewController = CasinoGamePlayViewController(viewModel: gamePlayViewModel)
        self.casinoGamePlayViewController = gamePlayViewController
        
        // Navigate using the existing navigation controller
        self.navigationController.pushViewController(gamePlayViewController, animated: true)
        
        // Notify RootTabBarCoordinator if needed
        onShowGamePlay(gameId)
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        // Create view model with injected dependencies
        let viewModel = CasinoCategoriesListViewModel(
            servicesProvider: environment.servicesProvider
        )
        
        // Setup MVVM-C navigation closures - ViewModels signal navigation intent
        viewModel.onCategorySelected = { [weak self] categoryId, categoryTitle in
            self?.showCategoryGamesList(categoryId: categoryId, categoryTitle: categoryTitle)
        }
        
        // Create view controller
        let viewController = CasinoCategoriesListViewController(viewModel: viewModel)
        self.casinoCategoriesListViewController = viewController
        
        // RootTabBarCoordinator will handle embedding
    }
    
    func finish() {
        childCoordinators.removeAll()
        casinoCategoriesListViewController = nil
        casinoCategoryGamesListViewController = nil
        casinoGamePlayViewController = nil
    }
    
    // MARK: - Public Methods for RootTabBarCoordinator
    func refresh() {
        casinoCategoriesListViewController?.viewModel.reloadCategories()
    }
}
