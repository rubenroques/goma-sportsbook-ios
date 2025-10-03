//
//  TransactionHistoryCoordinator.swift
//  BetssonCameroonApp
//
//  Created on 25/01/2025.
//

import UIKit
import ServicesProvider
import GomaUI

final class TransactionHistoryCoordinator: Coordinator {

    // MARK: - Coordinator Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Private Properties

    private let servicesProvider: ServicesProvider.Client
    private var transactionHistoryViewController: TransactionHistoryViewController?

    // MARK: - Navigation Closures

    var onDismiss: (() -> Void)?

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
        showTransactionHistory()
    }

    func finish() {
        transactionHistoryViewController = nil
        onDismiss?()
        childCoordinators.removeAll()
    }

    // MARK: - Private Methods

    private func showTransactionHistory() {
        let viewModel = TransactionHistoryViewModel(servicesProvider: servicesProvider)
        let viewController = TransactionHistoryViewController(viewModel: viewModel)

        viewModel.onDismiss = { [weak self] in
            self?.dismissTransactionHistory()
        }

        // Store reference
        self.transactionHistoryViewController = viewController

        // Push onto navigation stack
        navigationController.pushViewController(viewController, animated: true)
    }

    private func dismissTransactionHistory() {
        navigationController.popViewController(animated: true)
        finish()
    }
}
