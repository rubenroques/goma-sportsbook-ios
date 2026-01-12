import UIKit
import Combine
import SwiftUI

final public class BorderedTextFieldView: UIView {
    // MARK: - Private Properties
    private let containerView = UIView()
    private let textField = UITextField()
    private let floatingLabel = UILabel()
    private let suffixButton = UIButton()
    private let errorLabel = UILabel()
    private let prefixLabel = UILabel()
    
    // Custom border layer
    private let borderLayer = CAShapeLayer()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: BorderedTextFieldViewModelProtocol

    // Label animation constraints
    private var labelCenterYConstraint: NSLayoutConstraint!
    private var labelLeadingConstraint: NSLayoutConstraint!
    private var labelTopConstraint: NSLayoutConstraint!
    
    // Prefix constraints
    private var textFieldLeadingConstraint: NSLayoutConstraint!
    
    // Current visual state for internal tracking
    private var currentVisualState: BorderedTextFieldVisualState = .idle

    // MARK: - Public Properties
    public var onTextChanged: ((String) -> Void) = { _ in }
    public var onFocusChanged: ((Bool) -> Void) = { _ in }
    public var onRequestCustomInput: (() -> Void)?

    // MARK: - Constants
    private enum Constants {
        static let cornerRadius: CGFloat = 4.0
        static let borderWidth: CGFloat = 2.0
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 12.0
        static let labelAnimationDuration: TimeInterval = 0.2
        static let labelFloatedTopMargin: CGFloat = -8.0
        static let labelFloatedScale: CGFloat = 0.8
        static let suffixButtonSize: CGFloat = 24.0
        static let fieldHeight: CGFloat = 56.0
        static let errorLabelTopMargin: CGFloat = 4.0
    }

