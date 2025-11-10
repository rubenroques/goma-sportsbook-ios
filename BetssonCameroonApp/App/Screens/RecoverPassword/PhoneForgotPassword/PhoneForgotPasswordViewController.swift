//
//  PhoneForgotPasswordViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class PhoneForgotPasswordViewController: UIViewController {
    
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
        label.text = localized("forgot_password")
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let headerView: PromotionalHeaderView
    private let highlightedTextView: HighlightedTextView
    private let newPasswordField: BorderedTextFieldView
    private let confirmNewPasswordField: BorderedTextFieldView
    private let changePasswordButton: ButtonView
    
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
    private var changePasswordButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()

    private let viewModel: PhoneForgotPasswordViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PhoneForgotPasswordViewModelProtocol) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.newPasswordField = BorderedTextFieldView(viewModel: viewModel.newPasswordFieldViewModel)
        self.confirmNewPasswordField = BorderedTextFieldView(viewModel: viewModel.confirmNewPasswordFieldViewModel)
        self.changePasswordButton = ButtonView(viewModel: viewModel.buttonViewModel)
                
        switch viewModel.resetPasswordType {
        case .forgot:
            self.navigationTitleLabel.text = localized("forgot_password")
        case .change:
            self.navigationTitleLabel.text = localized("change_password")
        }
        
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
        newPasswordField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newPasswordField)
        confirmNewPasswordField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmNewPasswordField)
        changePasswordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changePasswordButton)
        view.addSubview(loadingView)
        
        changePasswordButtonBottomConstraint = changePasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

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

            newPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newPasswordField.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 24),
            
            confirmNewPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmNewPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmNewPasswordField.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 12),

            changePasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            changePasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 48),
            changePasswordButtonBottomConstraint,
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        changePasswordButton.onButtonTapped = { [weak self] in
            self?.viewModel.requestPasswordChange()
        }
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.passwordChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.presentPasswordChangedSuccessScreen()
            }
            .store(in: &cancellables)
        
        viewModel.showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func presentPasswordChangedSuccessScreen() {
        let phoneForgotPasswordSuccessViewModel = PhoneForgotPasswordSuccessViewModel(resetPasswordType: viewModel.resetPasswordType)
        
        let phoneForgotPasswordSuccessViewController = PhoneForgotPasswordSuccessViewController(viewModel: phoneForgotPasswordSuccessViewModel)
        
        self.navigationController?.pushViewController(phoneForgotPasswordSuccessViewController, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: localized("error"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default))
        present(alert, animated: true)
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
        changePasswordButtonBottomConstraint.constant = -keyboardHeight + 20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        changePasswordButtonBottomConstraint.constant = -20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
