import Foundation
import UIKit

/// Coordinator for the betslip screen
class BetslipCoordinator: Coordinator {
    
    // MARK: - Properties
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    // Services (for production ViewModel)
    private let environment: Environment
    
    // View model and view controller references
    private var betslipViewModel: BetslipViewModel?
    public var betslipViewController: BetslipViewController?
    
    // Navigation closures
    public var onCloseBetslip: (() -> Void)?
    public var onShowRegistration: (() -> Void)?
    public var onShowLogin: (() -> Void)?
    public var onEmptyStateAction: (() -> Void)?
    public var onBetPlaced: (() -> Void)?
    
    // MARK: - Initialization
    public init(
        navigationController: UINavigationController,
        environment: Environment
    ) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator
    public func start() {
        // Create appropriate ViewModel based on available services
        var viewModel: BetslipViewModelProtocol

        let betslipViewModel = BetslipViewModel()
        viewModel = betslipViewModel
        
        self.betslipViewModel = betslipViewModel
                
        // Setup navigation closures in ViewModel
        viewModel.onHeaderCloseTapped = { [weak self] in
            self?.finish()
            self?.onCloseBetslip?()
        }
        
        viewModel.onHeaderJoinNowTapped = { [weak self] in
            self?.onShowRegistration?()
        }
        
        viewModel.onHeaderLogInTapped = { [weak self] in
            self?.onShowLogin?()
        }
        
        viewModel.onEmptyStateActionTapped = { [weak self] in
            self?.onEmptyStateAction?()
        }
        
        viewModel.onPlaceBetTapped = { [weak self] in
            self?.onBetPlaced?()
        }
        
        let viewController = BetslipViewController(viewModel: viewModel)
        self.betslipViewController = viewController

    }
    
    public func finish() {
        childCoordinators.removeAll()
        betslipViewController = nil
        betslipViewModel = nil
    }
    
    // MARK: - Public Methods
    
    /// Update the betslip with actual ticket data
    public func updateTickets(_ tickets: [BettingTicket]) {
        betslipViewModel?.updateTickets(tickets)
    }
    
    /// Refresh the betslip data
    public func refresh() {
        // In a real implementation, this would refresh the ViewModel
        print("BetslipCoordinator: Refreshing betslip data")
    }
} 
