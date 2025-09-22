//
//  CasinoSearchCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 22/09/2025.
//

import UIKit
import ServicesProvider
import GomaUI
import Combine

final class CasinoSearchCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    private let environment: Environment
    private var casinoSearchViewController: CasinoSearchViewController?
    private var casinoSearchViewModel: CasinoSearchViewModelProtocol?
    private var subscriptions = Set<AnyCancellable>()
    
    // Public accessor for RootTabBarCoordinator
    var viewController: UIViewController? {
        return casinoSearchViewController
    }
    
    // MARK: - Init
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator
    func start() {
        let viewModel = CasinoSearchViewModel(servicesProvider: environment.servicesProvider)
        let viewController = CasinoSearchViewController(viewModel: viewModel)
        
        // Bind navigation intents
        viewModel.onGameSelected
            .sink { [weak self] gameId in
                self?.showGamePrePlay(gameId: gameId)
            }
            .store(in: &subscriptions)
        
        self.casinoSearchViewModel = viewModel
        self.casinoSearchViewController = viewController
        
        print("🔎 CasinoSearchCoordinator: Started casino search screen")
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
            servicesProvider: environment.servicesProvider
        )
        
        gamePrePlayViewModel.onNavigateBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        gamePrePlayViewModel.onLoginRequested = { [weak self] in
            print("CasinoSearchCoordinator: Login requested")
        }
        
        gamePrePlayViewModel.onDepositRequested = { [weak self] in
            print("CasinoSearchCoordinator: Deposit requested")
        }
        
        gamePrePlayViewModel.onStartGame = { [weak self] mode, casinoGame in
            let vm: CasinoGamePlayViewModel
            if let casinoGame = casinoGame {
                vm = CasinoGamePlayViewModel(casinoGame: casinoGame, servicesProvider: self?.environment.servicesProvider ?? Env.servicesProvider)
            } else {
                vm = CasinoGamePlayViewModel(gameId: gameId, servicesProvider: self?.environment.servicesProvider ?? Env.servicesProvider)
            }
            let vc = CasinoGamePlayViewController(viewModel: vm)
            self?.navigationController.pushViewController(vc, animated: true)
        }
        
        let prePlayVC = CasinoGamePrePlayViewController(viewModel: gamePrePlayViewModel)
        self.navigationController.pushViewController(prePlayVC, animated: true)
    }
}


