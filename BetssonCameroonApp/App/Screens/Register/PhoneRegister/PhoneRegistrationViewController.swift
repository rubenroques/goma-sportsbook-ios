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
        label.text = localized("register")
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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let componentsBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let componentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var phonePrefixField: BorderedTextFieldView?
    private var phoneField: BorderedTextFieldView?
    private var passwordField: BorderedTextFieldView?
    private var firstNameField: BorderedTextFieldView?
    private var lastNameField: BorderedTextFieldView?
    private var birthDateField: BorderedTextFieldView?
    private var termsView: TermsAcceptanceView?
    private var promoCodeField: BorderedTextFieldView?
    private let createAccountButton: ButtonView

    // Date picker for birth date input
    private var birthDatePicker: UIDatePicker?

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
    
    private var viewModel: PhoneRegistrationViewModelProtocol

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PhoneRegistrationViewModelProtocol) {
        self.viewModel = viewModel
        self.headerView = PromotionalHeaderView(viewModel: viewModel.headerViewModel)
        self.highlightedTextView = HighlightedTextView(viewModel: viewModel.highlightedTextViewModel)
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
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)
        
        viewModel.isLoadingConfigPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingConfig in
                
                if !isLoadingConfig {
                    self?.setupComponentsLayout()
                }
            })
            .store(in: &cancellables)
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
        scrollView.addSubview(componentsBaseView)
        componentsBaseView.addSubview(componentsStackView)

        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(createAccountButton)

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

            componentsBaseView.topAnchor.constraint(equalTo: highlightedTextView.bottomAnchor, constant: 20),
            componentsBaseView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            componentsBaseView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),

            componentsStackView.topAnchor.constraint(equalTo: componentsBaseView.topAnchor),
            componentsStackView.leadingAnchor.constraint(equalTo: componentsBaseView.leadingAnchor),
            componentsStackView.trailingAnchor.constraint(equalTo: componentsBaseView.trailingAnchor),

            createAccountButton.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            createAccountButton.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            createAccountButton.topAnchor.constraint(equalTo: componentsBaseView.bottomAnchor, constant: 30),
            createAccountButton.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            // Loading view - covers entire view
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupComponentsLayout() {

        if let phoneFieldViewModel = viewModel.phoneFieldViewModel {
            let phoneField = BorderedTextFieldView(viewModel: phoneFieldViewModel)
            self.phoneField = phoneField
            componentsStackView.addArrangedSubview(phoneField)
        }
        
        if let passwordFieldViewModel = viewModel.passwordFieldViewModel {
            let passwordField = BorderedTextFieldView(viewModel: passwordFieldViewModel)
            self.passwordField = passwordField
            componentsStackView.addArrangedSubview(passwordField)
        }

        if let firstNameFieldViewModel = viewModel.firstNameFieldViewModel {
            let firstNameField = BorderedTextFieldView(viewModel: firstNameFieldViewModel)
            self.firstNameField = firstNameField
            componentsStackView.addArrangedSubview(firstNameField)
        }

        if let lastNameFieldViewModel = viewModel.lastNameFieldViewModel {
            let lastNameField = BorderedTextFieldView(viewModel: lastNameFieldViewModel)
            self.lastNameField = lastNameField
            componentsStackView.addArrangedSubview(lastNameField)
        }

        if let birthDateFieldViewModel = viewModel.birthDateFieldViewModel {
            let birthDateField = BorderedTextFieldView(viewModel: birthDateFieldViewModel)
            self.birthDateField = birthDateField

            // Setup date picker immediately (before field is added to view)
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.maximumDate = Date() // Can't be in the future

            // Set min/max dates from registration config
            if let birthDateMinMax = viewModel.birthDateMinMax {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")

                if let minDate = formatter.date(from: birthDateMinMax.min) {
                    datePicker.minimumDate = minDate
                }
                if let maxDate = formatter.date(from: birthDateMinMax.max) {
                    datePicker.maximumDate = maxDate
                    // Set initial date to max date (youngest allowed age)
                    datePicker.date = maxDate
                }
            }

            // Add value changed handler
            datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

            // Create toolbar with Done button
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.barStyle = .default
            toolbar.isTranslucent = true

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: localized("done"), style: .done, target: self, action: #selector(datePickerDone))
            toolbar.items = [flexSpace, doneButton]

            // Set custom input view BEFORE field is added to view hierarchy
            birthDateField.setCustomInputView(datePicker, accessoryView: toolbar)
            self.birthDatePicker = datePicker

            // Simplified closure - just show the picker (inputView already set)
            birthDateField.onRequestCustomInput = { [weak self] in
                self?.birthDateField?.becomeFirstResponder()
            }

            componentsStackView.addArrangedSubview(birthDateField)
        }

        if let termsViewModel = viewModel.termsViewModel {
            let termsView = TermsAcceptanceView(viewModel: termsViewModel)
            self.termsView = termsView
            termsView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(termsView)

            NSLayoutConstraint.activate([
                termsView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
                termsView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
                termsView.topAnchor.constraint(equalTo: componentsStackView.bottomAnchor, constant: 36)
            ])

            // Add promo code field after terms (per config order)
            if let promoCodeFieldViewModel = viewModel.promoCodeFieldViewModel {
                let promoCodeField = BorderedTextFieldView(viewModel: promoCodeFieldViewModel)
                self.promoCodeField = promoCodeField
                promoCodeField.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(promoCodeField)

                NSLayoutConstraint.activate([
                    promoCodeField.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
                    promoCodeField.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
                    promoCodeField.topAnchor.constraint(equalTo: termsView.bottomAnchor, constant: 20),
                    promoCodeField.bottomAnchor.constraint(equalTo: componentsBaseView.bottomAnchor)
                ])
            } else {
                // No promo code field, tie terms to bottom
                termsView.bottomAnchor.constraint(equalTo: componentsBaseView.bottomAnchor).isActive = true
            }
        }
        
        self.componentsBaseView.setNeedsLayout()
        self.componentsBaseView.layoutIfNeeded()
        
        setupBindings()
    }
    
    // MARK: Binding
    private func setupBindings() {
        
        createAccountButton.onButtonTapped = { [weak self] in
            
            self?.viewModel.registerUser()
        }
        
        if let termsView = self.termsView {
            termsView.onTermsLinkTapped = { [weak self] in
                if let termsData = self?.viewModel.extractedTermsHTMLData?.extractedLinks.first(where: {
                    $0.type == .terms
                }) {
                    self?.openTermsURL(urlString: termsData.url)
                }
            }
            
            termsView.onPrivacyLinkTapped = { [weak self] in
                if let privacyData = self?.viewModel.extractedTermsHTMLData?.extractedLinks.first(where: {
                    $0.type == .privacyPolicy
                }) {
                    self?.openTermsURL(urlString: privacyData.url)
                }
                
            }
            
            termsView.onCookiesLinkTapped = { [weak self] in
                if let cookiesData = self?.viewModel.extractedTermsHTMLData?.extractedLinks.first(where: {
                    $0.type == .cookies
                }) {
                    self?.openTermsURL(urlString: cookiesData.url)
                }
            }
            
            termsView.onCheckboxToggled = { isChecked in
                termsView.showError(!isChecked)
            }
        }
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        viewModel.registerComplete = { [weak self] in
            self?.showRegisterSuccessAlert()

        }
        
        viewModel.registerError = { [weak self] errorMessage in
            self?.showRegisterErrorAlert(errorMessage: errorMessage)
        }
        
    }
    
    func showRegisterSuccessAlert() {
        
        let alert = UIAlertController(
            title: localized("register_success_title"),
            message: localized("register_success_message"),
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: localized("ok"),
            style: .default
        ) { [weak self] _ in
            
            self?.dismiss(animated: true)
            self?.viewModel.showBonusOnRegister?()
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func showRegisterErrorAlert(errorMessage: String) {
        
        let alert = UIAlertController(
            title: localized("register_error_title"),
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

    // MARK: - Date Picker Handlers

    @objc private func datePickerValueChanged(_ picker: UIDatePicker) {
        // Update text field as user scrolls through dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let dateString = formatter.string(from: picker.date)
        viewModel.birthDateFieldViewModel?.updateText(dateString)
    }

    @objc private func datePickerDone() {
        // Dismiss date picker
        birthDateField?.resignFirstResponder()
    }

    // MARK: Actions
    @objc private func didTapCloseButton() {
        self.dismiss(animated: true)
    }
}
