//
//  PhoneRegistrationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 25/06/2025.
//

import Foundation
import UIKit
import GomaUI
import Combine

class PhoneRegistrationViewController: UIViewController {

    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Register"
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
    private let headerView: PromotionalHeaderView
    private let highlightedTextView: HighlightedTextView
    private let phoneField: BorderedTextFieldView
    private let passwordField: BorderedTextFieldView
    private let referralField: BorderedTextFieldView
    private let termsView: TermsAcceptanceView
    private let createAccountButton: ButtonView
    
    private let viewModel: PhoneRegistrationViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PhoneRegistrationViewModelProtocol) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.phoneField = BorderedTextFieldView(viewModel: viewModel.phoneFieldViewModel)
        self.passwordField = BorderedTextFieldView(viewModel: viewModel.passwordFieldViewModel)
        self.referralField = BorderedTextFieldView(viewModel: viewModel.referralFieldViewModel)
        self.termsView = TermsAcceptanceView(viewModel: viewModel.termsViewModel)
        self.createAccountButton = ButtonView(viewModel: viewModel.buttonViewModel)
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
        
    }

    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(closeButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        highlightedTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highlightedTextView)
        
        let stackView = UIStackView(arrangedSubviews: [
            phoneField,
            passwordField,
            referralField,
        ])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        
        termsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(termsView)
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createAccountButton)
        
        NSLayoutConstraint.activate([
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
            
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            headerView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 18),
            
            highlightedTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            highlightedTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            highlightedTextView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            
            stackView.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            termsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            termsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            termsView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 36),
            
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createAccountButton.topAnchor.constraint(greaterThanOrEqualTo: termsView.bottomAnchor, constant: 30),
            createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Binding
    private func setupBindings() {
        
        createAccountButton.onButtonTapped = { [weak self] in
            self?.openFirstDepositPromotions()
        }
        
        termsView.onTermsLinkTapped = { [weak self] in
            if let termsData = Env.legislationManager.extractedTermsHTMLData?.extractedLinks.first(where: {
                $0.type == .terms
            }) {
                self?.openTermsURL(urlString: termsData.url)
            }
        }
        
        termsView.onPrivacyLinkTapped = { [weak self] in
            if let privacyData = Env.legislationManager.extractedTermsHTMLData?.extractedLinks.first(where: {
                $0.type == .privacyPolicy
            }) {
                self?.openTermsURL(urlString: privacyData.url)
            }
            
        }
        
        termsView.onCookiesLinkTapped = { [weak self] in
            if let cookiesData = Env.legislationManager.extractedTermsHTMLData?.extractedLinks.first(where: {
                $0.type == .cookies
            }) {
                self?.openTermsURL(urlString: cookiesData.url)
            }
        }
    }
    
    private func openFirstDepositPromotions() {
        
        let firstDepositPromotions = FirstDepositPromotionsViewController()
        
        self.present(firstDepositPromotions, animated: true)
    }
    
    private func openTermsURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacyURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openCookiesURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: Actions
    @objc private func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}
