
import UIKit
import ServicesProvider
import GomaUI

/// Coordinator for handling bonus screen navigation and presentation
final class BonusCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let servicesProvider: ServicesProvider.Client
    private let displayType: BonusDisplayType
    private var bonusViewController: BonusViewController?
    private var bonusViewModel: BonusViewModel?
    
    private var bonusNavigationController: UINavigationController?

    // MARK: - Navigation Closures
    
    /// Called when bonus screen is dismissed
    var onBonusDismiss: (() -> Void)?
    var onDepositBonusRequested: ((String) -> Void)?
    var onDepositBonusSkipRequested: (() -> Void)?
    
    /// Called when a terms URL needs to be opened
    var onTermsURLRequested: ((String) -> Void)?
    
    /// Called when an internal link needs to be handled
    var onInternalLinkRequested: ((String) -> Void)?
    
    /// Called when deposit transaction completes
    var onDepositComplete: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        navigationController: UINavigationController,
        servicesProvider: ServicesProvider.Client,
        displayType: BonusDisplayType
    ) {
        self.navigationController = navigationController
        self.servicesProvider = servicesProvider
        self.displayType = displayType
    }
    
    // MARK: - Coordinator Implementation
    
    func start() {
        showBonusScreen()
    }
    
    func finish() {
        bonusViewController = nil
        bonusViewModel = nil
        onBonusDismiss?()
        childCoordinators.removeAll()
    }
    
    /// Dismisses the bonus screen and cleans up
    func dismiss() {
        handleBackNavigation()
    }
    
    // MARK: - Private Navigation Methods
    
    private func showBonusScreen() {
        // Create BonusViewModel
        let bonusViewModel = BonusViewModel(
            servicesProvider: servicesProvider,
            displayType: displayType
        )
        self.bonusViewModel = bonusViewModel
        
        // Create BonusViewController
        let bonusViewController = BonusViewController(viewModel: bonusViewModel)
        self.bonusViewController = bonusViewController
        
        let bonusNavigationController = AppCoordinator.navigationController(with: bonusViewController)
        self.bonusNavigationController = bonusNavigationController
        
        // Setup ViewModel callbacks
        bonusViewModel.onNavigateBack = { [weak self] in
            self?.handleBackNavigation()
        }
        
        bonusViewModel.onDepositWithoutBonus = { [weak self] in
            guard let self = self else { return }
            switch self.displayType {
            case .register:
                self.handleBackNavigation()
                self.onDepositBonusSkipRequested?()
            case .history:
                self.handleDepositWithoutBonus()
            }
        }
        
        bonusViewModel.onDepositBonus = { [weak self] bonusCode in
            guard let self = self else { return }
            switch self.displayType {
            case .register:
                self.handleBackNavigation()
                self.onDepositBonusRequested?(bonusCode)
            case .history:
                self.handleDepositBonus(bonusCode: bonusCode)

            }
        }
        
        bonusViewModel.onTermsURLRequested = { [weak self] urlString in
            self?.handleTermsURLRequest(urlString: urlString)
        }
        
        bonusViewModel.onBonusURLOpened = { [weak self] urlString in
            self?.handleBonusURLOpen(urlString: urlString)
        }
        
        // Present the bonus screen
        navigationController.present(bonusNavigationController, animated: true)
        
        print("🎁 BonusCoordinator: Presented bonus screen")
    }
    
    // MARK: - Action Handlers
    
    private func handleBackNavigation() {
        bonusViewController?.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
    
    private func handleDepositWithoutBonus() {
        presentDepositFlow(bonusCode: nil)
    }
    
    private func handleDepositBonus(bonusCode: String) {
        presentDepositFlow(bonusCode: bonusCode)
    }
    
    // MARK: - Banking Flow Methods
    
    private func presentDepositFlow(bonusCode: String?) {
        guard let bonusNavigationController = self.bonusNavigationController else { return }
        
        let bankingCoordinator = BankingCoordinator.forDeposit(
            navigationController: bonusNavigationController,
            client: servicesProvider
        )
        
        bankingCoordinator.bonusCode = bonusCode
        
        // Setup callbacks
        bankingCoordinator.onTransactionComplete = { [weak self] in
            print("🏦 BonusCoordinator: Deposit completed, returning to bonus screen")
            self?.onDepositComplete?()
            self?.removeChildCoordinator(bankingCoordinator)
            // Refresh bonuses after deposit
            self?.refreshBonusData()
            
        }
        
        bankingCoordinator.onTransactionCancel = { [weak self] in
            print("🏦 BonusCoordinator: Deposit cancelled, returning to bonus screen")
            self?.removeChildCoordinator(bankingCoordinator)
            // Refresh bonuses in case anything changed
            self?.refreshBonusData()
            
        }
        
        bankingCoordinator.onTransactionError = { [weak self] error in
            print("🏦 BonusCoordinator: Deposit error: \(error), returning to bonus screen")
            self?.removeChildCoordinator(bankingCoordinator)
            
        }
        
        // Add as child coordinator
        addChildCoordinator(bankingCoordinator)
        
        // Start the deposit flow (presents on navigationController)
        bankingCoordinator.start()
    }
    
    private func refreshBonusData() {
        bonusViewModel?.refreshBonuses()
    }
    
    private func handleTermsURLRequest(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("⚠️ BonusCoordinator: Invalid terms URL")
            return
        }
        
        onTermsURLRequested?(urlString)
        UIApplication.shared.open(url)
    }
    
    private func handleBonusURLOpen(urlString: String?) {
        guard let urlString = urlString else {
            print("⚠️ BonusCoordinator: Invalid bonus URL")
            return
        }
        
        // Check if it's an internal link (betssonem.com)
        if urlString.contains("betssonem.com") {
            print("🔗 BonusCoordinator: Internal link detected: \(urlString)")
            onInternalLinkRequested?(urlString)
            return
        }
        
        // Otherwise, treat as external URL
        guard let url = URL(string: urlString) else {
            print("⚠️ BonusCoordinator: Invalid bonus URL")
            return
        }
        
        UIApplication.shared.open(url)
    }
}

