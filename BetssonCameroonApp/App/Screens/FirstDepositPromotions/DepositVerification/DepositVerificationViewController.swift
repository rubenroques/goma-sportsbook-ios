//
//  DepositVerificationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class DepositVerificationViewController: UIViewController {

    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Deposit"
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.setTitleColor(StyleProvider.Color.highlightTertiary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let transactionVerificationView: TransactionVerificationView
    private let cancelTransactionButton: ButtonView
    private let alternativeStepsButton: ButtonView

    private var viewModel: DepositVerificationViewModelProtocol

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Navigation Closures
    // Called when verification flow needs navigation - handled by coordinator
    var onAlternativeStepsRequested: ((BonusDepositData) -> Void)?
    var onVerificationComplete: ((BonusDepositData) -> Void)?
    var onCancelRequested: (() -> Void)?

    init(viewModel: DepositVerificationViewModelProtocol) {
        self.viewModel = viewModel
        self.transactionVerificationView = TransactionVerificationView(viewModel: viewModel.transactionVerificationViewModel)
        self.cancelTransactionButton = ButtonView(viewModel: viewModel.cancelButtonViewModel)
        self.alternativeStepsButton = ButtonView(viewModel: viewModel.alternativeStepsButtonViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
        setupLayout()
        setupBindings()
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        updateButtonVisibility()
        
    }

    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(cancelButton)

        transactionVerificationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(transactionVerificationView)
        cancelTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelTransactionButton)
        alternativeStepsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alternativeStepsButton)

        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),

            navigationTitleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            cancelButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            transactionVerificationView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 32),
            transactionVerificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            transactionVerificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            cancelTransactionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cancelTransactionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cancelTransactionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            cancelTransactionButton.heightAnchor.constraint(equalToConstant: 48),

            alternativeStepsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            alternativeStepsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            alternativeStepsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            alternativeStepsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupBindings() {
        
        cancelTransactionButton.onButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.onVerificationComplete?(self.viewModel.bonusDepositData)
        }
        
        alternativeStepsButton.onButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.onAlternativeStepsRequested?(self.viewModel.bonusDepositData)
        }
        
        viewModel.shouldUpdateTransactionState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.updateButtonVisibility()
            })
            .store(in: &cancellables)
    }

    private func updateButtonVisibility() {
        cancelTransactionButton.isHidden = viewModel.isShowingAlternativeSteps
        alternativeStepsButton.isHidden = !viewModel.isShowingAlternativeSteps
    }

    @objc private func didTapCancel() {
        onCancelRequested?()
    }
}
