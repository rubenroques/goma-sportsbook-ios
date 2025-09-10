//
//  ProfileWalletCoordinator.swift  
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import UIKit
import ServicesProvider
import GomaUI

// Removed ProfileWalletCoordinatorDelegate - using closure-based pattern for consistency with other coordinators

final class ProfileWalletCoordinator: Coordinator {
    
    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let servicesProvider: ServicesProvider.Client
    private let userSessionStore: UserSessionStore
    private var profileViewController: ProfileWalletViewController?
    
    private var profileNavigationController: UINavigationController?
    
    // MARK: - Navigation Closures (following app's closure-based pattern)
    
    var onProfileDismiss: (() -> Void)?
    var onDepositRequested: (() -> Void)?
    var onWithdrawRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        navigationController: UINavigationController,
        servicesProvider: ServicesProvider.Client,
        userSessionStore: UserSessionStore
    ) {
        self.navigationController = navigationController
        self.servicesProvider = servicesProvider
        self.userSessionStore = userSessionStore
    }
    
    // MARK: - Coordinator Implementation
    
    func start() {
        showProfileWallet()
    }
    
    func finish() {
        profileViewController = nil
        profileNavigationController = nil
        onProfileDismiss?()
        childCoordinators.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func showProfileWallet() {
        let viewModel = createProfileWalletViewModel()
        let profileViewController = ProfileWalletViewController(viewModel: viewModel)
        
        // Setup ViewModel callbacks
        setupViewModelCallbacks(viewModel)
        
        // Create dedicated NavigationController with hidden navigation bar (following Router pattern)
        let profileNavigationController = Router.navigationController(with: profileViewController)
        
        // Configure modal presentation on the NavigationController
        profileNavigationController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            profileNavigationController.sheetPresentationController?.detents = [.large()]
            profileNavigationController.sheetPresentationController?.prefersGrabberVisible = false
        }
        
        // Store references
        self.profileViewController = profileViewController
        self.profileNavigationController = profileNavigationController
        
        // Present the NavigationController modally (not the bare view controller)
        navigationController.present(profileNavigationController, animated: true)
    }
    
    private func createProfileWalletViewModel() -> ProfileWalletViewModel {
        return ProfileWalletViewModel(servicesProvider: servicesProvider, userSessionStore: userSessionStore)
    }
    
    private func setupViewModelCallbacks(_ viewModel: ProfileWalletViewModel) {
        // Dismiss callback
        viewModel.onDismiss = { [weak self] in
            self?.dismissProfileWallet()
        }
        
        // Deposit callback
        viewModel.onDepositRequested = { [weak self] in
            self?.presentDepositFlow()
        }
        
        // Withdraw callback
        viewModel.onWithdrawRequested = { [weak self] in
            self?.presentWithdrawFlow()
        }
        
        // Menu item selection callback
        viewModel.onMenuItemSelected = { [weak self] menuItem in
            guard let self = self else { return }
            self.handleMenuItemSelection(menuItem)
        }
    }
    
    private func handleMenuItemSelection(_ menuItem: ProfileMenuItem) {
        switch menuItem.action {
        case .logout:
            // Handle logout with confirmation
            showLogoutConfirmation()
        case .notifications:
            // Handle notifications internally - present from profile's modal context
            showNotifications()
        case .transactionHistory:
            // TODO: Navigate to transaction history
            showPlaceholderAlert(title: "Transaction History", message: "Feature coming soon")
        case .changeLanguage:
            // Show language selection
            showLanguageSelection()
        case .responsibleGaming:
            // TODO: Navigate to responsible gaming
            showPlaceholderAlert(title: "Responsible Gaming", message: "Feature coming soon")
        case .helpCenter:
            // TODO: Navigate to help center
            showPlaceholderAlert(title: "Help Center", message: "Feature coming soon")
        case .changePassword:
            // TODO: Navigate to change password
            showPlaceholderAlert(title: "Change Password", message: "Feature coming soon")
        }
    }
    
    private func showLogoutConfirmation() {
        guard let profileViewController = profileViewController else { return }
        
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        profileViewController.present(alert, animated: true)
    }
    
    private func showLanguageSelection() {
        guard let profileViewController = profileViewController else { return }
        
        let alert = UIAlertController(
            title: "Select Language",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        // Add language options
        let languages = ["English", "Français", "Español"]
        
        for language in languages {
            let action = UIAlertAction(title: language, style: .default) { _ in
                print("Selected language: \(language)")
                // Update language preference
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        // Configure for iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = profileViewController.view
            popover.sourceRect = CGRect(
                x: profileViewController.view.bounds.midX,
                y: profileViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
        }
        
        profileViewController.present(alert, animated: true)
    }
    
    private func showNotifications() {
        guard let profileNavigationController = profileNavigationController else {
            print("❌ ProfileWalletCoordinator: Profile navigation controller not available")
            return
        }
        
        // Create NotificationsCoordinator using profile's NavigationController
        let notificationsCoordinator = NotificationsCoordinator(
            navigationController: profileNavigationController,
            servicesProvider: servicesProvider
        )
        
        // Setup closure-based callbacks
        notificationsCoordinator.onDismiss = { [weak self] in
            self?.removeChildCoordinator(notificationsCoordinator)
        }
        
        notificationsCoordinator.onNotificationAction = { notification, action in
            print("ProfileWalletCoordinator: Notification action - \(action.title) for '\(notification.title)'")
            // Handle notification actions that need additional navigation
        }
        
        addChildCoordinator(notificationsCoordinator)
        notificationsCoordinator.start()
        
        print("🚀 ProfileWalletCoordinator: Presented notifications from profile modal context")
    }
    
    private func showPlaceholderAlert(title: String, message: String) {
        guard let profileViewController = profileViewController else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        profileViewController.present(alert, animated: true)
    }
    
    private func performLogout() {
        // Dismiss profile first, then handle logout
        dismissProfileWallet { [weak self] in
            // Perform actual logout through UserSessionStore
            self?.userSessionStore.logout()
            print("✅ ProfileWalletCoordinator: User logged out successfully")
        }
    }
    
    private func dismissProfileWallet(completion: (() -> Void)? = nil) {
        // Dismiss the NavigationController (not the bare view controller)
        profileNavigationController?.dismiss(animated: true) { [weak self] in
            completion?()
            self?.finish()
        }
    }
    
    // MARK: - Banking Flow Methods
    
    private func presentDepositFlow() {
        guard let presentingViewController = profileNavigationController else { return }
        
        let bankingCoordinator = BankingCoordinator.forDeposit(
            presentingViewController: presentingViewController,
            client: servicesProvider,
            isFirstDeposit: checkIfFirstDeposit()
        )
        
        // Set up banking coordinator closures
        setupBankingCoordinatorCallbacks(bankingCoordinator)
        
        // Add as child coordinator
        addChildCoordinator(bankingCoordinator)
        
        // Start the banking flow
        bankingCoordinator.start()
    }
    
    private func presentWithdrawFlow() {
        guard let presentingViewController = profileNavigationController else { return }
        
        let bankingCoordinator = BankingCoordinator.forWithdraw(
            presentingViewController: presentingViewController,
            client: servicesProvider
        )
        
        // Set up banking coordinator closures
        setupBankingCoordinatorCallbacks(bankingCoordinator)
        
        // Add as child coordinator
        addChildCoordinator(bankingCoordinator)
        
        // Start the banking flow
        bankingCoordinator.start()
    }
    
    private func checkIfFirstDeposit() -> Bool {
        // TODO: In a real implementation, check user's transaction history
        // For now, return false as a default
        return false
    }
    
    // MARK: - Banking Coordinator Setup
    
    private func setupBankingCoordinatorCallbacks(_ coordinator: BankingCoordinator) {
        // Transaction completion callback
        coordinator.onTransactionComplete = { [weak self] transactionType, amount in
            guard let self = self else { return }
            
            // Transaction completed successfully
            print("[ProfileWallet] Banking transaction completed: \(transactionType.displayName)")
            
            // Update wallet data to reflect the transaction
            self.userSessionStore.refreshUserWallet()
            
            // Remove child coordinator
            self.removeChildCoordinator(coordinator)
            
            // Optionally call external callback for further handling
            if transactionType == .deposit {
                self.onDepositRequested?()
            } else {
                self.onWithdrawRequested?()
            }
        }
        
        // Transaction cancellation callback
        coordinator.onTransactionCancel = { [weak self] in
            guard let self = self else { return }
            
            print("[ProfileWallet] Banking transaction cancelled")
            self.removeChildCoordinator(coordinator)
        }
        
        // Transaction error callback
        coordinator.onTransactionError = { [weak self] error in
            guard let self = self else { return }
            
            print("[ProfileWallet] Banking transaction failed: \(error)")
            self.removeChildCoordinator(coordinator)
            
            // Show error to user
            self.showTransactionErrorAlert(error: error)
        }
        
        // Navigation action callback
        coordinator.onNavigationAction = { [weak self] action in
            guard let self = self else { return }
            
            // Handle navigation actions from banking flow
            switch action {
            case .goToSports:
                // Dismiss profile and navigate to sports
                self.dismissProfileWallet()
                // Note: The parent coordinator should handle sports navigation
                
            case .goToCasino:
                // Dismiss profile and navigate to casino
                self.dismissProfileWallet()
                // Note: The parent coordinator should handle casino navigation
                
            case .closeModal, .none:
                // Just remove the banking coordinator
                self.removeChildCoordinator(coordinator)
            }
        }
    }
    
    private func showTransactionErrorAlert(error: String) {
        guard let presentingViewController = profileNavigationController else { return }
        
        let alert = UIAlertController(
            title: "Transaction Error",
            message: error,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        presentingViewController.present(alert, animated: true)
    }
}

// MARK: - Factory Methods

extension ProfileWalletCoordinator {
    
    /// Creates and presents a ProfileWalletCoordinator
    static func present(
        from navigationController: UINavigationController,
        servicesProvider: ServicesProvider.Client,
        userSessionStore: UserSessionStore
    ) -> ProfileWalletCoordinator {
        let coordinator = ProfileWalletCoordinator(
            navigationController: navigationController,
            servicesProvider: servicesProvider,
            userSessionStore: userSessionStore
        )
        
        coordinator.start()
        return coordinator
    }
}
