//
//  BorderedTextFieldViewController.swift
//  TestCase
//
//  Created by Ruben Roques on 19/05/2025.
//

import UIKit
import GomaUI
import Combine

class BorderedTextFieldViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private var textFieldViewModels: [MockBorderedTextFieldViewModel] = []
    private var textFields: [BorderedTextFieldView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTextFields()
        setupValidationObservation()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        
        // Content view setup
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Add description
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "BorderedTextFieldView with unified visual states and single animatable placeholder. The placeholder serves as both label (when floating) and placeholder (when centered). Each field demonstrates a different visual state: idle, focused, error, or disabled. Features custom border with gap behind floating labels."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        descriptionLabel.textColor = StyleProvider.Color.textColor
        stackView.addArrangedSubview(descriptionLabel)
        
        // Add separator
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.secondaryColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }
    
    private func setupTextFields() {
        // Create various text field configurations showcasing different visual states
        let fieldConfigurations = [
            ("Phone Number (Idle State)", MockBorderedTextFieldViewModel.phoneNumberField),
            ("Password (Idle State)", MockBorderedTextFieldViewModel.passwordField),
            ("Email (Focused State)", MockBorderedTextFieldViewModel.focusedField),
            ("Full Name (Idle State)", MockBorderedTextFieldViewModel.nameField),
            ("Email with Error State", MockBorderedTextFieldViewModel.errorField),
            ("Disabled Field", MockBorderedTextFieldViewModel.disabledField)
        ]
        
        for (title, viewModel) in fieldConfigurations {
            // Add section label
            let sectionLabel = UILabel()
            sectionLabel.text = title
            sectionLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
            sectionLabel.textColor = StyleProvider.Color.secondaryColor
            stackView.addArrangedSubview(sectionLabel)
            
            // Create text field
            let textFieldView = BorderedTextFieldView(viewModel: viewModel)
            textFieldView.translatesAutoresizingMaskIntoConstraints = false
            
            // Handle text changes
            textFieldView.onTextChanged = { [weak self] text in
                self?.handleTextChange(text)
            }
            
            // Handle focus changes
            textFieldView.onFocusChanged = { [weak self] focused in
                self?.handleFocusChange(focused)
            }
            
            stackView.addArrangedSubview(textFieldView)
            textFields.append(textFieldView)
            textFieldViewModels.append(viewModel)
        }
        
        // Add form validation section
        addFormValidationSection()
        
        // Add visual state controls section
        addVisualStateControlsSection()
    }
    
    private func addFormValidationSection() {
        // Add spacing
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let sectionTitle = UILabel()
        sectionTitle.text = "Form Validation Demo"
        sectionTitle.font = StyleProvider.fontWith(type: .bold, size: 18)
        sectionTitle.textColor = StyleProvider.Color.textColor
        stackView.addArrangedSubview(sectionTitle)
        
        // Add validation status label
        let validationLabel = UILabel()
        validationLabel.tag = 999 // For easy reference
        validationLabel.text = "Fill required fields without errors to enable submit"
        validationLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        validationLabel.textColor = StyleProvider.Color.secondaryColor
        validationLabel.numberOfLines = 0
        stackView.addArrangedSubview(validationLabel)
        
        // Add submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Form", for: .normal)
        submitButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        submitButton.backgroundColor = StyleProvider.Color.primaryColor
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.isEnabled = false
        submitButton.alpha = 0.6
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        stackView.addArrangedSubview(submitButton)
    }
    
    private func addVisualStateControlsSection() {
        // Add spacing
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let sectionTitle = UILabel()
        sectionTitle.text = "Visual State Controls"
        sectionTitle.font = StyleProvider.fontWith(type: .bold, size: 18)
        sectionTitle.textColor = StyleProvider.Color.textColor
        stackView.addArrangedSubview(sectionTitle)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Test the unified visual state system - states are mutually exclusive:"
        subtitleLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        subtitleLabel.textColor = StyleProvider.Color.secondaryColor
        subtitleLabel.numberOfLines = 0
        stackView.addArrangedSubview(subtitleLabel)
        
        // Add control buttons
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        
        let toggleErrorButton = createControlButton(title: "Toggle Error on First Field", action: #selector(toggleErrorOnFirstField))
        let toggleDisabledButton = createControlButton(title: "Toggle Disabled on Second Field", action: #selector(toggleDisabledOnSecondField))
        let setAllIdleButton = createControlButton(title: "Set All Fields to Idle", action: #selector(setAllFieldsIdle))
        let setAllFocusedButton = createControlButton(title: "Set All Fields to Focused", action: #selector(setAllFieldsFocused))
        let fillSampleButton = createControlButton(title: "Fill Sample Data", action: #selector(fillSampleData))
        
        buttonStackView.addArrangedSubview(toggleErrorButton)
        buttonStackView.addArrangedSubview(toggleDisabledButton)
        buttonStackView.addArrangedSubview(setAllIdleButton)
        buttonStackView.addArrangedSubview(setAllFocusedButton)
        buttonStackView.addArrangedSubview(fillSampleButton)
        
        stackView.addArrangedSubview(buttonStackView)
    }
    
    private func createControlButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .regular, size: 14)
        button.backgroundColor = StyleProvider.Color.backgroundColor
        button.setTitleColor(StyleProvider.Color.primaryColor, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = StyleProvider.Color.primaryColor.cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        return button
    }
    
    private func setupValidationObservation() {
        // Get relevant text field publishers for form validation
        guard textFieldViewModels.count >= 3 else { return }
        
        let phonePublisher = textFieldViewModels[0].textPublisher
        let passwordPublisher = textFieldViewModels[1].textPublisher
        let emailPublisher = textFieldViewModels[2].textPublisher
        
        // Also observe visual states to ensure no errors
        let phoneVisualStatePublisher = textFieldViewModels[0].visualStatePublisher
        let passwordVisualStatePublisher = textFieldViewModels[1].visualStatePublisher
        let emailVisualStatePublisher = textFieldViewModels[2].visualStatePublisher
        
        // Combine publishers for real-time form validation
        Publishers.CombineLatest3(
            Publishers.CombineLatest(phonePublisher, phoneVisualStatePublisher),
            Publishers.CombineLatest(passwordPublisher, passwordVisualStatePublisher),
            Publishers.CombineLatest(emailPublisher, emailVisualStatePublisher)
        )
        .map { phoneData, passwordData, emailData in
            let (phoneText, phoneState) = phoneData
            let (passwordText, passwordState) = passwordData
            let (emailText, emailState) = emailData
            
            // Check if all required fields have text and no errors
            let hasRequiredText = !phoneText.isEmpty && !passwordText.isEmpty && !emailText.isEmpty
            let hasNoErrors = !phoneState.isError && !passwordState.isError && !emailState.isError
            let allEnabled = !phoneState.isDisabled && !passwordState.isDisabled && !emailState.isDisabled
            
            return hasRequiredText && hasNoErrors && allEnabled
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isValid in
            self?.updateFormValidation(isValid: isValid)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Event Handlers
    private func handleTextChange(_ text: String) {
        print("Text changed for: \(text)")
    }
    
    private func handleFocusChange(_ focused: Bool) {
        print("Focus changed for: \(focused)")
    }
    
    private func updateFormValidation(isValid: Bool) {
        guard let submitButton = stackView.arrangedSubviews.first(where: { $0 is UIButton && ($0 as! UIButton).title(for: .normal) == "Submit Form" }) as? UIButton,
              let validationLabel = stackView.viewWithTag(999) as? UILabel else { return }
        
        submitButton.isEnabled = isValid
        submitButton.alpha = isValid ? 1.0 : 0.6
        
        validationLabel.text = isValid ? "Form is valid - ready to submit!" : "Fill required fields without errors to enable submit"
        validationLabel.textColor = isValid ? StyleProvider.Color.successColor : StyleProvider.Color.secondaryColor
    }
    
    @objc private func submitButtonTapped() {
        let alert = UIAlertController(title: "Form Submitted", message: "All validation passed successfully with unified visual states!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func toggleErrorOnFirstField() {
        guard !textFieldViewModels.isEmpty else { return }
        let firstViewModel = textFieldViewModels[0]
        
        switch firstViewModel.currentVisualState {
        case .error:
            firstViewModel.clearError()
        default:
            firstViewModel.setError("This field has an error")
        }
    }
    
    @objc private func toggleDisabledOnSecondField() {
        guard textFieldViewModels.count > 1 else { return }
        let secondViewModel = textFieldViewModels[1]
        
        switch secondViewModel.currentVisualState {
        case .disabled:
            secondViewModel.setEnabled(true)
        default:
            secondViewModel.setEnabled(false)
        }
    }
    
    @objc private func setAllFieldsIdle() {
        textFieldViewModels.forEach { viewModel in
            viewModel.setVisualState(.idle)
        }
    }
    
    @objc private func setAllFieldsFocused() {
        textFieldViewModels.forEach { viewModel in
            viewModel.setVisualState(.focused)
        }
    }
    
    @objc private func fillSampleData() {
        guard textFieldViewModels.count >= 4 else { return }
        
        textFieldViewModels[0].updateText("+1 555 123 4567") // Phone
        textFieldViewModels[1].updateText("SecurePass123!") // Password
        textFieldViewModels[2].updateText("user@example.com") // Email
        textFieldViewModels[3].updateText("John Doe") // Name
        
        // Clear any existing errors and set to idle state
        textFieldViewModels.forEach { viewModel in
            viewModel.setVisualState(.idle)
        }
    }
}

// MARK: - Visual State Extension
private extension BorderedTextFieldVisualState {
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    var isDisabled: Bool {
        if case .disabled = self { return true }
        return false
    }
} 
