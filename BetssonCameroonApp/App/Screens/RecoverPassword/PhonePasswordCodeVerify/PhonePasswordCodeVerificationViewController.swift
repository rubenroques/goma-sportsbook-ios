//
//  PhonePasswordCodeVerificationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class PhonePasswordCodeVerificationViewController: UIViewController {
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Forgot Password"
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "back_icon"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let changeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("change"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 14)
        button.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    private let headerView: PromotionalHeaderView
    private let highlightedTextView: HighlightedTextView
    private let pinEntryView: PinDigitEntryView
    private let resendCodeCountdownView: ResendCodeCountdownView
    private let verifyButton: ButtonView
    
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
    private var verifyButtonBottomConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint()
        return constraint
    }()
    
    private let viewModel: PhonePasswordCodeVerificationViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PhonePasswordCodeVerificationViewModelProtocol) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.pinEntryView = PinDigitEntryView(viewModel: viewModel.pinEntryViewModel)
        self.resendCodeCountdownView = ResendCodeCountdownView(viewModel: viewModel.resendCodeCountdownViewModel)
        self.verifyButton = ButtonView(viewModel: viewModel.buttonViewModel)
        
        
        switch viewModel.resetPasswordType {
        case .forgot:
            self.navigationTitleLabel.text = "Forgot Password"
        case .change:
            self.navigationTitleLabel.text = "Change Password"
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

        changeButton.addTarget(self, action: #selector(didTapChangeButton), for: .primaryActionTriggered)
        
        pinEntryView.focusField(at: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(backButton)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        highlightedTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highlightedTextView)
        view.addSubview(changeButton)
        pinEntryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinEntryView)
        resendCodeCountdownView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resendCodeCountdownView)
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verifyButton)
        view.addSubview(loadingView)

        verifyButtonBottomConstraint = verifyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),

            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 50),
            navigationTitleLabel.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -50),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            backButton.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            headerView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 18),

            highlightedTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            highlightedTextView.trailingAnchor.constraint(equalTo: changeButton.leadingAnchor, constant: -30),
            highlightedTextView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            
            changeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            changeButton.heightAnchor.constraint(equalToConstant: 40),
            changeButton.centerYAnchor.constraint(equalTo: highlightedTextView.centerYAnchor),

            pinEntryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pinEntryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pinEntryView.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 24),
            pinEntryView.heightAnchor.constraint(equalToConstant: 60),
            
            resendCodeCountdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resendCodeCountdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resendCodeCountdownView.topAnchor.constraint(equalTo: pinEntryView.bottomAnchor, constant: 12),

            verifyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            verifyButton.topAnchor.constraint(greaterThanOrEqualTo: resendCodeCountdownView.bottomAnchor, constant: 30),
            verifyButtonBottomConstraint,
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        verifyButton.onButtonTapped = { [weak self] in
            self?.viewModel.requestPasswordChange()
        }
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.shouldPasswordChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hashKey in
                self?.presentPasswordChangeScreen(hashKey: hashKey)
            }
            .store(in: &cancellables)
        
        viewModel.showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func presentPasswordChangeScreen(hashKey: String) {
        let forgotPasswordViewModel = PhoneForgotPasswordViewModel(hashKey: hashKey, resetPasswordType: viewModel.resetPasswordType)
        
        let forgotPasswordViewController = PhoneForgotPasswordViewController(viewModel: forgotPasswordViewModel)
        
        self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
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
    
    @objc private func didTapChangeButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let keyboardHeight = keyboardFrame.height
        verifyButtonBottomConstraint.constant = -keyboardHeight + 20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        verifyButtonBottomConstraint.constant = -20

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

enum ResetPasswordType {
    case forgot
    case change
}
