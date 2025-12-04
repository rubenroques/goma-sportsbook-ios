//
//  LanguageSelectorCoordinator.swift
//  BetssonCameroonApp
//

import UIKit
import GomaUI

final class LanguageSelectorCoordinator: Coordinator {

    // MARK: - Coordinator Properties

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Private Properties

    private var languageSelectorViewController: LanguageSelectorFullScreenViewController?

    // MARK: - Navigation Closures

    var onDismiss: (() -> Void)?

    /// Called when a language is selected (for future language switching logic)
    var onLanguageSelected: ((LanguageModel) -> Void)?

    // MARK: - Initialization

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator Implementation

    func start() {
        showLanguageSelector()
    }

    func finish() {
        languageSelectorViewController = nil
        onDismiss?()
        childCoordinators.removeAll()
    }

    // MARK: - Private Methods

    private func showLanguageSelector() {
        let viewModel = LanguageSelectorFullScreenViewModel()
        let viewController = LanguageSelectorFullScreenViewController(viewModel: viewModel)

        viewModel.onDismiss = { [weak self] in
            self?.dismissLanguageSelector()
        }

        viewModel.onLanguageSelected = { [weak self] language in
            self?.onLanguageSelected?(language)
        }

        // Store reference
        self.languageSelectorViewController = viewController

        // Push onto navigation stack
        navigationController.pushViewController(viewController, animated: true)
    }

    private func dismissLanguageSelector() {
        navigationController.popViewController(animated: true)
        finish()
    }
}
