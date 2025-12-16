//
//  ProfileWalletCoordinator.swift  
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import UIKit
import ServicesProvider
import GomaUI
import XPush
import Combine
import GomaLogger

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
    
    var cancellables = Set<AnyCancellable>()
    
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
        let profileNavigationController = AppCoordinator.navigationController(with: profileViewController)
        
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
        viewModel.onMenuItemSelected = { [weak self] menuItem, actionResponse in
            guard let self = self else { return }
            self.handleMenuItemSelection(menuItem, actionResponse)
        }
        
        viewModel.showErrorAlert = { [weak self] error in
            self?.showChangePasswordErrorAlert(error: error)
        }
    }
    
    private func handleMenuItemSelection(_ menuItem: ActionRowItem, _ actionResponse: String? = nil) {
        switch menuItem.action {
        case .logout:
            // Handle logout with confirmation
            showLogoutConfirmation()
        case .notifications:
            // Open XPush inbox screen to view notifications
            XPush.forceOpenInbox()
        case .notificationSettings:
            // Open iPhone Settings app directly to notification settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        case .transactionHistory:
            // Navigate to transaction history
            showTransactionHistory()
        case .changeLanguage:
            // Show language selection
            showLanguageSelection()
        case .responsibleGaming:
            self.showResponsibleGaming()
        case .helpCenter:
            openSupportURL()
        case .changePassword:
//            showPlaceholderAlert(title: "Change Password", message: "Feature coming soon")
            self.showChangePasswordScreen(tokenId: actionResponse ?? "")
        case .promotions:
            showPromotions()
        case .bonus:
            showBonus()
        case .custom:
            // Custom actions are not used in profile menu context
            print("⚠️ ProfileWalletCoordinator: Custom action not handled in profile menu")
        }
    }
    
    private func showLogoutConfirmation() {
        guard let profileViewController = profileViewController else { return }
        
        let alert = UIAlertController(
            title: localized("logout"),
            message: localized("logout_confirmation_message"),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: localized("cancel"), style: .cancel)
        let logoutAction = UIAlertAction(title: localized("logout"), style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        profileViewController.present(alert, animated: true)
    }
    
    private func showLanguageSelection() {
        guard let profileNavigationController = profileNavigationController else {
            print("ProfileWalletCoordinator: Profile navigation controller not available")
            return
        }

        // Create LanguageSelectorCoordinator using profile's NavigationController
        let languageSelectorCoordinator = LanguageSelectorCoordinator(
            navigationController: profileNavigationController
        )

        // Setup closure-based callbacks
        languageSelectorCoordinator.onDismiss = { [weak self] in
            self?.removeChildCoordinator(languageSelectorCoordinator)
        }

        languageSelectorCoordinator.onLanguageSelected = { language in
            // Future: Handle language switching logic
            print("ProfileWalletCoordinator: Language selected - \(language.displayName)")
        }

        addChildCoordinator(languageSelectorCoordinator)
        languageSelectorCoordinator.start()
    }

    private func openSupportURL() {
        let supportURL = Env.linksProvider.links.getURL(for: .helpCenter)

        guard !supportURL.isEmpty, let url = URL(string: supportURL) else {
            print("❌ ProfileWalletCoordinator: Invalid support URL: '\(supportURL)'")
            return
        }

        guard UIApplication.shared.canOpenURL(url) else {
            print("❌ ProfileWalletCoordinator: Cannot open URL: \(supportURL)")
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("✅ ProfileWalletCoordinator: Opened support URL: \(supportURL)")
            } else {
                print("❌ ProfileWalletCoordinator: Failed to open support URL")
            }
        }
    }

    private func showTransactionHistory() {
        guard let profileNavigationController = profileNavigationController else {
            print("❌ ProfileWalletCoordinator: Profile navigation controller not available")
            return
        }

        // Create TransactionHistoryCoordinator using profile's NavigationController
        let transactionHistoryCoordinator = TransactionHistoryCoordinator(
            navigationController: profileNavigationController,
            servicesProvider: servicesProvider
        )

        // Setup closure-based callbacks
        transactionHistoryCoordinator.onDismiss = { [weak self] in
            self?.removeChildCoordinator(transactionHistoryCoordinator)
        }

        addChildCoordinator(transactionHistoryCoordinator)
        transactionHistoryCoordinator.start()

        print("🚀 ProfileWalletCoordinator: Navigated to transaction history from profile modal context")
    }
    
    // COMMENTED OUT - Using XPush.openInbox() for now
    // Will be used later for in-app notification settings
    /*
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
    */
    
    private func showPromotions() {
        guard let profileNavigationController = profileNavigationController else {
            print("❌ ProfileWalletCoordinator: Profile navigation controller not available")
            return
        }
        
        // Create and start PromotionsCoordinator
        let promotionsCoordinator = PromotionsCoordinator(
            navigationController: profileNavigationController,
            environment: Env
        )
        
        // Setup TopBar container callbacks to delegate to ProfileWalletCoordinator
        promotionsCoordinator.onLoginRequested = { [weak self] in
            // Handle login request - could delegate to parent or handle locally
            print("🚀 ProfileWalletCoordinator: Login requested from promotions")
        }
        
        promotionsCoordinator.onRegistrationRequested = { [weak self] in
            // Handle registration request - could delegate to parent or handle locally
            print("🚀 ProfileWalletCoordinator: Registration requested from promotions")
        }
        
        promotionsCoordinator.onProfileRequested = { [weak self] in
            // Handle profile request - could delegate to parent or handle locally
            print("🚀 ProfileWalletCoordinator: Profile requested from promotions")
        }
        
        promotionsCoordinator.onDepositRequested = { [weak self] in
            // Delegate to parent coordinator
            self?.onDepositRequested?()
            self?.presentDepositFlow()
        }
        
        promotionsCoordinator.onWithdrawRequested = { [weak self] in
            // Delegate to parent coordinator
            self?.onWithdrawRequested?()
            self?.presentWithdrawFlow()
        }
        
        // Add as child coordinator for proper lifecycle management
        addChildCoordinator(promotionsCoordinator)
        
        // Start the coordinator (which will handle the entire promotions flow)
        promotionsCoordinator.start()
        
        print("🚀 ProfileWalletCoordinator: Started PromotionsCoordinator")
    }
    
    private func showBonus() {
        guard let profileNavigationController = profileNavigationController else {
            print("❌ ProfileWalletCoordinator: Profile navigation controller not available")
            return
        }
        
        // Create and start BonusCoordinator
        let bonusCoordinator = BonusCoordinator(
            navigationController: profileNavigationController,
            servicesProvider: servicesProvider,
            displayType: .history
        )
        
        // Setup callbacks
        bonusCoordinator.onDepositComplete = { [weak self] in
            print("🏦 ProfileWalletCoordinator: Deposit completed from bonus")
            // Refresh user wallet after deposit
            self?.userSessionStore.refreshUserWallet()
        }
        
        bonusCoordinator.onTermsURLRequested = { urlString in
            print("📄 ProfileWalletCoordinator: Terms URL requested: \(urlString)")
            // URL is already opened in the coordinator
        }
        
        bonusCoordinator.onBonusDismiss = { [weak self] in
            self?.removeChildCoordinator(bonusCoordinator)
        }
        
        bonusCoordinator.onDepositBonusRequested = { [weak self] bonusCode in
            self?.removeChildCoordinator(bonusCoordinator)
            self?.presentDepositFlow(bonusCode: bonusCode)
        }
        
        bonusCoordinator.onDepositBonusSkipRequested = { [weak self] in
            self?.removeChildCoordinator(bonusCoordinator)
            self?.presentDepositFlow()
        }
        
        // Add as child coordinator
        addChildCoordinator(bonusCoordinator)
        
        // Start the coordinator
        bonusCoordinator.start()
        
        print("🎁 ProfileWalletCoordinator: Started BonusCoordinator")
    }
    
    private func showResponsibleGaming() {
        guard let profileNavigationController = profileNavigationController else {
            print("❌ ProfileWalletCoordinator: Profile navigation controller not available")
            return
        }
        
        let responsibleGamingCoordinator = ResponsibleGamingCoordinator(
            navigationController: profileNavigationController,
            servicesProvider: servicesProvider
        )
        
        responsibleGamingCoordinator.onDismiss = { [weak self] in
            self?.removeChildCoordinator(responsibleGamingCoordinator)
        }
        
        responsibleGamingCoordinator.onRootDismiss = { [weak self] in
            self?.removeChildCoordinator(responsibleGamingCoordinator)
            self?.dismissProfileWallet()
        }
        
        addChildCoordinator(responsibleGamingCoordinator)
        responsibleGamingCoordinator.start()
        
        print("🎯 ProfileWalletCoordinator: Started ResponsibleGamingCoordinator")
    }
    
    private func showPlaceholderAlert(title: String, message: String) {
        guard let profileViewController = profileViewController else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: localized("ok"), style: .default)
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
    
    private func presentDepositFlow(bonusCode: String? = nil) {
        guard let profileNavigationController = profileNavigationController else { return }
        
        let bankingCoordinator = BankingCoordinator.forGomaCashierDeposit(
            navigationController: profileNavigationController,
            client: servicesProvider
        )
        
        bankingCoordinator.bonusCode = bonusCode
        
        // Set up banking coordinator closures
        setupBankingCoordinatorCallbacks(bankingCoordinator)
        
        // Add as child coordinator
        addChildCoordinator(bankingCoordinator)
        
        // Start the banking flow
        bankingCoordinator.start()
    }
    
    private let gomaCashierLogPrefix = "[GomaCashier]"

    private func presentWithdrawFlow() {
        guard let profileNavigationController = profileNavigationController else { return }

        GomaLogger.info("\(gomaCashierLogPrefix) Presenting Goma withdraw flow from ProfileWallet")
        let bankingCoordinator = BankingCoordinator.forGomaCashierWithdraw(
            navigationController: profileNavigationController,
            client: servicesProvider
        )

        // Set up banking coordinator closures
        setupBankingCoordinatorCallbacks(bankingCoordinator)

        // Add as child coordinator
        addChildCoordinator(bankingCoordinator)

        // Start the banking flow
        bankingCoordinator.start()
    }
    
    
    // MARK: - Banking Coordinator Setup
    
    private func setupBankingCoordinatorCallbacks(_ coordinator: BankingCoordinator) {
        // Transaction completion callback
        coordinator.onTransactionComplete = { [weak self] in
            guard let self = self else { return }
            
            // Transaction completed successfully
            print("[ProfileWallet] Banking transaction completed")
            
            // Update wallet data to reflect the transaction
            self.userSessionStore.refreshUserWallet()
            
            // Remove child coordinator
            self.removeChildCoordinator(coordinator)
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
        
    }
    
    private func showTransactionErrorAlert(error: String) {
        guard let presentingViewController = profileNavigationController else { return }

        let alert = UIAlertController(
            title: localized("error"),
            message: error,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default))
        
        presentingViewController.present(alert, animated: true)
    }
    
    private func showChangePasswordErrorAlert(error: String) {
        guard let presentingViewController = profileNavigationController else { return }

        let alert = UIAlertController(
            title: localized("error"),
            message: error,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default))
        
        presentingViewController.present(alert, animated: true)
    }
    
    private func showChangePasswordScreen(tokenId: String) {
        let phoneNumber = userSessionStore.userProfilePublisher.value?.username ?? ""
        
        let passwordCodeVerificationViewModel = PhonePasswordCodeVerificationViewModel(tokenId: tokenId, phoneNumber: phoneNumber, resetPasswordType: .change)
        
        let passwordCodeVerificationViewController = PhonePasswordCodeVerificationViewController(viewModel: passwordCodeVerificationViewModel)
        
        self.profileNavigationController?.pushViewController(passwordCodeVerificationViewController, animated: true)
    }
}
