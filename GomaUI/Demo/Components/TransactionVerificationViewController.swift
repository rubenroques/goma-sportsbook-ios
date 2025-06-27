//
//  TransactionVerificationViewController.swift
//  Demo
//
//  Created by André Lascas on 24/06/2025.
//

import Foundation
import UIKit
import GomaUI

class TransactionVerificationViewController: UIViewController {
    private let viewModels: [(title: String, viewModel: TransactionVerificationViewModelProtocol)] = [
        ("Incomplete Pin Mock", MockTransactionVerificationViewModel.incompletePinMock),
        ("Complete Pin state", MockTransactionVerificationViewModel.CompletePinMock),
    ]
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.text = "A transaction verification component, using TransactionVerificationView."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    private let verificationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    private var currentVerificationView: TransactionVerificationView?
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSummaryLabel()
        setupButtonStack()
        setupVerificationContainer()
        displayVerification(at: 0)
    }

    private func setupSummaryLabel() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryLabel)
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupButtonStack() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        for (index, (title, _)) in viewModels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupVerificationContainer() {
        verificationContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verificationContainer)
        NSLayoutConstraint.activate([
            verificationContainer.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 24),
            verificationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verificationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func displayVerification(at index: Int) {
        guard index < viewModels.count else { return }
        
        // Remove current verification view
        currentVerificationView?.removeFromSuperview()
        
        // Create and add new verification view
        let (title, viewModel) = viewModels[index]
        let verificationView = TransactionVerificationView(viewModel: viewModel)
        verificationView.translatesAutoresizingMaskIntoConstraints = false
        verificationContainer.addSubview(verificationView)
        
        NSLayoutConstraint.activate([
            verificationView.topAnchor.constraint(equalTo: verificationContainer.topAnchor),
            verificationView.leadingAnchor.constraint(equalTo: verificationContainer.leadingAnchor),
            verificationView.trailingAnchor.constraint(equalTo: verificationContainer.trailingAnchor),
            verificationView.bottomAnchor.constraint(equalTo: verificationContainer.bottomAnchor)
        ])
        
        currentVerificationView = verificationView
        currentIndex = index
        
        // Update button states
        updateButtonStates()
    }

    private func updateButtonStates() {
        for (index, button) in buttonStackView.arrangedSubviews.enumerated() {
            if let button = button as? UIButton {
                if index == currentIndex {
                    button.backgroundColor = .systemGreen
                } else {
                    button.backgroundColor = .systemBlue
                }
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        displayVerification(at: sender.tag)
    }
}
