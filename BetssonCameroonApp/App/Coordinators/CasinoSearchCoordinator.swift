//
//  CasinoSearchCoordinator.swift
//  BetssonCameroonApp
//
//  Created on 22/09/2025.
//

import UIKit
import ServicesProvider
import GomaUI
import Combine

final class CasinoSearchCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Navigation Closures for MainTabBarCoordinator
    var onLoginRequested: (() -> Void)?
    var onDepositRequested: (() -> Void)?

    // MARK: - Properties
    private let servicesProvider: ServicesProvider.Client
    private let userSessionStore: UserSessionStore
    private var casinoSearchViewController: CasinoSearchViewController?
    private var casinoSearchViewModel: CasinoSearchViewModelProtocol?
    private var subscriptions = Set<AnyCancellable>()

    // Public accessor for RootTabBarCoordinator
    var viewController: UIViewController? {
        return casinoSearchViewController
    }

    // MARK: - Init
    init(navigationController: UINavigationController, servicesProvider: ServicesProvider.Client, userSessionStore: UserSessionStore) {
        self.navigationController = navigationController
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
    }
    
    // MARK: - Coordinator
    func start() {
        let viewModel = CasinoSearchViewModel(servicesProvider: servicesProvider)
        let viewController = CasinoSearchViewController(viewModel: viewModel)
        
        // Bind navigation intents
        viewModel.onGameSelected
            .sink { [weak self] gameId in
                self?.showGamePrePlay(gameId: gameId)
            }
            .store(in: &subscriptions)
        
        self.casinoSearchViewModel = viewModel
        self.casinoSearchViewController = viewController
        
        print("CasinoSearchCoordinator: Started casino search screen")
    }
    
    func finish() {
        casinoSearchViewController = nil
        casinoSearchViewModel = nil
        childCoordinators.removeAll()
    }
    
    // MARK: - Public Methods
    func refresh() {
        // Placeholder for future refresh logic
    }
}

// MARK: - Private
private extension CasinoSearchCoordinator {
    func showGamePrePlay(gameId: String) {
        // Reuse the flow from CasinoCoordinator by constructing the pre-play screen here
        let gamePrePlayViewModel = CasinoGamePrePlayViewModel(
            gameId: gameId,
            servicesProvider: servicesProvider,
            userSessionStore: userSessionStore
        )

        gamePrePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        gamePrePlayViewModel.onLoginRequested = { [weak self] in
            self?.onLoginRequested?()
        }

        gamePrePlayViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
        }

        gamePrePlayViewModel.onStartGame = { [weak self] (mode: CasinoGamePlayMode, casinoGame: CasinoGame?) in
            guard
                let self = self, let casinoGame = casinoGame
            else {
                return
            }
            
            let viewModel = CasinoGamePlayViewModel(casinoGame: casinoGame, mode: mode, servicesProvider: self.servicesProvider)
            
            let viewController = CasinoGamePlayViewController(viewModel: viewModel)
            self.navigationController.pushViewController(viewController, animated: true)
        }
        
        let prePlayVC = CasinoGamePrePlayViewController(viewModel: gamePrePlayViewModel)
        self.navigationController.pushViewController(prePlayVC, animated: true)
    }
}


