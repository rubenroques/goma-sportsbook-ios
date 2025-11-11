//
//  FirstDepositPromotionsCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 01/08/2025.
//

import UIKit
import ServicesProvider
import GomaUI

class FirstDepositPromotionsCoordinator: Coordinator {
    
    // MARK: - Coordinator Protocol
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Properties
    private let environment: Environment
    private var firstDepositViewController: FirstDepositPromotionsViewController?
    
    // MARK: - Navigation Closures
    // Following the established pattern - these will be set by parent coordinator
    var onFirstDepositComplete: (() -> Void)?
    var onFirstDepositSkipped: (() -> Void)?
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, environment: Environment) {
        self.navigationController = navigationController
        self.environment = environment
    }
    
    // MARK: - Coordinator Protocol
    
    func start() {
        presentFirstDepositPromotions()
    }
    
    func startFromRegistration() {
        // Entry point after successful registration
        presentFirstDepositPromotions()
    }
    
    func finish() {
        childCoordinators.removeAll()
        firstDepositViewController = nil
    }
    
    // MARK: - Private Navigation Methods
    
    private func presentFirstDepositPromotions() {
        let viewModel: FirstDepositPromotionsViewModelProtocol = MockFirstDepositPromotionsViewModel()
        let firstDepositViewController = FirstDepositPromotionsViewController(viewModel: viewModel)
        
        // Setup navigation closures
        firstDepositViewController.onBonusSelected = { [weak self] bonusData in
            self?.showDepositBonus(with: bonusData)
        }
        
        firstDepositViewController.onSkipRequested = { [weak self] in
            self?.handleSkipFirstDeposit()
        }
        
        firstDepositViewController.onCloseRequested = { [weak self] in
            self?.handleSkipFirstDeposit()
        }
        
        self.firstDepositViewController = firstDepositViewController
        
        // Present modally as the entry point
        let authNavigationController = AppCoordinator.navigationController(with: firstDepositViewController)
        navigationController.present(authNavigationController, animated: true)
        
        print("🎁 FirstDepositPromotionsCoordinator: Presented first deposit promotions")
    }
    
    private func showDepositBonus(with bonusData: PromotionalBonusCardData) {
        let depositBonusViewModel: DepositBonusViewModelProtocol = MockDepositBonusViewModel(
            promotionalBonusCardData: bonusData
        )
        let depositBonusViewController = DepositBonusViewController(viewModel: depositBonusViewModel)
        
        // Setup navigation closures
        depositBonusViewController.onVerificationRequested = { [weak self] depositData in
            self?.showDepositVerification(with: depositData)
        }
        
        depositBonusViewController.onCancelRequested = { [weak self] in
            self?.handleCancelDeposit()
        }
        
        // Present within the current navigation stack
        if let currentNavController = firstDepositViewController?.navigationController {
            currentNavController.pushViewController(depositBonusViewController, animated: true)
        }
        
        print("🎁 FirstDepositPromotionsCoordinator: Navigated to deposit bonus")
    }
    
    private func showDepositVerification(with depositData: BonusDepositData) {
        let depositVerificationViewModel: DepositVerificationViewModelProtocol = MockDepositVerificationViewModel(
            bonusDepositData: depositData
        )
        let depositVerificationViewController = DepositVerificationViewController(viewModel: depositVerificationViewModel)
        
        // Setup navigation closures
        depositVerificationViewController.onAlternativeStepsRequested = { [weak self] depositData in
            self?.showAlternativeSteps(with: depositData)
        }
        
        depositVerificationViewController.onVerificationComplete = { [weak self] depositData in
            self?.showDepositSuccess(with: depositData)
        }
        
        depositVerificationViewController.onCancelRequested = { [weak self] in
            self?.handleCancelDeposit()
        }
        
        // Present modally for verification flow
        if let currentNavController = firstDepositViewController?.navigationController {
            currentNavController.present(depositVerificationViewController, animated: true)
        }
        
        print("🎁 FirstDepositPromotionsCoordinator: Presented deposit verification")
    }
    
    private func showAlternativeSteps(with depositData: BonusDepositData) {
        let alternativeStepsViewModel: DepositAlternativeStepsViewModelProtocol = MockDepositAlternativeStepsViewModel(
            bonusDepositData: depositData
        )
        let alternativeStepsViewController = DepositAlternativeStepsViewController(viewModel: alternativeStepsViewModel)
        
        // Setup navigation closures
        alternativeStepsViewController.onDepositComplete = { [weak self] depositData in
            self?.showDepositSuccess(with: depositData)
        }
        
        alternativeStepsViewController.onCancelRequested = { [weak self] in
            self?.handleCancelDeposit()
        }
        
        // Present modally for alternative steps
        if let currentNavController = firstDepositViewController?.navigationController {
            currentNavController.present(alternativeStepsViewController, animated: true)
        }
        
        print("🎁 FirstDepositPromotionsCoordinator: Presented alternative steps")
    }
    
    private func showDepositSuccess(with depositData: BonusDepositData) {
        let depositSuccessViewModel: DepositBonusSuccessViewModelProtocol = MockDepositBonusSuccessViewModel(
            bonusDepositData: depositData
        )
        let depositSuccessViewController = DepositBonusSuccessViewController(viewModel: depositSuccessViewModel)
        
        // Setup navigation closures
        depositSuccessViewController.onContinueRequested = { [weak self] in
            self?.handleFirstDepositComplete()
        }
        
        // Present modally for success celebration
        if let currentNavController = firstDepositViewController?.navigationController {
            currentNavController.present(depositSuccessViewController, animated: true)
        }
        
        print("🎁 FirstDepositPromotionsCoordinator: Presented deposit success")
    }
    
    // MARK: - Action Handlers
    
    private func handleFirstDepositComplete() {
        print("🎁 FirstDepositPromotionsCoordinator: First deposit completed successfully")
        onFirstDepositComplete?()
    }
    
    private func handleSkipFirstDeposit() {
        print("🎁 FirstDepositPromotionsCoordinator: First deposit skipped")
        onFirstDepositSkipped?()
    }
    
    private func handleCancelDeposit() {
        print("🎁 FirstDepositPromotionsCoordinator: Deposit cancelled, treating as skip")
        onFirstDepositSkipped?()
    }
}
