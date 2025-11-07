//
//  ResponsibleGamingCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Claude on November 6, 2025.
//

import UIKit
import ServicesProvider
import GomaUI

/// Coordinator for handling responsible gaming screen navigation and presentation
final class ResponsibleGamingCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let servicesProvider: ServicesProvider.Client
    private var responsibleGamingViewController: ResponsibleGamingViewController?
    private var responsibleGamingViewModel: ResponsibleGamingViewModel?
    
    private var responsibleGamingNavigationController: UINavigationController?

    // MARK: - Navigation Closures
    
    /// Called when responsible gaming screen is dismissed
    var onDismiss: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        navigationController: UINavigationController,
        servicesProvider: ServicesProvider.Client
    ) {
        self.navigationController = navigationController
        self.servicesProvider = servicesProvider
    }
    
    // MARK: - Coordinator Implementation
    
    func start() {
        showResponsibleGamingScreen()
    }
    
    func finish() {
        responsibleGamingViewController = nil
        responsibleGamingViewModel = nil
        onDismiss?()
        childCoordinators.removeAll()
    }
    
    // MARK: - Private Navigation Methods
    
    private func showResponsibleGamingScreen() {
        // Create ResponsibleGamingViewModel
        let responsibleGamingViewModel = ResponsibleGamingViewModel(
            servicesProvider: servicesProvider
        )
        self.responsibleGamingViewModel = responsibleGamingViewModel
        
        // Create ResponsibleGamingViewController
        let responsibleGamingViewController = ResponsibleGamingViewController(viewModel: responsibleGamingViewModel)
        self.responsibleGamingViewController = responsibleGamingViewController
        
//        let responsibleGamingNavigationController = Router.navigationController(with: responsibleGamingViewController)
//        self.responsibleGamingNavigationController = responsibleGamingNavigationController
        
        // Setup ViewModel callbacks
        responsibleGamingViewModel.onNavigateBack = { [weak self] in
            self?.handleBackNavigation()
        }
        
        // Present the responsible gaming screen
        navigationController.pushViewController(responsibleGamingViewController, animated: true)
        
        print("🎯 ResponsibleGamingCoordinator: Presented responsible gaming screen")
    }
    
    // MARK: - Action Handlers
    
    private func handleBackNavigation() {
        navigationController.popViewController(animated: true)
        finish()
    }
}

