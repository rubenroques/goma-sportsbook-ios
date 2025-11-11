//
//  PhoneLoginViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class PhoneLoginViewController: UIViewController {
    
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("login")
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 14)
        button.setTitleColor(StyleProvider.Color.highlightTertiary, for: .normal)
        return button
    }()
    
    private let logoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betsson_logo")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let headerView: PromotionalHeaderView
    private let highlightedTextView: HighlightedTextView
    private let phoneField: BorderedTextFieldView
    private let passwordField: BorderedTextFieldView

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("forgot_your_password"), for: .normal)
        button.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .bold, size: 14)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    private let loginButton: ButtonView
    
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
    
    private var viewModel: PhoneLoginViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: PhoneLoginViewModel) {
        self.viewModel = viewModel
        
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.phoneField = BorderedTextFieldView(viewModel: viewModel.phoneFieldViewModel)
        self.passwordField = BorderedTextFieldView(viewModel: viewModel.passwordFieldViewModel)
        self.loginButton = ButtonView(viewModel: viewModel.buttonViewModel)
        
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
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
        forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .primaryActionTriggered)

        setupDebugHelpers()
    }

    private func setupLayout() {
        // Fixed navigation header (stays at top)
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(closeButton)

        // ScrollView for scrollable content
        view.addSubview(scrollView)

        // Add all scrollable content to scrollView
        scrollView.addSubview(logoImageView)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(headerView)
        highlightedTextView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(highlightedTextView)

        let stackView = UIStackView(arrangedSubviews: [
            phoneField,
            passwordField,
            forgotPasswordButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(loginButton)

        // Loading view stays on top of everything
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            // Navigation view - fixed at top
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 40),

            navigationTitleLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 50),
            navigationTitleLabel.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -50),
            navigationTitleLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 40),

            // ScrollView - below navigation, fills remaining space
            scrollView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content inside scrollView - using contentLayoutGuide for vertical scrolling
            logoImageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            logoImageView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 20),

            headerView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -8),
            headerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 18),

            highlightedTextView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            highlightedTextView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            highlightedTextView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),

            stackView.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),

            loginButton.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            loginButton.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            // Loading view - covers entire view
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        
        loginButton.onButtonTapped = { [weak self] in
            
            self?.viewModel.loginUser()
            
        }
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.loginError = { [weak self] errorMessage in
            self?.showLoginErrorAlert(errorMessage: errorMessage)

        }
        
        viewModel.loginComplete = { [weak self] in
            self?.dismiss(animated: true)
        }
        
    }
    
    func showLoginErrorAlert(errorMessage: String) {
        
        let alert = UIAlertController(
            title: localized("login_error_title"),
            message: errorMessage,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: localized("ok"),
            style: .default
        )
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }

    @objc private func didTapCloseButton() {
        self.dismiss(animated: true)
    }

    @objc private func didTapForgotPassword() {
        let phonePasswordRecoverViewModel = PhonePasswordCodeResetViewModel()

        let phonePasswordRecoverViewController = PhonePasswordCodeResetViewController(viewModel: phonePasswordRecoverViewModel)

        self.navigationController?.pushViewController(phonePasswordRecoverViewController, animated: true)
    }
    
    // MARK: - Debug Helpers
    
    private func setupDebugHelpers() {
        #if DEBUG
        // Make navigation title label tappable for debug
        navigationTitleLabel.isUserInteractionEnabled = true
        let debugTitleTap = UITapGestureRecognizer(target: self, action: #selector(didTapDebugFormFill))
        debugTitleTap.numberOfTapsRequired = 3
        navigationTitleLabel.addGestureRecognizer(debugTitleTap)
        #endif
    }
    
    @objc private func didTapDebugFormFill() {
        #if DEBUG
        // Get current phone text from viewModel
        let currentPhone = viewModel.phoneFieldViewModel.textPublisher
            .first()
            .eraseToAnyPublisher()
        
        var phoneToSet = ""
        var passwordToSet = ""
        
        // Use Combine to get the current text value
        var cancellable: AnyCancellable?
        cancellable = currentPhone
            .sink { phone in
                if phone.isEmpty {
                    // First tap: Fill with the provided credentials
                    phoneToSet = "699198921"
                    passwordToSet = "1234"
                }
                else if phone == "666999005" {
                    // Second tap: Alternative test account
                    phoneToSet = "123456789"
                    passwordToSet = "test123"
                }
                else if phone == "123456789" {
                    // Third tap: Another test account
                    phoneToSet = "+237987654321"
                    passwordToSet = "debug123"
                }
                else {
                    // Reset to first credentials
                    phoneToSet = "666999005"
                    passwordToSet = "4050"
                }
                
                // Update the text fields through their view models
                self.viewModel.phoneFieldViewModel.updateText(phoneToSet)
                self.viewModel.passwordFieldViewModel.updateText(passwordToSet)
                
                cancellable?.cancel()
            }
        #endif
    }
}
