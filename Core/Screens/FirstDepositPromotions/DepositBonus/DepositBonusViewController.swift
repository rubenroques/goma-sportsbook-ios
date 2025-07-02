//
//  DepositBonusViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class DepositBonusViewController: UIViewController {
    
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
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let headerView: PromotionalHeaderView
    private let highlightedTextView: HighlightedTextView
    private let amountField: BorderedTextFieldView
    private let amountPillsView: AmountPillsView
    private let bonusInfoView: DepositBonusInfoView
    private let depositButton: ButtonView
    
    private let loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    // Constraints
    private var depositButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()
    
    private let viewModel: DepositBonusViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: DepositBonusViewModelProtocol) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.amountField = BorderedTextFieldView(viewModel: viewModel.amountFieldViewModel)
        self.amountPillsView = AmountPillsView(viewModel: viewModel.amountPillsViewModel)
        self.bonusInfoView = DepositBonusInfoView(viewModel: viewModel.bonusInfoViewModel)
        self.depositButton = ButtonView(viewModel: viewModel.buttonViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        setupLayout()
        setupBindings()
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(cancelButton)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        highlightedTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highlightedTextView)
        amountField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountField)
        amountPillsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountPillsView)
        bonusInfoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bonusInfoView)
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(depositButton)
        view.addSubview(loadingView)
        
        depositButtonBottomConstraint = depositButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 44),

            navigationTitleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            cancelButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            headerView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 18),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            highlightedTextView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            highlightedTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            highlightedTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            amountField.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 20),
            amountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            amountField.heightAnchor.constraint(equalToConstant: 48),

            amountPillsView.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 16),
            amountPillsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountPillsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            amountPillsView.heightAnchor.constraint(equalToConstant: 40),

            bonusInfoView.topAnchor.constraint(equalTo: amountPillsView.bottomAnchor, constant: 16),
            bonusInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bonusInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bonusInfoView.heightAnchor.constraint(equalToConstant: 48),

            depositButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            depositButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            depositButton.heightAnchor.constraint(equalToConstant: 48),
            depositButtonBottomConstraint,
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        depositButton.onButtonTapped = { [weak self] in
            self?.viewModel.requestVerifyTransaction()
        }
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.shouldVerifyTransaction
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentDepositVerificationScreen()
            }
            .store(in: &cancellables)
    }
    
    private func presentDepositVerificationScreen() {
        
        let depositVerificationViewModel: DepositVerificationViewModelProtocol = MockDepositVerificationViewModel(bonusDepositData: viewModel.bonusDepositData)
        
        let depositVerificationViewController = DepositVerificationViewController(viewModel: depositVerificationViewModel)
        
        self.present(depositVerificationViewController, animated: true)
    }

    @objc private func didTapCancel() {
        self.dismiss(animated: true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let keyboardHeight = keyboardFrame.height
        depositButtonBottomConstraint.constant = -keyboardHeight + 20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        depositButtonBottomConstraint.constant = -20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
