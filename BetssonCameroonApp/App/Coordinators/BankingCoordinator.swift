//
//  BankingCoordinator.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 11/09/2025.
//

import UIKit
import ServicesProvider

/// Generic coordinator for banking operations following MVVM-C pattern
/// Coordinator's role: Navigation and presentation logic only
final class BankingCoordinator: Coordinator {

    // MARK: - Transaction Type

    enum TransactionType {
        /// EveryMatrix-hosted deposit (legacy)
        case deposit
        /// EveryMatrix-hosted withdraw (legacy)
        case withdraw
        /// Widget Cashier deposit (new)
        case widgetCashierDeposit
        /// Widget Cashier withdraw (new)
        case widgetCashierWithdraw

        var title: String {
            switch self {
            case .deposit, .widgetCashierDeposit:
                return "Deposit"
            case .withdraw, .widgetCashierWithdraw:
                return "Withdraw"
            }
        }
    }

    // MARK: - Coordinator Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var bonusCode: String?

    // MARK: - Private Properties

    private let transactionType: TransactionType
    private let client: ServicesProvider.Client

    // MARK: - Callbacks

    /// Called when banking transaction completes successfully
    var onTransactionComplete: (() -> Void)?

    /// Called when banking transaction is cancelled
    var onTransactionCancel: (() -> Void)?

    /// Called when banking transaction fails
    var onTransactionError: ((String) -> Void)?

    // MARK: - Initialization

    /// Initialize banking coordinator
    /// - Parameters:
    ///   - transactionType: Type of transaction (deposit or withdraw)
    ///   - presentingViewController: View controller that will present the banking flow
    ///   - client: Services provider client for banking operations
    init(
        transactionType: TransactionType,
        navigationController: UINavigationController,
        client: ServicesProvider.Client
    ) {
        self.transactionType = transactionType
        self.client = client
        self.navigationController = navigationController

    }

    // MARK: - Coordinator Implementation

    func start() {
        // Coordinator decides which flow to present based on transaction type
        switch transactionType {
        case .deposit:
            presentDepositFlow()
        case .withdraw:
            presentWithdrawFlow()
        case .widgetCashierDeposit:
            presentWidgetCashierDepositFlow()
        case .widgetCashierWithdraw:
            presentWidgetCashierWithdrawFlow()
        }
    }

    func finish() {
        dismissBankingFlow()
        childCoordinators.removeAll()
    }

    // MARK: - Navigation Logic (Coordinator's responsibility)

    private func presentDepositFlow() {
        let viewModel = DepositWebContainerViewModel(client: client, bonusCode: bonusCode)
        let viewController = DepositWebContainerViewController(viewModel: viewModel)

        setupDepositCallbacks(viewController)
        presentViewController(viewController)
    }

    private func presentWithdrawFlow() {
        let viewModel = WithdrawWebContainerViewModel(client: client)
        let viewController = WithdrawWebContainerViewController(viewModel: viewModel)

        setupWithdrawCallbacks(viewController)
        presentViewController(viewController)
    }

    private func presentWidgetCashierDepositFlow() {
        let viewModel = WidgetCashierDepositViewModel()
        let viewController = WidgetCashierDepositViewController(viewModel: viewModel)

        setupWidgetCashierDepositCallbacks(viewController)
        presentViewController(viewController)
    }

    private func presentWidgetCashierWithdrawFlow() {
        let viewModel = WidgetCashierWithdrawViewModel()
        let viewController = WidgetCashierWithdrawViewController(viewModel: viewModel)

        setupWidgetCashierWithdrawCallbacks(viewController)
        presentViewController(viewController)
    }

    private func presentViewController(_ viewController: UIViewController) {
        // Prevent swipe-down dismissal during banking flows.
        viewController.isModalInPresentation = true
        navigationController.present(viewController, animated: true)
    }

    // MARK: - Callback Setup

    private func setupDepositCallbacks(_ viewController: DepositWebContainerViewController) {
        viewController.onTransactionComplete = { [weak self] navigationAction in
            self?.handleTransactionComplete(navigationAction: navigationAction)
        }

        viewController.onTransactionCancel = { [weak self] in
            self?.handleTransactionCancel()
        }
    }

    private func setupWithdrawCallbacks(_ viewController: WithdrawWebContainerViewController) {
        viewController.onTransactionComplete = { [weak self] navigationAction in
            self?.handleTransactionComplete(navigationAction: navigationAction)
        }

        viewController.onTransactionCancel = { [weak self] in
            self?.handleTransactionCancel()
        }
    }

    private func setupWidgetCashierDepositCallbacks(_ viewController: WidgetCashierDepositViewController) {
        viewController.onTransactionComplete = { [weak self] navigationAction in
            self?.handleTransactionComplete(navigationAction: navigationAction)
        }

        viewController.onTransactionCancel = { [weak self] in
            self?.handleTransactionCancel()
        }
    }

    private func setupWidgetCashierWithdrawCallbacks(_ viewController: WidgetCashierWithdrawViewController) {
        viewController.onTransactionComplete = { [weak self] navigationAction in
            self?.handleTransactionComplete(navigationAction: navigationAction)
        }

        viewController.onTransactionCancel = { [weak self] in
            self?.handleTransactionCancel()
        }
    }

    // MARK: - Event Handlers

    private func handleTransactionComplete(navigationAction: BankingNavigationAction) {
        switch navigationAction {
        case .goToSports, .goToCasino, .closeModal, .none:
            // All completion actions result in dismissing and notifying parent
            finish()
            onTransactionComplete?()
        }
    }

    private func handleTransactionCancel() {
        finish()
        onTransactionCancel?()
    }

    // MARK: - UI Helpers

    private func dismissBankingFlow() {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true)
        }
    }
}

// MARK: - Factory Methods

extension BankingCoordinator {

    static func forDeposit(
        navigationController: UINavigationController,
        client: ServicesProvider.Client
    ) -> BankingCoordinator {
        return BankingCoordinator(
            transactionType: .deposit,
            navigationController: navigationController,
            client: client
        )
    }

    static func forWithdraw(
        navigationController: UINavigationController,
        client: ServicesProvider.Client
    ) -> BankingCoordinator {
        return BankingCoordinator(
            transactionType: .withdraw,
            navigationController: navigationController,
            client: client
        )
    }

    // MARK: - Widget Cashier Factory Methods

    static func forWidgetCashierDeposit(
        navigationController: UINavigationController,
        client: ServicesProvider.Client
    ) -> BankingCoordinator {
        return BankingCoordinator(
            transactionType: .widgetCashierDeposit,
            navigationController: navigationController,
            client: client
        )
    }

    static func forWidgetCashierWithdraw(
        navigationController: UINavigationController,
        client: ServicesProvider.Client
    ) -> BankingCoordinator {
        return BankingCoordinator(
            transactionType: .widgetCashierWithdraw,
            navigationController: navigationController,
            client: client
        )
    }
}