    // MARK: - Initialization
    public init(viewModel: BorderedTextFieldViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        renderInitialState()
        setupBindings()
        setupTextFieldDelegate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupSubviews() {
        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.backgroundColor = .clear
        addSubview(containerView)

        // Custom border setup
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = StyleProvider.Color.separatorLine.cgColor
        borderLayer.lineWidth = Constants.borderWidth
        containerView.layer.addSublayer(borderLayer)

        // Prefix label setup
        prefixLabel.translatesAutoresizingMaskIntoConstraints = false
        prefixLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        prefixLabel.textColor = StyleProvider.Color.textDisablePrimary
        prefixLabel.backgroundColor = .clear
        prefixLabel.isHidden = true
        prefixLabel.isUserInteractionEnabled = false // Allow touches to pass through
        prefixLabel.setContentHuggingPriority(.required, for: .horizontal)
        containerView.addSubview(prefixLabel)
        
        // Text field setup
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = StyleProvider.fontWith(type: .regular, size: 16)
        textField.textColor = StyleProvider.Color.textPrimary
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        containerView.addSubview(textField)

        // Floating label setup
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.backgroundColor = .clear
        containerView.addSubview(floatingLabel)

        // Suffix button setup (for password toggle)
        suffixButton.translatesAutoresizingMaskIntoConstraints = false
        suffixButton.tintColor = StyleProvider.Color.iconPrimary
        suffixButton.isHidden = true
        suffixButton.addTarget(self, action: #selector(suffixButtonTapped), for: .touchUpInside)
        containerView.addSubview(suffixButton)

        // Error label setup
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = StyleProvider.fontWith(type: .regular, size: 12)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        addSubview(errorLabel)

        setupConstraints()
        setupAccessibility()
        setupTapGesture()
        updatePrefixLabel()
    }

    private func setupConstraints() {
        // Container constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: Constants.fieldHeight)
        ])
        
        // Prefix label constraints
        NSLayoutConstraint.activate([
            prefixLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            prefixLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        // Text field constraints (with padding for suffix button area)
        textFieldLeadingConstraint = textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding)
        textFieldLeadingConstraint.isActive = true

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 24),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -(Constants.horizontalPadding + Constants.suffixButtonSize + 8))
        ])

        // Suffix button constraints (overlaying the text field)
        NSLayoutConstraint.activate([
            suffixButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            suffixButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            suffixButton.widthAnchor.constraint(equalToConstant: Constants.suffixButtonSize),
            suffixButton.heightAnchor.constraint(equalToConstant: Constants.suffixButtonSize)
        ])

        // Floating label constraints (will be animated)
        labelLeadingConstraint = floatingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding)
        labelCenterYConstraint = floatingLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        labelTopConstraint = floatingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.labelFloatedTopMargin)

        labelLeadingConstraint.isActive = true
        labelCenterYConstraint.isActive = true

        // Error label constraints
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: Constants.errorLabelTopMargin),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupAccessibility() {
        textField.accessibilityIdentifier = "borderedTextField.textField"
        floatingLabel.accessibilityIdentifier = "borderedTextField.label"
        suffixButton.accessibilityIdentifier = "borderedTextField.suffixButton"
        errorLabel.accessibilityIdentifier = "borderedTextField.errorLabel"

        suffixButton.accessibilityLabel = LocalizationProvider.string("toggle_password_visibility")
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(tapGesture)
    }

    private func setupTextFieldDelegate() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    /// Renders the initial state synchronously using current values from the view model.
    /// This ensures snapshot tests and immediate display work correctly without waiting for Combine publishers.
    private func renderInitialState() {
        // Text
        textField.text = viewModel.currentText

        // Placeholder
        updatePlaceholder(viewModel.currentPlaceholder)
        textField.placeholder = nil

        // Secure text entry
        let isSecure = viewModel.currentIsSecure
        let isPasswordVisible = viewModel.currentIsPasswordVisible
        textField.isSecureTextEntry = isSecure && !isPasswordVisible
        suffixButton.isHidden = !isSecure
        if isSecure {
            let iconName = isPasswordVisible ? "eye.slash" : "eye"
            suffixButton.setImage(UIImage(systemName: iconName), for: .normal)
        }

        // Keyboard configuration
        textField.keyboardType = viewModel.currentKeyboardType
        textField.returnKeyType = viewModel.currentReturnKeyType
        textField.textContentType = viewModel.currentTextContentType

        // Visual state
        updateVisualAppearance(state: viewModel.currentVisualState)

        // Update label position based on text content
        updateLabelPosition()
    }

    private func setupBindings() {
        // Text binding - dropFirst() since initial state is rendered synchronously
        viewModel.textPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                if self?.textField.text != text {
                    self?.textField.text = text
                    self?.updateLabelPosition()
                }
            }
            .store(in: &cancellables)

        // Placeholder binding - dropFirst() since initial state is rendered synchronously
        viewModel.placeholderPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] placeholder in
                self?.updatePlaceholder(placeholder)
                self?.textField.placeholder = nil
            }
            .store(in: &cancellables)

        // Secure text binding - dropFirst() since initial state is rendered synchronously
        Publishers.CombineLatest(viewModel.isSecurePublisher, viewModel.isPasswordVisiblePublisher)
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSecure, isPasswordVisible in
                self?.textField.isSecureTextEntry = isSecure && !isPasswordVisible
                self?.suffixButton.isHidden = !isSecure

                if isSecure {
                    let iconName = isPasswordVisible ? "eye.slash" : "eye"
                    self?.suffixButton.setImage(UIImage(systemName: iconName), for: .normal)
                }
            }
            .store(in: &cancellables)

        // Keyboard type binding - dropFirst() since initial state is rendered synchronously
        viewModel.keyboardTypePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyboardType in
                self?.textField.keyboardType = keyboardType
            }
            .store(in: &cancellables)

        // Return key type binding - dropFirst() since initial state is rendered synchronously
        viewModel.returnKeyTypePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnKeyType in
                self?.textField.returnKeyType = returnKeyType
            }
            .store(in: &cancellables)

        // Text content type binding - dropFirst() since initial state is rendered synchronously
        viewModel.textContentTypePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] textContentType in
                self?.textField.textContentType = textContentType
            }
            .store(in: &cancellables)

        // Visual state binding - dropFirst() since initial state is rendered synchronously
        viewModel.visualStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visualState in
                self?.updateVisualAppearance(state: visualState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Text Field Actions
    @objc private func textFieldDidChange() {
        guard let text = textField.text else { return }
        viewModel.updateText(text)
        onTextChanged(text)
        updateLabelPosition()
    }

    @objc private func textFieldDidBeginEditing() {
        viewModel.setFocused(true)
        onFocusChanged(true)
        animateLabelToFloatedPosition()
    }

    @objc private func textFieldDidEndEditing() {
        guard let text = textField.text else { return }
        viewModel.updateText(text)
        viewModel.setFocused(false)
        onFocusChanged(false)
        updateLabelPosition()
    }

    @objc private func suffixButtonTapped() {
        viewModel.togglePasswordVisibility()
    }

    @objc private func containerTapped() {
        // Only become first responder if the field is enabled
        guard currentVisualState != .disabled else { return }

        if viewModel.usesCustomInput {
            // Delegate custom input handling to the view controller
            onRequestCustomInput?()
        } else {
            // Standard keyboard input
            textField.becomeFirstResponder()
        }
    }

    // MARK: - Visual State Management
    private func updateVisualAppearance(state: BorderedTextFieldVisualState) {
        currentVisualState = state

        switch state {
        case .idle:
            updateForIdleState()
        case .focused:
            updateForFocusedState()
        case .error(let message):
            updateForErrorState(message: message)
        case .disabled:
            updateForDisabledState()
        }
    }

    private func updateForIdleState() {
        // Border and colors
        borderLayer.strokeColor = StyleProvider.Color.separatorLine.cgColor

        // Error label
        errorLabel.isHidden = true

        // Interaction
        textField.isEnabled = true
        alpha = 1.0
        isUserInteractionEnabled = true
    }

    private func updateForFocusedState() {
        // Border and colors
        borderLayer.strokeColor = StyleProvider.Color.highlightPrimary.cgColor

        // Error label
        errorLabel.isHidden = true

        // Interaction
        textField.isEnabled = true
        alpha = 1.0
        isUserInteractionEnabled = true
    }

    private func updateForErrorState(message: String) {
        // Border and colors (error takes precedence)
        borderLayer.strokeColor = StyleProvider.Color.alertError.cgColor

        // Error label
        errorLabel.text = message
        errorLabel.isHidden = false

        // Interaction
        textField.isEnabled = true
        alpha = 1.0
        isUserInteractionEnabled = true
    }

    private func updateForDisabledState() {
        // Border and colors
        borderLayer.strokeColor = StyleProvider.Color.separatorLine.cgColor

        // Error label
        errorLabel.isHidden = true

        // Interaction
        textField.isEnabled = false
        alpha = 0.6
        isUserInteractionEnabled = false
    }
    
    private func updatePrefixLabel() {
        if let prefix = viewModel.prefixText, !prefix.isEmpty {
            prefixLabel.text = prefix
            textFieldLeadingConstraint.isActive = false
            textFieldLeadingConstraint = textField.leadingAnchor.constraint(equalTo: prefixLabel.trailingAnchor, constant: 8)
            textFieldLeadingConstraint.isActive = true
        } else {
            textFieldLeadingConstraint.isActive = false
            textFieldLeadingConstraint = textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding)
            textFieldLeadingConstraint.isActive = true
        }
    }
    
    private func updatePlaceholder(_ placeholder: String) {
        // Build display text: append " *" if field is required
        let displayText = viewModel.isRequired ? "\(placeholder) *" : placeholder
        let attributedString = NSMutableAttributedString(string: displayText)

        // Set base styling
        let fullRange = NSRange(location: 0, length: displayText.count)
        attributedString.addAttribute(.font, value: StyleProvider.fontWith(type: .regular, size: 16), range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: StyleProvider.Color.inputTextTitle, range: fullRange)

        // Highlight the asterisk if field is required
        if viewModel.isRequired {
            let asteriskRange = NSRange(location: displayText.count - 1, length: 1)
            attributedString.addAttribute(.foregroundColor, value: StyleProvider.Color.highlightPrimary, range: asteriskRange)
        }

        floatingLabel.attributedText = attributedString
    }

    // MARK: - Animation & Styling
    private func updateLabelPosition() {
        let shouldFloat = !textField.text.isNilOrEmpty || textField.isFirstResponder

        if shouldFloat {
            animateLabelToFloatedPosition()
        } else {
            animateLabelToPlaceholderPosition()
        }

        // Update border path after label position changes
        updateBorderPath()
    }

    private func updateBorderPath() {
        let containerBounds = containerView.bounds
        guard containerBounds.width > 0 && containerBounds.height > 0 else { return }

        let path = UIBezierPath()
        let cornerRadius = Constants.cornerRadius
        let shouldFloat = !textField.text.isNilOrEmpty || textField.isFirstResponder

        if shouldFloat && !floatingLabel.text.isNilOrEmpty {
            // Create border with gap for floating label
            createBorderPathWithLabelGap(path: path, bounds: containerBounds, cornerRadius: cornerRadius)
        } else {
            // Create normal rounded rectangle border
            path.append(UIBezierPath(roundedRect: containerBounds, cornerRadius: cornerRadius))
        }

        borderLayer.path = path.cgPath
    }

    private func createBorderPathWithLabelGap(path: UIBezierPath, bounds: CGRect, cornerRadius: CGFloat) {
        // Calculate label frame and gap
        let labelFrame = floatingLabel.frame
        let labelPadding: CGFloat = 4 // Padding around label text
        let gapStart = max(labelFrame.minX - labelPadding, cornerRadius)
        let gapEnd = min(labelFrame.maxX + labelPadding, bounds.width - cornerRadius)

        // Start from top-left corner, going clockwise
        path.move(to: CGPoint(x: 0, y: cornerRadius))

        // Left side
        path.addLine(to: CGPoint(x: 0, y: bounds.height - cornerRadius))

        // Bottom-left corner
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: bounds.height - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .pi,
                   endAngle: .pi / 2,
                   clockwise: false)

        // Bottom side
        path.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: bounds.height))

        // Bottom-right corner
        path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: bounds.height - cornerRadius),
                   radius: cornerRadius,
                   startAngle: .pi / 2,
                   endAngle: 0,
                   clockwise: false)

        // Right side
        path.addLine(to: CGPoint(x: bounds.width, y: cornerRadius))

        // Top-right corner
        path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: 0,
                   endAngle: -.pi / 2,
                   clockwise: false)

        // Top side with gap for label
        if gapEnd < bounds.width - cornerRadius {
            path.addLine(to: CGPoint(x: gapEnd, y: 0))
        }

        // Skip the gap (don't draw line behind label)
        if gapStart > cornerRadius {
            path.move(to: CGPoint(x: gapStart, y: 0))
        }

        // Continue top side
        path.addLine(to: CGPoint(x: cornerRadius, y: 0))

        // Top-left corner
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                   radius: cornerRadius,
                   startAngle: -.pi / 2,
                   endAngle: .pi,
                   clockwise: false)
    }

    private func animateLabelToFloatedPosition() {
        labelCenterYConstraint.isActive = false
        labelTopConstraint.isActive = true

        UIView.animate(withDuration: Constants.labelAnimationDuration) {
            self.floatingLabel.transform = CGAffineTransform(scaleX: Constants.labelFloatedScale, y: Constants.labelFloatedScale)
            self.layoutIfNeeded()
        } completion: { _ in
            // Update border path after animation completes
            self.updateBorderPath()
        }
        
        if viewModel.prefixText != nil {
            prefixLabel.isHidden = false
        }
        
    }

    private func animateLabelToPlaceholderPosition() {
        labelTopConstraint.isActive = false
        labelCenterYConstraint.isActive = true

        UIView.animate(withDuration: Constants.labelAnimationDuration) {
            self.floatingLabel.transform = .identity
            self.layoutIfNeeded()
        } completion: { _ in
            // Update border path after animation completes
            self.updateBorderPath()
        }
        
        if viewModel.prefixText != nil {
            prefixLabel.isHidden = true
        }
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Update border layer frame to match container
        borderLayer.frame = containerView.bounds
        // Update border path when view bounds change
        updateBorderPath()
    }

    // MARK: - Public Methods
    public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    public override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    /// Sets a custom input view (e.g., UIDatePicker) instead of the standard keyboard
    /// - Parameters:
    ///   - inputView: The custom input view to display (e.g., UIDatePicker, UIPickerView)
    ///   - accessoryView: Optional toolbar or accessory view to display above the input view
    public func setCustomInputView(_ inputView: UIView?, accessoryView: UIView? = nil) {
        textField.inputView = inputView
        textField.inputAccessoryView = accessoryView
    }
}

