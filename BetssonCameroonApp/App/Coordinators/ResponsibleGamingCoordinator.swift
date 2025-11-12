//
//  ResponsibleGamingCoordinator.swift
//  BetssonCameroonApp
//
//  Created by André on 06/11/2025.
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
    var onRootDismiss: (() -> Void)?
    
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
    
    func finish(withRootDismiss: Bool = false) {
        responsibleGamingViewController = nil
        responsibleGamingViewModel = nil
        if withRootDismiss {
            onRootDismiss?()
        }
        else {
            onDismiss?()
        }
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
        
        // Setup ViewModel callbacks
        responsibleGamingViewModel.onNavigateBack = { [weak self] in
            self?.handleBackNavigation()
        }
        responsibleGamingViewModel.onLimitSuccess = { [weak self] info in
            self?.presentLimitSuccess(info: info)
        }
        responsibleGamingViewModel.onTimeoutSuccess = { [weak self] info in
            self?.presentLimitSuccess(info: info)
        }
        responsibleGamingViewModel.onSelfExclusionSuccess = { [weak self] info in
            self?.presentLimitSuccess(info: info)
        }
        
        // Present the responsible gaming screen
        navigationController.pushViewController(responsibleGamingViewController, animated: true)
        
        print("🎯 ResponsibleGamingCoordinator: Presented responsible gaming screen")
    }
    
    // MARK: - Action Handlers
    
    private func handleBackNavigation(withRootDismiss: Bool = false) {
        navigationController.popViewController(animated: true)
        finish(withRootDismiss: withRootDismiss)
    }
    
    private func presentLimitSuccess(info: ResponsibleGamingLimitSuccessInfo) {
        DispatchQueue.main.async { [weak self] in
            guard
                let self,
                let hostViewController = self.responsibleGamingViewController
            else { return }
            
            let successViewModel = LimitsSuccessViewModel(
                successMessage: info.successMessage,
                periodTitle: info.periodTitle,
                periodValue: info.periodValue,
                amountTitle: info.amountTitle,
                amountValue: info.amountValue,
                statusTitle: info.statusTitle,
                statusValue: info.statusValue,
                highlightStatus: info.highlightStatus
            )
            let successViewController = LimitsSuccessViewController(viewModel: successViewModel)
            successViewController.onContinueRequested = { [weak self, weak successViewController] in
                guard let self, let successViewController else { return }
                successViewController.dismiss(animated: true) {
                    self.handlePostSuccessActions(info: info)
                }
            }
            
            if let presented = hostViewController.presentedViewController {
                presented.dismiss(animated: false) {
                    hostViewController.present(successViewController, animated: true)
                }
            } else {
                hostViewController.present(successViewController, animated: true)
            }
        }
    }
    
    private func handlePostSuccessActions(info: ResponsibleGamingLimitSuccessInfo) {
        guard info.shouldLogoutOnDismiss else { return }
        Env.userSessionStore.logout()
        handleBackNavigation(withRootDismiss: true)
    }
}

