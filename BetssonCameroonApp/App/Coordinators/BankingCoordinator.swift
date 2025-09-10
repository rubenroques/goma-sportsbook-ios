//
//  BankingCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 10/09/2025.
//

import UIKit
import Combine
import ServicesProvider

/// Coordinator for managing banking flow navigation and presentation
final class BankingCoordinator: Coordinator {
    
    // MARK: - Coordinator Properties
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Private Properties
    
    private let transactionType: CashierTransactionType
    private let client: ServicesProvider.Client
    private let isFirstDeposit: Bool
    private let presentingViewController: UIViewController
    
    private var bankingViewModel: BankingViewModel?
    private var currentWebViewController: BankingWebViewController?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Navigation Closures (following app's closure-based pattern)
    
    var onTransactionComplete: ((CashierTransactionType, Double?) -> Void)?
    var onTransactionCancel: (() -> Void)?
    var onTransactionError: ((String) -> Void)?
    var onNavigationAction: ((BankingNavigationAction) -> Void)?
    
    // MARK: - Initialization
    
    /// Initialize banking coordinator
    /// - Parameters:
    ///   - presentingViewController: View controller that will present the banking flow
    ///   - transactionType: Type of banking transaction
    ///   - client: Services provider client for banking operations
    ///   - isFirstDeposit: Whether this is a first deposit (affects bonus flow)
    init(
        presentingViewController: UIViewController,
        transactionType: CashierTransactionType,
        client: ServicesProvider.Client,
        isFirstDeposit: Bool = false
    ) {
        self.presentingViewController = presentingViewController
        self.transactionType = transactionType
        self.client = client
        self.isFirstDeposit = isFirstDeposit
        self.navigationController = UINavigationController()
        
        setupNavigationController()
    }
    
    // MARK: - Coordinator Implementation
    
    func start() {
        createAndPresentBankingFlow()
    }
    
    func finish() {
        dismissBankingFlow()
        childCoordinators.removeAll()
    }
    
    // MARK: - Private Setup
    
    private func setupNavigationController() {
        // Configure navigation controller appearance
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.modalPresentationStyle = .pageSheet
        
        // Configure sheet presentation
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
        }
    }
    
    private func createAndPresentBankingFlow() {
        // Create ViewModel
        let viewModel = BankingViewModel(
            transactionType: transactionType,
            client: client
        )
        self.bankingViewModel = viewModel
        
        // Set up ViewModel bindings
        setupViewModelBindings(viewModel)

        viewModel.initializeBanking(currency: "XAF", language: "EN", isFirstDeposit: isFirstDeposit)
        
        // Present the navigation controller
        presentingViewController.present(navigationController, animated: true)
    }
    
    private func setupViewModelBindings(_ viewModel: BankingViewModel) {
        // Subscribe to screen changes
        viewModel.screenPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] screen in
                self?.handleScreenChange(screen)
            }
            .store(in: &cancellables)
        
        // Subscribe to state changes for error handling
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Screen Navigation
    
    private func handleScreenChange(_ screen: BankingScreen) {
        switch screen {
        case .bonusSelection:
            presentBonusSelectionScreen()
            
        case .amountInput:
            // For now, this will trigger the WebView loading
            // In a full implementation, this could show an amount input screen
            break
            
        case .webView(let url):
            presentWebViewController(with: url)
            
        case .success(let amount):
            handleTransactionSuccess(amount: amount)
            
        case .error(let message):
            handleTransactionError(error: message)
        }
    }
    
    private func handleStateChange(_ state: BankingState) {
        switch state {
        case .idle:
            break
        case .loading:
            // Could show loading indicator here if needed
            break
        case .loaded:
            // WebView will be presented via screenPublisher
            break
        case .error(let message):
            handleTransactionError(error: message)
        }
    }
    
    private func presentBonusSelectionScreen() {
        // For now, we'll skip bonus selection and proceed to WebView
        // In a full implementation, create a BonusSelectionViewController here
        bankingViewModel?.skipBonusSelection()
    }
    
    private func presentWebViewController(with url: URL) {
        let webViewController = BankingWebViewController(
            transactionType: transactionType,
            url: url
        )
        
        // Set up closure-based callbacks
        webViewController.onTransactionComplete = { [weak self] navigationAction in
            self?.handleWebViewTransactionComplete(navigationAction: navigationAction)
        }
        
        webViewController.onTransactionFailure = { [weak self] error in
            self?.handleWebViewTransactionFailure(error: error)
        }
        
        webViewController.onTransactionCancel = { [weak self] in
            self?.handleWebViewTransactionCancel()
        }
        
        webViewController.onWebViewDidFinishLoading = { [weak self] in
            self?.handleWebViewDidFinishLoading()
        }
        
        navigationController.setViewControllers([webViewController], animated: true)
        currentWebViewController = webViewController
    }
    
    // MARK: - Transaction Handling
    
    private func handleTransactionSuccess(amount: Double) {
        onTransactionComplete?(transactionType, amount)
        
        finish()
    }
    
    private func handleTransactionError(error: String) {
        onTransactionError?(error)
        finish()
    }
    
    private func handleTransactionCancellation() {
        onTransactionCancel?()
        finish()
    }
    
    // MARK: - UI Helpers
    private func dismissBankingFlow() {
        if navigationController.presentingViewController != nil {
            navigationController.dismiss(animated: true)
        }
    }
    
    // MARK: - WebView Event Handlers
    
    private func handleWebViewTransactionComplete(navigationAction: BankingNavigationAction) {
        // Notify about navigation action
        onNavigationAction?(navigationAction)
        
        // Handle transaction success
        bankingViewModel?.handleTransactionSuccess(amount: nil)
    }
    
    private func handleWebViewTransactionFailure(error: String) {
        bankingViewModel?.handleTransactionError(error: error)
    }
    
    private func handleWebViewTransactionCancel() {
        handleTransactionCancellation()
    }
    
    private func handleWebViewDidFinishLoading() {
        // WebView finished loading - no specific action needed
        print("[BankingCoordinator] WebView finished loading")
    }
}

// MARK: - Factory Methods

extension BankingCoordinator {
    
    /// Create a coordinator for deposit operations
    /// - Parameters:
    ///   - presentingViewController: View controller to present from
    ///   - client: Services provider client
    ///   - isFirstDeposit: Whether this is a first deposit
    /// - Returns: Configured deposit coordinator
    static func forDeposit(
        presentingViewController: UIViewController,
        client: ServicesProvider.Client,
        isFirstDeposit: Bool = false
    ) -> BankingCoordinator {
        return BankingCoordinator(
            presentingViewController: presentingViewController,
            transactionType: .deposit,
            client: client,
            isFirstDeposit: isFirstDeposit
        )
    }
    
    /// Create a coordinator for withdraw operations
    /// - Parameters:
    ///   - presentingViewController: View controller to present from
    ///   - client: Services provider client
    /// - Returns: Configured withdraw coordinator
    static func forWithdraw(
        presentingViewController: UIViewController,
        client: ServicesProvider.Client
    ) -> BankingCoordinator {
        return BankingCoordinator(
            presentingViewController: presentingViewController,
            transactionType: .withdraw,
            client: client,
            isFirstDeposit: false
        )
    }
}
