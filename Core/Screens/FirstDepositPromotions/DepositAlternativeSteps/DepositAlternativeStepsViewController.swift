//
//  DepositAlternativeStepsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/07/2025.
//

import Foundation
import UIKit
import GomaUI

class DepositAlternativeStepsViewController: UIViewController {
    private let viewModel: DepositAlternativeStepsViewModelProtocol

    private let navigationView: CustomNavigationView
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    private var stepViews: [StepInstructionView] = []
    private let confirmButton: ButtonView
    private let resendButton: ButtonView
    private let cancelButton: ButtonView
    
    init(viewModel: DepositAlternativeStepsViewModelProtocol) {
        self.viewModel = viewModel
        self.navigationView = CustomNavigationView(viewModel: viewModel.navigationViewModel)
        self.confirmButton = ButtonView(viewModel: viewModel.confirmButtonViewModel)
        self.resendButton = ButtonView(viewModel: viewModel.resendButtonViewModel)
        self.cancelButton = ButtonView(viewModel: viewModel.cancelButtonViewModel)
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = viewModel.title
        stepViews = viewModel.stepViewModels.map { StepInstructionView(viewModel: $0) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        setupLayout()
        setupBindings()
        
    }

    private func setupLayout() {
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationView)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let scrollContent = UIView()
        scrollContent.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContent)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollContent.addSubview(titleLabel)

        let stepsStack = UIStackView(arrangedSubviews: stepViews)
        stepsStack.axis = .vertical
        stepsStack.spacing = 12
        stepsStack.alignment = .fill
        stepsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stepsStack)

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resendButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
                navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationView.heightAnchor.constraint(equalToConstant: 56),

                // ScrollView constraints
                scrollView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),

                // Scroll content constraints
                scrollContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
                scrollContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                scrollContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                scrollContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                scrollContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

                // Title and stepsStack inside scroll content
                titleLabel.topAnchor.constraint(equalTo: scrollContent.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor, constant: -16),

                stepsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                stepsStack.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: 16),
                stepsStack.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor, constant: -16),
                stepsStack.bottomAnchor.constraint(equalTo: scrollContent.bottomAnchor, constant: -16),

                // Buttons fixed at the bottom
                confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                confirmButton.bottomAnchor.constraint(equalTo: resendButton.topAnchor, constant: -10),

                resendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                resendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                resendButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
                
                cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ])
    }
    
    private func setupBindings() {
        navigationView.onCloseTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        
        confirmButton.onButtonTapped = { [weak self] in
            self?.presentDepositSuccessScreen()
        }
        
        resendButton.onButtonTapped = { [weak self] in
            self?.viewModel.shouldResendAction?()
        }
        
        cancelButton.onButtonTapped = { [weak self] in
            self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func presentDepositSuccessScreen() {
        let depositBonusSuccessViewModel: DepositBonusSuccessViewModelProtocol = MockDepositBonusSuccessViewModel(bonusDepositData: viewModel.bonusDepositData)
        
        let depositBonusSuccessViewController = DepositBonusSuccessViewController(viewModel: depositBonusSuccessViewModel)
        
        self.present(depositBonusSuccessViewController, animated: true)
    }
}
