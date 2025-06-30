//
//  PhoneVerificationViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2025.
//

import Foundation
import UIKit
import GomaUI

class PhoneVerificationViewController: UIViewController {
    private let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Verify phone"
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
    
    private let viewModel: PhoneVerificationViewModelProtocol

    init(viewModel: PhoneVerificationViewModelProtocol = MockPhoneVerificationViewModel()) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
        self.pinEntryView = PinDigitEntryView(viewModel: viewModel.pinEntryViewModel)
        self.resendCodeCountdownView = ResendCodeCountdownView(viewModel: viewModel.resendCodeCountdownViewModel)
        self.verifyButton = ButtonView(viewModel: viewModel.buttonViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
        
        changeButton.addTarget(self, action: #selector(didTapChangeButton), for: .primaryActionTriggered)

    }

    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(navigationTitleLabel)
        navigationView.addSubview(closeButton)

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
            verifyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    @objc private func didTapCloseButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func didTapChangeButton() {
        print("CHANGE SOMETHING!")
    }
}
