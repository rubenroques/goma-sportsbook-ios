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
//            self?.onEmptyStateAction?()
            self?.onShowLogin?()
        }
        
        viewModel.onPlaceBetTapped = { [weak self] betPlacedState in
            switch betPlacedState {
            case .success:
                self?.showBetslipSuccessScreen()
            case .error(let message):
                self?.showBetslipErrorAlert(message: message)
            }
            
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
    public func showBetslipSuccessScreen() {
        
        // Clear betslip
        Env.betslipManager.clearAllBettingTickets()
        
        let betSuccessViewModel = BetSuccessViewModel()
        
        let betSuccessViewController = BetSuccessViewController(viewModel: betSuccessViewModel)
        
        self.betslipViewController?.present(betSuccessViewController, animated: true)
        
        betSuccessViewController.onContinueRequested = { [weak self] in
            self?.finish()
            self?.onCloseBetslip?()
        }
    }
    
    public func showBetslipErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Bet Placement Error",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        
        alert.addAction(okAction)
        
        // Present the alert from the betslip view controller
        betslipViewController?.present(alert, animated: true)
    }
    
//    public func showBetslipSuccessScreen() {
//        
//        let betSuccessViewModel = MockDepositBonusSuccessViewModel(bonusDepositData: BonusDepositData(id: "", selectedAmount: 0.0, bonusAmount: 1.0))
//        
//        let betSuccessViewController = DepositBonusSuccessViewController(viewModel: betSuccessViewModel)
//        
//        self.betslipViewController?.present(betSuccessViewController, animated: true)
//        
//        betSuccessViewController.onContinueRequested = { [weak self] in
//            self?.finish()
//            self?.onCloseBetslip?()
//        }
//    }
}
