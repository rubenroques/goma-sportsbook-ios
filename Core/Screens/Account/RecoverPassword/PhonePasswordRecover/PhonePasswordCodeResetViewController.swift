//
//  PhonePasswordCodeResetViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class PhonePasswordCodeResetViewController: UIViewController {
    
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "back_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Forgot password"
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let headerView: PromotionalHeaderView
    private let highlightedTextView: HighlightedTextView
    private let phoneField: BorderedTextFieldView
    private let requestCodeButton: ButtonView
    
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
    private var requestCodeButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    private let viewModel: PhonePasswordCodeResetViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PhonePasswordCodeResetViewModelProtocol = MockPhonePasswordCodeResetViewModel()) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.phoneField = BorderedTextFieldView(viewModel: viewModel.phoneFieldViewModel)
        self.requestCodeButton = ButtonView(viewModel: viewModel.buttonViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupBindings()
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(backButton)
        navigationView.addSubview(navigationTitleLabel)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        highlightedTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highlightedTextView)
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(phoneField)
        requestCodeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(requestCodeButton)
        view.addSubview(loadingView)
        
        requestCodeButtonBottomConstraint = requestCodeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),

            backButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            navigationTitleLabel.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            headerView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 18),

            highlightedTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            highlightedTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            highlightedTextView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),

            phoneField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            phoneField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            phoneField.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 24),

            requestCodeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            requestCodeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            requestCodeButton.heightAnchor.constraint(equalToConstant: 48),
            requestCodeButtonBottomConstraint,
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        requestCodeButton.onButtonTapped = { [weak self] in
            self?.viewModel.requestPasswordResetCode()
        }
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.shouldVerifyCode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentPasswordCodeVerificationScreen()
            }
            .store(in: &cancellables)
    }
    
    private func presentPasswordCodeVerificationScreen() {
        let passwordCodeVerificationViewController = PhonePasswordCodeVerificationViewController()
        
        self.navigationController?.pushViewController(passwordCodeVerificationViewController, animated: true)
    }
    
    private func showLoading() {
        loadingView.isHidden = false
    }

    private func hideLoading() {
        loadingView.isHidden = true
    }

    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let keyboardHeight = keyboardFrame.height
        requestCodeButtonBottomConstraint.constant = -keyboardHeight + 20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        requestCodeButtonBottomConstraint.constant = -20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