// MARK: - UITextFieldDelegate
extension BorderedTextFieldView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // Check maxLength restriction
        if let maxLength = viewModel.maxLength {
            if updatedText.count > maxLength {
                return false
            }
        }

        // Check allowedCharacters restriction
        if let allowedCharacters = viewModel.allowedCharacters {
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
        }

        // Check format validation (e.g., decimal number format)
        if !viewModel.shouldAllowTextChange(from: currentText, to: updatedText) {
            return false
        }

        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Notify the view model that return key was tapped
        viewModel.onReturnKeyTapped()
        return true
    }
}

// MARK: - String Extension
private extension String {
    var isNilOrEmpty: Bool {
        return self.isEmpty
    }
}

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty != false
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("BorderedTextFieldView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "BorderedTextFieldView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Phone Number Field
        let phoneView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.phoneNumberField)
        phoneView.translatesAutoresizingMaskIntoConstraints = false

        // Password Field
        let passwordView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.passwordField)
        passwordView.translatesAutoresizingMaskIntoConstraints = false

        // Email Field
        let emailView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.emailField)
        emailView.translatesAutoresizingMaskIntoConstraints = false

        // Name Field
        let nameView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.nameField)
        nameView.translatesAutoresizingMaskIntoConstraints = false

        // Error Field
        let errorView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.errorField)
        errorView.translatesAutoresizingMaskIntoConstraints = false

        // Disabled Field
        let disabledView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.disabledField)
        disabledView.translatesAutoresizingMaskIntoConstraints = false

        // Focused Field
        let focusedView = BorderedTextFieldView(viewModel: MockBorderedTextFieldViewModel.focusedField)
        focusedView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(phoneView)
        stackView.addArrangedSubview(passwordView)
        stackView.addArrangedSubview(emailView)
        stackView.addArrangedSubview(nameView)
        stackView.addArrangedSubview(errorView)
        stackView.addArrangedSubview(disabledView)
        stackView.addArrangedSubview(focusedView)

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        return vc
    }
}

#endif
