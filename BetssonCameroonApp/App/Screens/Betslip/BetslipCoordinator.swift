//
//  BetslipCoordinator.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit
import GomaUI

class BetslipCoordinator: Coordinator {
    
    // MARK: - Properties
    private let navigationController: UINavigationController
    private var betslipViewModel: BetslipViewModel?
    public var betslipViewController: BetslipViewController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Coordinator
    func start() {
        let viewModel = BetslipViewModel()
        betslipViewModel = viewModel
        
        let viewController = BetslipViewController(viewModel: viewModel)
        betslipViewController = viewController
        
        // Setup callbacks
        viewModel.onHeaderCloseTapped = { [weak self] in
            self?.handleHeaderCloseTapped()
        }
        
        viewModel.onHeaderJoinNowTapped = { [weak self] in
            self?.handleHeaderJoinNowTapped()
        }
        
        viewModel.onHeaderLogInTapped = { [weak self] in
            self?.handleHeaderLogInTapped()
        }
        
        viewModel.onEmptyStateActionTapped = { [weak self] in
            self?.handleEmptyStateActionTapped()
        }
        
        viewModel.onPlaceBetTapped = { [weak self] in
            self?.handlePlaceBetTapped()
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private Methods
    private func handleHeaderCloseTapped() {
        // TODO: Implement close action
        print("Header close button tapped")
    }
    
    private func handleHeaderJoinNowTapped() {
        // TODO: Implement join now action
        print("Header join now button tapped")
    }
    
    private func handleHeaderLogInTapped() {
        // TODO: Implement log in action
        print("Header log in button tapped")
    }
    
    private func handleEmptyStateActionTapped() {
        // TODO: Implement empty state action
        print("Empty state action button tapped")
    }
    
    private func handlePlaceBetTapped() {
        // TODO: Implement place bet action
        print("Place bet button tapped")
    }
} 