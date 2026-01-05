import Combine
import UIKit


/// Mock implementation of `BorderedTextFieldViewModelProtocol` for testing.
final public class MockBorderedTextFieldViewModel: BorderedTextFieldViewModelProtocol {

    // MARK: - Publishers
    private let textSubject: CurrentValueSubject<String, Never>
    private let placeholderSubject: CurrentValueSubject<String, Never>
    private let isSecureSubject: CurrentValueSubject<Bool, Never>
    private let keyboardTypeSubject: CurrentValueSubject<UIKeyboardType, Never>
    private let returnKeyTypeSubject: CurrentValueSubject<UIReturnKeyType, Never>
    private let textContentTypeSubject: CurrentValueSubject<UITextContentType?, Never>

    // Unified visual state subject
    private let visualStateSubject: CurrentValueSubject<BorderedTextFieldVisualState, Never>

    // Password visibility subject
    private let isPasswordVisibleSubject: CurrentValueSubject<Bool, Never>

    // MARK: - Public Publishers
    public var textPublisher: AnyPublisher<String, Never> {
        return textSubject.eraseToAnyPublisher()
    }

    public var placeholderPublisher: AnyPublisher<String, Never> {
        return placeholderSubject.eraseToAnyPublisher()
    }

    public var isSecurePublisher: AnyPublisher<Bool, Never> {
        return isSecureSubject.eraseToAnyPublisher()
    }

    public var keyboardTypePublisher: AnyPublisher<UIKeyboardType, Never> {
        return keyboardTypeSubject.eraseToAnyPublisher()
    }

    public var returnKeyTypePublisher: AnyPublisher<UIReturnKeyType, Never> {
        return returnKeyTypeSubject.eraseToAnyPublisher()
    }

    public var textContentTypePublisher: AnyPublisher<UITextContentType?, Never> {
        return textContentTypeSubject.eraseToAnyPublisher()
    }

    public var visualStatePublisher: AnyPublisher<BorderedTextFieldVisualState, Never> {
        return visualStateSubject.eraseToAnyPublisher()
    }

    public var currentVisualState: BorderedTextFieldVisualState {
        return visualStateSubject.value
    }

    public var isPasswordVisiblePublisher: AnyPublisher<Bool, Never> {
        return isPasswordVisibleSubject.eraseToAnyPublisher()
    }

    // MARK: - Synchronous State Access
    public var currentText: String {
        return textSubject.value
    }

    public var currentPlaceholder: String {
        return placeholderSubject.value
    }

    public var currentIsSecure: Bool {
        return isSecureSubject.value
    }

    public var currentKeyboardType: UIKeyboardType {
        return keyboardTypeSubject.value
    }

    public var currentReturnKeyType: UIReturnKeyType {
        return returnKeyTypeSubject.value
    }

    public var currentTextContentType: UITextContentType? {
        return textContentTypeSubject.value
    }

    public var currentIsPasswordVisible: Bool {
        return isPasswordVisibleSubject.value
    }

    public var prefixText: String?
    public var isRequired: Bool
    public var usesCustomInput: Bool
    public var maxLength: Int?
    public var allowedCharacters: CharacterSet?

    // MARK: - Callbacks
    public var onReturnKeyTappedCallback: (() -> Void)?

    // MARK: - Initialization
    public init(textFieldData: BorderedTextFieldData) {
        self.textSubject = CurrentValueSubject(textFieldData.text)
        self.placeholderSubject = CurrentValueSubject(textFieldData.placeholder)
        self.isSecureSubject = CurrentValueSubject(textFieldData.isSecure)
        self.keyboardTypeSubject = CurrentValueSubject(textFieldData.keyboardType)
        self.returnKeyTypeSubject = CurrentValueSubject(textFieldData.returnKeyType)
        self.textContentTypeSubject = CurrentValueSubject(textFieldData.textContentType)
        self.visualStateSubject = CurrentValueSubject(textFieldData.visualState)

        // Password visibility initialization
        self.isPasswordVisibleSubject = CurrentValueSubject(false)

        self.prefixText = textFieldData.prefix
        self.isRequired = textFieldData.isRequired
        self.usesCustomInput = textFieldData.usesCustomInput
        self.maxLength = textFieldData.maxLength
        self.allowedCharacters = textFieldData.allowedCharacters
    }

    // MARK: - BorderedTextFieldViewModelProtocol
    public func updateText(_ text: String) {
        textSubject.send(text)
    }

    public func setVisualState(_ state: BorderedTextFieldVisualState) {
        visualStateSubject.send(state)
    }

    public func togglePasswordVisibility() {
        isPasswordVisibleSubject.send(!isPasswordVisibleSubject.value)
    }

    public func updatePlaceholder(_ placeholder: String) {
        placeholderSubject.send(placeholder)
    }

    public func onReturnKeyTapped() {
        // Trigger the callback if set
        onReturnKeyTappedCallback?()
    }

    // MARK: - Convenience Methods
    public func setFocused(_ focused: Bool) {
        // Only change to focused/idle if not in error or disabled state
        let currentState = visualStateSubject.value
        switch currentState {
        case .error, .disabled:
            // Don't override error or disabled states
            return
        case .idle, .focused:
            visualStateSubject.send(focused ? .focused : .idle)
        }
    }

    public func setError(_ errorMessage: String) {
        visualStateSubject.send(.error(errorMessage))
    }

    public func clearError() {
        // Return to idle or focused state when clearing error
        let currentState = visualStateSubject.value
        switch currentState {
        case .idle:
            visualStateSubject.send(.idle)
        case .error:
            visualStateSubject.send(.focused)
        default:
            return
        }
    }

    public func setEnabled(_ enabled: Bool) {
        if enabled {
            // Return to idle state when enabling
            visualStateSubject.send(.idle)
        } else {
            visualStateSubject.send(.disabled)
        }
    }
}

// MARK: - Mock Factory
extension MockBorderedTextFieldViewModel {
    public static var phoneNumberField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "phone",
                text: "+237 712345678",
                placeholder: LocalizationProvider.string("phone_number"),
                visualState: .idle,
                keyboardType: .phonePad,
                textContentType: .telephoneNumber
            )
        )
    }

    public static var passwordField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "password",
                text: "",
                placeholder: LocalizationProvider.string("password"),
                isSecure: true,
                visualState: .idle,
                textContentType: .password
            )
        )
    }

    public static var emailField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "email",
                text: "",
                placeholder: LocalizationProvider.string("email"),
                visualState: .idle,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
        )
    }

    public static var nameField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "name",
                text: "",
                placeholder: "Full Name",
                visualState: .idle,
                textContentType: .name
            )
        )
    }

    public static var errorField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "error",
                text: "invalid@email",
                placeholder: LocalizationProvider.string("email"),
                visualState: .error("Please enter a valid email address"),
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
        )
    }

    public static var disabledField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "disabled",
                text: "Read only value",
                placeholder: "Disabled Field",
                visualState: .disabled
            )
        )
    }

    public static var focusedField: MockBorderedTextFieldViewModel {
        return MockBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "focused",
                text: "",
                placeholder: LocalizationProvider.string("email"),
                visualState: .focused,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
        )
    }
}
