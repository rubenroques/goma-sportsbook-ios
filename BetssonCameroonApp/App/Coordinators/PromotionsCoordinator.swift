//
//  PromotionsCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import UIKit
import ServicesProvider
import GomaUI

/// Coordinator for handling promotions screen navigation and presentation
/// Follows MVVM-C pattern where coordinator handles navigation logic only
final class PromotionsCoordinator: Coordinator, PromotionsCoordinatorProtocol {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let environment: Environment
    private var promotionsViewController: PromotionsViewController?
    
    // MARK: - Callbacks for TopBar Container Actions
    
    /// Called when login is requested from TopBar container
    var onLoginRequested: (() -> Void)?
    
    /// Called when registration is requested from TopBar container
    var onRegistrationRequested: (() -> Void)?
    
    /// Called when profile is requested from TopBar container
    var onProfileRequested: (() -> Void)?
    
    /// Called when deposit is requested from TopBar container
    var onDepositRequested: (() -> Void)?
    
    /// Called when withdraw is requested from TopBar container
    var onWithdrawRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Initialize promotions coordinator
    /// - Parameters:
    ///   - navigationController: Navigation controller to use for navigation
    ///   - environment: Environment containing services and dependencies
    init(
        navigationController: UINavigationController,
        environment: Environment
    ) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Implementation
    
    func start() {
        showPromotionsScreen()
    }
    
    func finish() {
        // Clean up any child coordinators
        childCoordinators.removeAll()
    }
    
    // MARK: - Navigation Methods
    
    /// Shows the main promotions screen
    private func showPromotionsScreen() {
        // Create PromotionsViewModel
        let promotionsViewModel = PromotionsViewModel(servicesProvider: environment.servicesProvider)
        
        // Create PromotionsViewController
        let promotionsViewController = PromotionsViewController(
            viewModel: promotionsViewModel
        )
        
        // Store reference for potential cleanup
        self.promotionsViewController = promotionsViewController
        
        // Setup ViewModel callbacks
        promotionsViewModel.onDismiss = { [weak self] in
            self?.handleBackNavigation()
        }
        
        promotionsViewModel.onPromotionDetailRequested = { [weak self] promotion in
            self?.showPromotionDetail(promotion: promotion)
        }
        
        promotionsViewModel.onPromotionURLRequested = { [weak self] urlString in
            self?.openPromotionURL(urlString: urlString)
        }
        
        // Create TopBar ViewModel (handles all business logic)
        let topBarViewModel = TopBarContainerViewModel(
            userSessionStore: environment.userSessionStore
        )

        // Wrap in TopBarContainerController
        let container = TopBarContainerController(
            contentViewController: promotionsViewController,
            viewModel: topBarViewModel
        )

        // Setup navigation callbacks on container - delegate to parent coordinator
        container.onLoginRequested = { [weak self] in
            self?.onLoginRequested?()
        }

        container.onRegistrationRequested = { [weak self] in
            self?.onRegistrationRequested?()
        }

        container.onProfileRequested = { [weak self] in
            self?.onProfileRequested?()
        }

        container.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
        }

        container.onWithdrawRequested = { [weak self] in
            self?.onWithdrawRequested?()
        }
        
        // Push the container using navigation stack
        navigationController.pushViewController(container, animated: true)
        
        print("🚀 PromotionsCoordinator: Presented promotions screen")
    }
    
    /// Shows promotion detail screen
    /// - Parameter promotion: The promotion to show details for
    func showPromotionDetail(promotion: PromotionInfo) {
        let promotionDetailViewModel = PromotionDetailViewModel(
            promotion: promotion,
            servicesProvider: environment.servicesProvider
        )
        
        // Setup ViewModel callback for back navigation
        promotionDetailViewModel.onDismiss = { [weak self] in
            self?.handleDetailBackNavigation()
        }
        
        let promotionDetailViewController = PromotionDetailViewController(
            viewModel: promotionDetailViewModel
        )
        
        navigationController.pushViewController(promotionDetailViewController, animated: true)
        
        print("🚀 PromotionsCoordinator: Presented promotion detail for: \(promotion.title)")
    }
    
    /// Opens a promotion URL in external browser
    /// - Parameter urlString: The URL string to open
    func openPromotionURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ PromotionsCoordinator: Invalid URL: \(urlString)")
            return
        }
        
        UIApplication.shared.open(url)
        print("🚀 PromotionsCoordinator: Opened external URL: \(urlString)")
    }
    
    /// Handles back navigation from promotions screen
    private func handleBackNavigation() {
        navigationController.popViewController(animated: true)
        print("🚀 PromotionsCoordinator: Handled back navigation")
    }
    
    /// Handles back navigation from promotion detail screen
    func handleDetailBackNavigation() {
        navigationController.popViewController(animated: true)
        print("🚀 PromotionsCoordinator: Handled detail back navigation")
    }
    
}
