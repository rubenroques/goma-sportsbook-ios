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

        suffixButton.accessibilityLabel = "Toggle password visibility"
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(tapGesture)
    }

    private func setupTextFieldDelegate() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    private func setupBindings() {
        // Text binding
        viewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                if self?.textField.text != text {
                    self?.textField.text = text
                    self?.updateLabelPosition()
                }
            }
            .store(in: &cancellables)

        // Placeholder binding (now serves as both placeholder and label)
        viewModel.placeholderPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] placeholder in
                self?.updatePlaceholderWithHighlightedAsterisk(placeholder)

                // Remove textField placeholder since floatingLabel handles both states
                self?.textField.placeholder = nil
            }
            .store(in: &cancellables)

        // Secure text binding
        Publishers.CombineLatest(viewModel.isSecurePublisher, viewModel.isPasswordVisiblePublisher)
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

        // Keyboard type binding
        viewModel.keyboardTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyboardType in
                self?.textField.keyboardType = keyboardType
            }
            .store(in: &cancellables)

        // Text content type binding
        viewModel.textContentTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] textContentType in
                self?.textField.textContentType = textContentType
            }
            .store(in: &cancellables)

        // Unified visual state binding - This replaces multiple individual state bindings
        viewModel.visualStatePublisher
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
        textField.becomeFirstResponder()
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
    
    private func updatePlaceholderWithHighlightedAsterisk(_ placeholder: String) {
        let attributedString = NSMutableAttributedString(string: placeholder)
        
        // Set base styling
        let fullRange = NSRange(location: 0, length: placeholder.count)
        attributedString.addAttribute(.font, value: StyleProvider.fontWith(type: .regular, size: 16), range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: StyleProvider.Color.inputTextTitle, range: fullRange)
        
        // Find the asterisk and style it
        if let asteriskRange = placeholder.range(of: "*") {
            let nsRange = NSRange(asteriskRange, in: placeholder)
            attributedString.addAttribute(.foregroundColor, value: StyleProvider.Color.highlightPrimary, range: nsRange)
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

// MARK: - Preview Provider
#if DEBUG

@available(iOS 17.0, *)
#Preview("Phone Number Field") {
    PreviewUIView {
        let mockViewModel = MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "phone",
                text: "712345678",
                placeholder: "Phone number",
                prefix: "+237",
                visualState: .idle,
                keyboardType: .phonePad,
                textContentType: .telephoneNumber
            )
        )
        return BorderedTextFieldView(viewModel: mockViewModel)
    }
    .frame(height: 80)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Password Field") {
    PreviewUIView {
        let mockViewModel = MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "password",
                text: "secret123",
                placeholder: "Password",
                isSecure: true,
                visualState: .focused,
                textContentType: .password
            )
        )
        return BorderedTextFieldView(viewModel: mockViewModel)
    }
    .frame(height: 80)
    .padding()
}

#endif
