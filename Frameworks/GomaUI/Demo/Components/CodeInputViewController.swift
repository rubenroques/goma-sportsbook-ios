import UIKit
import GomaUI
import Combine

class CodeInputViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    private var viewModels: [MockCodeInputViewModel] = []
    private var codeInputViews: [CodeInputView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCodeInputViews()
        setupControlsSection()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Code Input"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        initConstraints()
        
        // Add description
        let descriptionLabel = createDescriptionLabel()
        stackView.addArrangedSubview(descriptionLabel)
        
        // Add separator
        let separator = createSeparator()
        stackView.addArrangedSubview(separator)
    }
    
    private func setupCodeInputViews() {
        // Create various code input configurations showcasing different states
        let inputConfigurations: [(String, MockCodeInputViewModel)] = [
            ("Default State (Empty)", MockCodeInputViewModel.defaultMock()),
            ("With Pre-filled Code", MockCodeInputViewModel.withCodeMock()),
            ("Loading State", MockCodeInputViewModel.loadingMock()),
            ("Error State", MockCodeInputViewModel.errorMock()),
            ("Custom Button Text", MockCodeInputViewModel(
                code: "SAVE20",
                placeholder: "Enter promo code",
                buttonTitle: "Apply Promo"
            ))
        ]
        
        for (title, viewModel) in inputConfigurations {
            // Add section label
            let sectionLabel = createSectionLabel(with: title)
            stackView.addArrangedSubview(sectionLabel)
            
            // Create code input view
            let codeInputView = CodeInputView(viewModel: viewModel)
            codeInputView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add container for proper spacing and visual separation
            let containerView = createInputContainer()
            containerView.addSubview(codeInputView)
            
            NSLayoutConstraint.activate([
                codeInputView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                codeInputView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                codeInputView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                codeInputView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
            ])
            
            stackView.addArrangedSubview(containerView)
            codeInputViews.append(codeInputView)
            viewModels.append(viewModel)
        }
        
        // Add interactive demo section
        addInteractiveDemoSection()
    }
    
    private func addInteractiveDemoSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let sectionTitle = createSectionTitle(with: "Interactive Demo")
        stackView.addArrangedSubview(sectionTitle)
        
        // Add description
        let descriptionLabel = createSubDescriptionLabel()
        stackView.addArrangedSubview(descriptionLabel)
        
        // Create interactive demo view
        let interactiveViewModel = MockCodeInputViewModel(
            code: "",
            placeholder: "Enter booking code",
            buttonTitle: "Load Betslip"
        )
        
        let interactiveView = CodeInputView(viewModel: interactiveViewModel)
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        
        let interactiveContainer = createInputContainer()
        interactiveContainer.addSubview(interactiveView)
        
        NSLayoutConstraint.activate([
            interactiveView.leadingAnchor.constraint(equalTo: interactiveContainer.leadingAnchor, constant: 12),
            interactiveView.trailingAnchor.constraint(equalTo: interactiveContainer.trailingAnchor, constant: -12),
            interactiveView.topAnchor.constraint(equalTo: interactiveContainer.topAnchor, constant: 12),
            interactiveView.bottomAnchor.constraint(equalTo: interactiveContainer.bottomAnchor, constant: -12)
        ])
        
        stackView.addArrangedSubview(interactiveContainer)
        
        // Store for controls
        codeInputViews.append(interactiveView)
        viewModels.append(interactiveViewModel)
    }
    
    private func setupControlsSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let controlsTitle = createSectionTitle(with: "State Controls")
        stackView.addArrangedSubview(controlsTitle)
        
        // Add controls description
        let controlsDescription = UILabel()
        controlsDescription.text = "Test different states and interactions on the interactive demo above:"
        controlsDescription.font = StyleProvider.fontWith(type: .regular, size: 14)
        controlsDescription.textColor = StyleProvider.Color.secondaryColor
        controlsDescription.numberOfLines = 0
        stackView.addArrangedSubview(controlsDescription)
        
        // Add control buttons
        let buttonStackView = createButtonStackView()
        
        let setLoadingButton = createControlButton(title: "Set Loading State", action: #selector(setLoadingState))
        let setErrorButton = createControlButton(title: "Set Error State", action: #selector(setErrorState))
        let clearErrorButton = createControlButton(title: "Clear Error State", action: #selector(clearErrorState))
        let fillCodeButton = createControlButton(title: "Fill Sample Code", action: #selector(fillSampleCode))
        let clearCodeButton = createControlButton(title: "Clear Code", action: #selector(clearCode))
        let toggleButtonTextButton = createControlButton(title: "Change Button Text", action: #selector(toggleButtonText))
        let simulateSubmitButton = createControlButton(title: "Simulate Submit", action: #selector(simulateSubmit))
        let testValidationButton = createControlButton(title: "Test Validation Flow", action: #selector(testValidationFlow))
        
        buttonStackView.addArrangedSubview(setLoadingButton)
        buttonStackView.addArrangedSubview(setErrorButton)
        buttonStackView.addArrangedSubview(clearErrorButton)
        buttonStackView.addArrangedSubview(fillCodeButton)
        buttonStackView.addArrangedSubview(clearCodeButton)
        buttonStackView.addArrangedSubview(toggleButtonTextButton)
        buttonStackView.addArrangedSubview(simulateSubmitButton)
        buttonStackView.addArrangedSubview(testValidationButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        // Add state observation section
        addStateObservationSection()
        
        // Add validation demo section
        addValidationDemoSection()
    }
    
    private func addStateObservationSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let observationTitle = createSectionTitle(with: "State Observation")
        stackView.addArrangedSubview(observationTitle)
        
        // Add status label
        let statusLabel = UILabel()
        statusLabel.tag = 999 // For easy reference
        statusLabel.text = "Watching interactive demo state changes..."
        statusLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        statusLabel.textColor = StyleProvider.Color.secondaryColor
        statusLabel.numberOfLines = 0
        statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        statusLabel.layer.cornerRadius = 8
        statusLabel.layer.masksToBounds = true
        statusLabel.textAlignment = .center
        
        // Add padding to status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        let statusContainer = UIView()
        statusContainer.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 12),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -12)
        ])
        
        stackView.addArrangedSubview(statusContainer)
        
        // Setup state observation for the last (interactive) view model
        if let interactiveViewModel = viewModels.last {
            interactiveViewModel.dataPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.updateStateObservation(with: data)
                }
                .store(in: &cancellables)
        }
    }
    
    private func addValidationDemoSection() {
        // Add spacing
        let spacer = createSpacer(height: 20)
        stackView.addArrangedSubview(spacer)
        
        // Add section title
        let validationTitle = createSectionTitle(with: "Validation Demo")
        stackView.addArrangedSubview(validationTitle)
        
        // Add validation description
        let validationDescription = UILabel()
        validationDescription.text = "This section demonstrates code validation patterns with different requirements:"
        validationDescription.font = StyleProvider.fontWith(type: .regular, size: 14)
        validationDescription.textColor = StyleProvider.Color.secondaryColor
        validationDescription.numberOfLines = 0
        stackView.addArrangedSubview(validationDescription)
        
        // Create validation demo views with different patterns
        let validationConfigs: [(String, String, String, (String) -> Bool)] = [
            ("Numeric Only (4-6 digits)", "Enter PIN", "Verify PIN", { code in
                let numericPattern = "^[0-9]{4,6}$"
                return code.range(of: numericPattern, options: .regularExpression) != nil
            }),
            ("Alphanumeric (6-8 chars)", "Enter booking code", "Load Betslip", { code in
                let alphanumericPattern = "^[A-Z0-9]{6,8}$"
                return code.uppercased().range(of: alphanumericPattern, options: .regularExpression) != nil
            }),
            ("Email Format", "Enter email", "Validate", { code in
                let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                return code.range(of: emailPattern, options: .regularExpression) != nil
            })
        ]
        
        for (title, placeholder, buttonText, validator) in validationConfigs {
            // Add validation section label
            let validationLabel = createSectionLabel(with: title)
            stackView.addArrangedSubview(validationLabel)
            
            // Create validation input
            let validationViewModel = MockCodeInputViewModel(
                placeholder: placeholder,
                buttonTitle: buttonText
            )
            
            let validationView = CodeInputView(viewModel: validationViewModel)
            validationView.translatesAutoresizingMaskIntoConstraints = false
            
            let validationContainer = createInputContainer()
            validationContainer.addSubview(validationView)
            
            NSLayoutConstraint.activate([
                validationView.leadingAnchor.constraint(equalTo: validationContainer.leadingAnchor, constant: 12),
                validationView.trailingAnchor.constraint(equalTo: validationContainer.trailingAnchor, constant: -12),
                validationView.topAnchor.constraint(equalTo: validationContainer.topAnchor, constant: 12),
                validationView.bottomAnchor.constraint(equalTo: validationContainer.bottomAnchor, constant: -12)
            ])
            
            stackView.addArrangedSubview(validationContainer)
            
            // Set up real-time validation
            validationViewModel.dataPublisher
                .map { $0.code }
                .removeDuplicates()
                .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
                .sink { [weak validationViewModel] code in
                    guard let viewModel = validationViewModel else { return }
                    
                    if !code.isEmpty {
                        if validator(code) {
                            viewModel.clearError()
                        } else {
                            switch title {
                            case let str where str.contains("Numeric"):
                                viewModel.setError("Must be 4-6 digits only")
                            case let str where str.contains("Alphanumeric"):
                                viewModel.setError("Must be 6-8 alphanumeric characters")
                            case let str where str.contains("Email"):
                                viewModel.setError("Must be valid email format")
                            default:
                                viewModel.setError("Invalid format")
                            }
                        }
                    } else {
                        viewModel.clearError()
                    }
                }
                .store(in: &cancellables)
            
            codeInputViews.append(validationView)
            viewModels.append(validationViewModel)
        }
    }
    
    // MARK: - Event Handlers
    @objc private func setLoadingState() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.setLoading(true)
        
        // Auto-clear after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            interactiveViewModel.setLoading(false)
        }
    }
    
    @objc private func setErrorState() {
        guard let interactiveViewModel = viewModels.last else { return }
        let errorMessages = [
            "Booking code not found",
            "Code has expired",
            "Invalid format - code must be 6-8 characters",
            "Network error - please try again",
            "This booking code is already used"
        ]
        let randomError = errorMessages.randomElement() ?? "Unknown error"
        interactiveViewModel.setError(randomError)
    }
    
    @objc private func clearErrorState() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.clearError()
    }
    
    @objc private func fillSampleCode() {
        guard let interactiveViewModel = viewModels.last else { return }
        let sampleCodes = ["BA2672", "XY9834", "QR5671", "MN4829", "PROMO123"]
        let randomCode = sampleCodes.randomElement() ?? "BA2672"
        interactiveViewModel.updateCode(randomCode)
        interactiveViewModel.clearError()
    }
    
    @objc private func clearCode() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.updateCode("")
        interactiveViewModel.clearError()
    }
    
    @objc private func toggleButtonText() {
        guard let interactiveViewModel = viewModels.last else { return }
        let buttonTexts = ["Load Betslip", "Apply Code", "Validate", "Submit", "Check Code"]
        
        // Get current button title from data
        let currentTitle = interactiveViewModel.currentData.buttonTitle
        let currentIndex = buttonTexts.firstIndex(of: currentTitle) ?? 0
        let nextIndex = (currentIndex + 1) % buttonTexts.count
        let nextTitle = buttonTexts[nextIndex]
        
        // Create new view model with updated button title (MockCodeInputViewModel doesn't have updateButtonTitle method)
        // We'll work within the constraints of the current interface
        print("Button text would change to: \(nextTitle)")
        
        // Show alert to demonstrate the functionality
        let alert = UIAlertController(
            title: "Button Text Changed",
            message: "In a production app, the button text would change to '\(nextTitle)'",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func simulateSubmit() {
        guard let interactiveViewModel = viewModels.last else { return }
        interactiveViewModel.onButtonTapped()
    }
    
    @objc private func testValidationFlow() {
        guard let interactiveViewModel = viewModels.last else { return }
        
        // Clear any existing state
        interactiveViewModel.clearError()
        interactiveViewModel.updateCode("")
        
        // Simulate typing an invalid code
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            interactiveViewModel.updateCode("X")
        }
        
        // Show error for invalid format
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            interactiveViewModel.setError("Code too short - minimum 6 characters")
        }
        
        // Continue typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            interactiveViewModel.updateCode("XY1234")
        }
        
        // Clear error and simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            interactiveViewModel.clearError()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            interactiveViewModel.setLoading(true)
        }
        
        // Simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            interactiveViewModel.setLoading(false)
            
            let alert = UIAlertController(
                title: "Validation Complete",
                message: "Code 'XY1234' validated successfully!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func updateStateObservation(with data: CodeInputData) {
        guard let statusLabel = stackView.viewWithTag(999) as? UILabel else { return }
        
        let stateText: String
        switch data.state {
        case .default:
            stateText = "DEFAULT"
        case .loading:
            stateText = "LOADING"
        case .error(let message):
            stateText = "ERROR: \(message)"
        }
        
        let enabledText = data.isButtonEnabled ? "ENABLED" : "DISABLED"
        
        statusLabel.text = """
        Code: "\(data.code)"
        Placeholder: "\(data.placeholder)"
        Button: "\(data.buttonTitle)"
        State: \(stateText)
        Button Status: \(enabledText)
        """
        
        // Update color based on state
        switch data.state {
        case .default:
            statusLabel.textColor = StyleProvider.Color.textColor
            statusLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        case .loading:
            statusLabel.textColor = StyleProvider.Color.primaryColor
            statusLabel.backgroundColor = StyleProvider.Color.primaryColor.withAlphaComponent(0.1)
        case .error:
            statusLabel.textColor = StyleProvider.Color.alertWarning
            statusLabel.backgroundColor = StyleProvider.Color.alertWarning.withAlphaComponent(0.1)
        }
    }
}

// MARK: - Subviews Initialization and Setup
extension CodeInputViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }
    
    private func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = "CodeInputView component for code entry with validation, error handling, and loading states. Features text input field, submit button, error display, and loading indicator. Supports various input types including booking codes, promo codes, and validation patterns."
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textColor = StyleProvider.Color.textColor
        return label
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.secondaryColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func createSectionLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.secondaryColor
        return label
    }
    
    private func createSectionTitle(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .bold, size: 18)
        label.textColor = StyleProvider.Color.textColor
        return label
    }
    
    private func createSubDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = "Enter code and test various states using the controls below:"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.secondaryColor
        label.numberOfLines = 0
        return label
    }
    
    private func createInputContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = StyleProvider.Color.backgroundColor
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = StyleProvider.Color.secondaryColor.withAlphaComponent(0.3).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    private func createSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        return spacer
    }
    
    private func createButtonStackView() -> UIStackView {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        return buttonStackView
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
    
    private func initConstraints() {
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
    }
}
