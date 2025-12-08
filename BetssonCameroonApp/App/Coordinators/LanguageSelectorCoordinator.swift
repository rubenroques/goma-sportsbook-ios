//
//  LanguageSelectorCoordinator.swift
//  BetssonCameroonApp
//

import UIKit
import GomaUI
import GomaPlatform

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
        // 1. Create language selector VM from GomaPlatform with injected dependencies
        let languageSelectorVM = GomaPlatform.LanguageSelectorViewModel(
            languageManager: LanguageManager.shared,
            supportedLanguages: AppSupportedLanguages.all
        )

        // 2. Create full screen VM with injected language selector VM
        let viewModel = LanguageSelectorFullScreenViewModel(
            languageSelectorViewModel: languageSelectorVM
        )

        // 3. Create client-specific nav bar VM
        let navBarVM = BetssonCameroonNavigationBarViewModel(
            title: LocalizationProvider.string("change_language"),
            onBackTapped: { [weak viewModel] in viewModel?.didTapBack() }
        )

        // 4. Create VC with all injected dependencies
        let viewController = LanguageSelectorFullScreenViewController(
            viewModel: viewModel,
            navigationBarViewModel: navBarVM,
            flagImageResolver: AppLanguageFlagImageResolver()
        )

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
