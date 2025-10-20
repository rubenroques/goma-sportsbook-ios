//
//  CasinoCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import ServicesProvider
import GomaUI

class CasinoCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Navigation Closures for MainTabBarCoordinator
    var onShowGamePlay: ((String) -> Void) = { _ in }
    var onShowSportsQuickLinkScreen: ((QuickLinkType) -> Void)?
    
    // MARK: - Properties
    private let environment: Environment
    private let lobbyType: CasinoLobbyType
    private var casinoCategoriesListViewController: CasinoCategoriesListViewController?
    var casinoCategoriesListViewModel: CasinoCategoriesListViewModel?
    private var casinoCategoryGamesListViewController: CasinoCategoryGamesListViewController?
    private var casinoGamePrePlayViewController: CasinoGamePrePlayViewController?
    private var casinoGamePlayViewController: CasinoGamePlayViewController?
    
    // Public accessor for MainTabBarCoordinator
    var viewController: UIViewController? {
        return casinoCategoriesListViewController
    }
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, environment: Environment, lobbyType: CasinoLobbyType = .casino) {
        self.navigationController = navigationController
        self.environment = environment
        self.lobbyType = lobbyType
    }
    
    // MARK: - Navigation Methods
    
    func showCategoryGamesList(categoryId: String, categoryTitle: String) {
        
        // Create category games list view model
        let categoryGamesViewModel = CasinoCategoryGamesListViewModel(
            categoryId: categoryId,
            categoryTitle: categoryTitle,
            servicesProvider: environment.servicesProvider,
            lobbyType: lobbyType.serviceProviderType
        )
                
        // Setup navigation closures
        categoryGamesViewModel.onGameSelected = { [weak self] gameId in
            self?.showGamePrePlay(gameId: gameId)
        }
        
        categoryGamesViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create the clean CasinoCategoryGamesListViewController (no top bar code)
        let categoryGamesViewController = CasinoCategoryGamesListViewController(viewModel: categoryGamesViewModel)
        self.casinoCategoryGamesListViewController = categoryGamesViewController

        // Create TopBar ViewModel
        let topBarViewModel = TopBarContainerViewModel(
            userSessionStore: environment.userSessionStore
        )

        // Wrap in TopBarContainerController
        let container = TopBarContainerController(
            contentViewController: categoryGamesViewController,
            viewModel: topBarViewModel
        )

        // Casino screens typically don't need authentication callbacks
        // (users can interact with casino content without being logged in)

        // Navigate using the existing navigation controller
        self.navigationController.pushViewController(container, animated: true)
    }
    
    func showAviatorGame() {
        
        let aviatorGame = casinoCategoriesListViewModel?.categorySections
            .flatMap { $0.sectionData.games }
            .first(where: { $0.name == "Aviator" })
        
        if let aviatorGameId = aviatorGame?.id {
            self.showGamePrePlay(gameId: aviatorGameId)
        }
    }
    
    func showGamePrePlay(gameId: String) {
        // Create game pre-play view model
        let gamePrePlayViewModel = CasinoGamePrePlayViewModel(
            gameId: gameId,
            servicesProvider: environment.servicesProvider
        )
        
        // Setup navigation closures
        gamePrePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        gamePrePlayViewModel.onLoginRequested = { [weak self] in
            // TODO: Navigate to login screen
            print("CasinoCoordinator: Login requested")
        }
        
        gamePrePlayViewModel.onDepositRequested = { [weak self] in
            // TODO: Navigate to deposit screen
            print("CasinoCoordinator: Deposit requested") 
        }
        
        gamePrePlayViewModel.onStartGame = { [weak self] mode, casinoGame in
            switch mode {
            case .practice:
                self?.showGamePlay(gameId: gameId, casinoGame: casinoGame, mode: .practice)
            case .realMoney:
                self?.showGamePlay(gameId: gameId, casinoGame: casinoGame, mode: .realMoney)
            }
        }
        
        // Create view controller
        let gamePrePlayViewController = CasinoGamePrePlayViewController(viewModel: gamePrePlayViewModel)
        self.casinoGamePrePlayViewController = gamePrePlayViewController
        
        // Navigate using the existing navigation controller
        self.navigationController.pushViewController(gamePrePlayViewController, animated: true)
    }
    
    private func showGamePlay(gameId: String, casinoGame: CasinoGame?, mode: CasinoGamePlayMode) {
        // Create game play view model with CasinoGame object if available
        let gamePlayViewModel: CasinoGamePlayViewModel
        if let casinoGame = casinoGame {
            gamePlayViewModel = CasinoGamePlayViewModel(casinoGame: casinoGame, servicesProvider: environment.servicesProvider)
        } else {
            // Fallback to gameId-based initialization
            gamePlayViewModel = CasinoGamePlayViewModel(gameId: gameId, servicesProvider: environment.servicesProvider)
        }
        
        // Setup navigation closures
        gamePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        // Create view controller
        let gamePlayViewController = CasinoGamePlayViewController(viewModel: gamePlayViewModel)
        self.casinoGamePlayViewController = gamePlayViewController
        
        // Navigate using the existing navigation controller
        self.navigationController.pushViewController(gamePlayViewController, animated: true)
        
        // Notify MainTabBarCoordinator if needed
        onShowGamePlay(gameId)
    }

    private func openExternalURL(url: String) {
        guard let url = URL(string: url) else {
            print("CasinoCoordinator: Invalid URL: \(url)")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if !success {
                    print("CasinoCoordinator: Failed to open URL: \(url)")
                }
            }
        } else {
            print("CasinoCoordinator: Cannot open URL: \(url)")
        }
    }

    // MARK: - Coordinator Protocol
    
    func start() {
        // Create view model with injected dependencies
        let viewModel = CasinoCategoriesListViewModel(
            servicesProvider: environment.servicesProvider,
            lobbyType: lobbyType
        )
        
        self.casinoCategoriesListViewModel = viewModel
        
        // Setup MVVM-C navigation closures - ViewModels signal navigation intent
        viewModel.onCategorySelected = { [weak self] categoryId, categoryTitle in
            self?.showCategoryGamesList(categoryId: categoryId, categoryTitle: categoryTitle)
        }

        viewModel.onGameSelected = { [weak self] gameId in
            self?.showGamePrePlay(gameId: gameId)
        }

        // Banner navigation closures
        viewModel.onBannerGameSelected = { [weak self] gameId in
            self?.showGamePrePlay(gameId: gameId)
        }

        viewModel.onBannerURLSelected = { [weak self] url in
            self?.openExternalURL(url: url)
        }
        
        viewModel.onSportsQuickLinkSelected = { [weak self] quickLink in
            self?.onShowSportsQuickLinkScreen?(quickLink)
        }
        
        // Create view controller
        let viewController = CasinoCategoriesListViewController(viewModel: viewModel)
        self.casinoCategoriesListViewController = viewController
        
        // MainTabBarCoordinator will handle embedding
    }
    
    func finish() {
        childCoordinators.removeAll()
        casinoCategoriesListViewController = nil
        casinoCategoryGamesListViewController = nil
        casinoGamePrePlayViewController = nil
        casinoGamePlayViewController = nil
    }
    
    // MARK: - Public Methods for MainTabBarCoordinator
    func refresh() {
        casinoCategoriesListViewController?.viewModel.reloadCategories()
    }
    
    // MARK: - QuickLinks Deep Navigation
    
    /// Navigate to specific casino category based on QuickLinkType
    func navigateToGameCategory(type: QuickLinkType) {
        print("🎰 CasinoCoordinator: Navigating to game category - \(type.rawValue)")
        
        // Map QuickLinkType to casino category IDs and actions
        switch type {
        case .aviator:
            // Navigate directly to Aviator game
            navigateToSpecificGame(gameId: "aviator", categoryId: "crash", categoryTitle: "Crash Games")
            
        case .virtual:
            // Navigate to Virtual Sports category
            showCategoryGamesList(categoryId: "virtual", categoryTitle: "Virtual Sports")
            
        case .slots:
            // Navigate to Slots category
            showCategoryGamesList(categoryId: "slots", categoryTitle: "Slots")
            
        case .crash:
            // Navigate to Crash Games category
            showCategoryGamesList(categoryId: "crash", categoryTitle: "Crash Games")
            
        case .promos:
            // For promotions, we could show a promotions-filtered view
            // For now, just show the main casino screen with a log
            print("🎰 CasinoCoordinator: Promotions not implemented - showing main casino")
            
        default:
            // For non-casino QuickLinks, just show main casino
            print("🎰 CasinoCoordinator: Non-casino QuickLink - showing main casino")
        }
    }
    
    private func navigateToSpecificGame(gameId: String, categoryId: String, categoryTitle: String) {
        // First navigate to category, then to specific game
        showCategoryGamesList(categoryId: categoryId, categoryTitle: categoryTitle)
        
        // After a brief delay, navigate to the specific game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showGamePrePlay(gameId: gameId)
        }
    }
}
