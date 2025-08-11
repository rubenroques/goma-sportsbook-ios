import Foundation
import UIKit

/// Coordinator for the betslip screen
public final class BetslipCoordinator: Coordinator {
    
    // MARK: - Properties
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    // Services (for production ViewModel)
    private let betslipManager: BetslipManager?
    
    // Navigation closures
    public var onCloseBetslip: (() -> Void)?
    public var onShowRegistration: (() -> Void)?
    public var onShowLogin: (() -> Void)?
    public var onBetPlaced: (() -> Void)?
    
    // MARK: - Initialization
    public init(
        navigationController: UINavigationController,
        betslipManager: BetslipManager? = nil
    ) {
        self.navigationController = navigationController
        self.betslipManager = betslipManager
    }
    
    // MARK: - Coordinator
    public func start() {
        // Create appropriate ViewModel based on available services
        let viewModel: BetslipViewModelProtocol
        
        if let betslipManager = betslipManager {
            // Use production ViewModel with real services
            viewModel = BetslipViewModel(betslipManager: betslipManager)
        } else {
            // Use mock ViewModel for testing/preview
            viewModel = MockBetslipViewModel.defaultMock()
        }
        
        let viewController = BetslipViewController(viewModel: viewModel)
        
        // Setup navigation closures in ViewModel
        viewModel.onHeaderCloseTapped = { [weak self] in
            self?.onCloseBetslip?()
        }
        
        viewModel.onHeaderJoinNowTapped = { [weak self] in
            self?.onShowRegistration?()
        }
        
        viewModel.onHeaderLogInTapped = { [weak self] in
            self?.onShowLogin?()
        }
        
        viewModel.onPlaceBetTapped = { [weak self] in
            self?.onBetPlaced?()
        }
        
        // Present the view controller
        navigationController.pushViewController(viewController, animated: true)
    }
    
    public func finish() {
        // Remove from navigation stack
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - Public Methods
    
    /// Update the betslip with ticket information
    public func updateTickets(hasTickets: Bool, count: Int) {
        // In a real implementation, this would update the ViewModel
        // For now, we'll just print the update
        print("BetslipCoordinator: Updated tickets - hasTickets: \(hasTickets), count: \(count)")
    }
    
    /// Refresh the betslip data
    public func refresh() {
        // In a real implementation, this would refresh the ViewModel
        print("BetslipCoordinator: Refreshing betslip data")
    }
} 