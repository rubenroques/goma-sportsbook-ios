//
//  CasinoCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import ServicesProvider
import GomaUI
import Combine

class CasinoCoordinator: Coordinator {

    // MARK: - Quick Link Constants
    private enum QuickLinkConstants {
        // Aviator game ID (same across environments)
        static let aviatorGameId = "32430"

        // Category IDs - Production
        static let slotsCategoryIdProduction = "Lobby1$video-slots"
        static let crashCategoryIdProduction = "Lobby1$crash-games"
        static let liteCategoryId = "Lobby1$lite"

        // Category IDs - Staging (different naming convention)
        static let slotsCategoryIdStaging = "Lobby1$videoslots"
        static let crashCategoryIdStaging = "Lobby1$crashgames"
    }

    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Navigation Closures for MainTabBarCoordinator
    var onShowGamePlay: ((String) -> Void) = { _ in }
    var onShowSportsQuickLinkScreen: ((QuickLinkType) -> Void)?
    var onDepositRequested: (() -> Void)?
    var onLoginRequested: (() -> Void)?
    
    // MARK: - Properties
    private let environment: Environment
    private let lobbyType: ServicesProvider.CasinoLobbyType
    private var casinoCategoriesListViewController: CasinoCategoriesListViewController?
    var casinoCategoriesListViewModel: CasinoCategoriesListViewModel?
    private var casinoCategoryGamesListViewController: CasinoCategoryGamesListViewController?
    private var casinoGamePrePlayViewController: CasinoGamePrePlayViewController?
    private var casinoGamePlayViewController: CasinoGamePlayViewController?
    
    // Public accessor for MainTabBarCoordinator
    var viewController: UIViewController? {
        return casinoCategoriesListViewController
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(navigationController: UINavigationController, environment: Environment, lobbyType: ServicesProvider.CasinoLobbyType = .casino) {
        self.navigationController = navigationController
        self.environment = environment
        self.lobbyType = lobbyType
    }
    
    // MARK: - Navigation Methods
    
    func showCategoryGamesList(categoryId: String, categoryTitle: String?) {

        // Create category games list view model
        let categoryGamesViewModel = CasinoCategoryGamesListViewModel(
            categoryId: categoryId,
            categoryTitle: categoryTitle,
            casinoCacheProvider: environment.casinoCacheProvider,
            lobbyType: lobbyType
        )
                
        // Setup navigation closures
        categoryGamesViewModel.onGameSelected = { [weak self] gameId in
            self?.showGamePrePlay(gameId: gameId)
        }
        
        categoryGamesViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        categoryGamesViewModel.onSportsQuickLinkSelected = { [weak self] quickLinkType in
            self?.onShowSportsQuickLinkScreen?(quickLinkType)
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
    
    // MARK: - Quick Link Navigation

    func showAviatorGame() {
        showGamePrePlay(gameId: QuickLinkConstants.aviatorGameId)
    }

    func showSlotsGames() {
        let categoryId = isProduction ? QuickLinkConstants.slotsCategoryIdProduction : QuickLinkConstants.slotsCategoryIdStaging
        showCategoryGamesList(categoryId: categoryId, categoryTitle: nil)
    }

    func showCrashGames() {
        let categoryId = isProduction ? QuickLinkConstants.crashCategoryIdProduction : QuickLinkConstants.crashCategoryIdStaging
        showCategoryGamesList(categoryId: categoryId, categoryTitle: nil)
    }

    func showLiteGames() {
        showCategoryGamesList(categoryId: QuickLinkConstants.liteCategoryId, categoryTitle: nil)
    }

    private var isProduction: Bool {
        return TargetVariables.serviceProviderEnvironment == .prod
    }
    
    func showGamePrePlay(gameId: String) {
        // Create game pre-play view model with proper DI
        let gamePrePlayViewModel = CasinoGamePrePlayViewModel(
            gameId: gameId,
            servicesProvider: environment.servicesProvider,
            userSessionStore: environment.userSessionStore
        )
        
        // Setup navigation closures
        gamePrePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        gamePrePlayViewModel.onLoginRequested = { [weak self] in
            self?.onLoginRequested?()
        }
        
        gamePrePlayViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
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

        guard let casinoGame = casinoGame else { return }
        
        let gamePlayViewModel = CasinoGamePlayViewModel(casinoGame: casinoGame, mode: mode, servicesProvider: environment.servicesProvider)
        
        // Setup navigation closures
        gamePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        gamePlayViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
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
    
    private func checkCasinoQuickLinkSelected(quickLink: QuickLinkType) {
        
        switch quickLink {
        case .aviator:
            self.showAviatorGame()
        case .slots:
            self.showSlotsGames()
        case .crash:
            self.showCrashGames()
        case .lite:
            self.showLiteGames()
        default:
            break
        }
    }

    // MARK: - Coordinator Protocol
    
    func start() {
        // Create view model with injected dependencies
        let viewModel = CasinoCategoriesListViewModel(
            casinoCacheProvider: environment.casinoCacheProvider,
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
        
        viewModel.onCasinoQuickLinkSelected = { [weak self] quickLink in
            self?.checkCasinoQuickLinkSelected(quickLink: quickLink)
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
    
}
