//
//  NotificationsCoordinator.swift  
//  BetssonCameroonApp
//
//  Created by Claude on 29/08/2025.
//

import UIKit
import ServicesProvider
import GomaUI

// Removed NotificationsCoordinatorDelegate - using closure-based pattern for consistency with other coordinators

final class NotificationsCoordinator: Coordinator {
    
    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let servicesProvider: ServicesProvider.Client
    private var notificationsViewController: NotificationsViewController?
    
    // MARK: - Navigation Closures (following app's closure-based pattern)
    
    var onDismiss: (() -> Void)?
    var onNotificationAction: ((NotificationData, NotificationAction) -> Void)?
    
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
        showNotifications()
    }
    
    func finish() {
        notificationsViewController = nil
        onDismiss?()
        childCoordinators.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func showNotifications() {
        let viewModel = createNotificationsViewModel()
        let notificationsViewController = NotificationsViewController(viewModel: viewModel)
        
        // Setup ViewModel callbacks
        setupViewModelCallbacks(viewModel)
        
        // Store reference
        self.notificationsViewController = notificationsViewController
        
        // Push onto navigation stack (standard right-to-left slide animation)
        navigationController.pushViewController(notificationsViewController, animated: true)
    }
    
    private func createNotificationsViewModel() -> NotificationsViewModel {
        return NotificationsViewModel(servicesProvider: servicesProvider)
    }
    
    private func setupViewModelCallbacks(_ viewModel: NotificationsViewModel) {
        // Dismiss callback
        viewModel.onDismiss = { [weak self] in
            self?.dismissNotifications()
        }
        
        // Notification action callback
        viewModel.onNotificationActionTapped = { [weak self] notification, action in
            guard let self = self else { return }
            self.handleNotificationAction(notification: notification, action: action)
        }
    }
    
    private func handleNotificationAction(notification: NotificationData, action: NotificationAction) {
        print("NotificationsCoordinator: Handling notification action - \(action.title)")
        
        // Handle different notification actions
        switch action.id {
        case "claim_bonus":
            // Navigate to bonus claim screen
            showBonusClaimScreen()
        case "confirm_payment":
            // Navigate to payment confirmation screen
            showPaymentConfirmationScreen()
        case "view_bonus":
            // Show bonus details screen
            showBonusDetailsScreen()
        default:
            print("NotificationsCoordinator: Unknown action - \(action.id)")
        }
        
        // Notify parent via closure for further handling if needed
        onNotificationAction?(notification, action)
    }
    
    // MARK: - Navigation Methods
    
    private func showBonusClaimScreen() {
        // TODO: Implement bonus claim screen navigation
        print("NotificationsCoordinator: Navigate to bonus claim screen")
        showActionAlert(title: "Claim Bonus", message: "This would navigate to the bonus claim screen.")
    }
    
    private func showPaymentConfirmationScreen() {
        // TODO: Implement payment confirmation screen navigation
        print("NotificationsCoordinator: Navigate to payment confirmation screen")
        showActionAlert(title: "Confirm Payment", message: "This would navigate to the payment confirmation screen.")
    }
    
    private func showBonusDetailsScreen() {
        // TODO: Implement bonus details screen navigation
        print("NotificationsCoordinator: Navigate to bonus details screen")
        showActionAlert(title: "Bonus Details", message: "This would show detailed bonus information.")
    }
    
    private func showActionAlert(title: String, message: String) {
        guard let notificationsViewController = notificationsViewController else { return }
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        notificationsViewController.present(alert, animated: true)
    }
    
    private func dismissNotifications(completion: (() -> Void)? = nil) {
        navigationController.popViewController(animated: true)
        completion?()
        finish()
    }
}

// MARK: - Factory Methods

extension NotificationsCoordinator {
    
    /// Creates and presents a NotificationsCoordinator
    static func present(
        from navigationController: UINavigationController,
        servicesProvider: ServicesProvider.Client
    ) -> NotificationsCoordinator {
        let coordinator = NotificationsCoordinator(
            navigationController: navigationController,
            servicesProvider: servicesProvider
        )
        
        coordinator.start()
        return coordinator
    }
}
