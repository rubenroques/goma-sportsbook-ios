import Combine
import UIKit

/// Mock implementation of `BorderedTextFieldViewModelProtocol` for testing.
final public class MockBorderedTextFieldViewModel: BorderedTextFieldViewModelProtocol {

    // MARK: - Publishers
    private let textSubject: CurrentValueSubject<String, Never>
    private let placeholderSubject: CurrentValueSubject<String, Never>
    private let isSecureSubject: CurrentValueSubject<Bool, Never>
    private let keyboardTypeSubject: CurrentValueSubject<UIKeyboardType, Never>
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

    public var prefixText: String?
    public var isRequired: Bool

    // MARK: - Initialization
    public init(textFieldData: BorderedTextFieldData) {
        self.textSubject = CurrentValueSubject(textFieldData.text)
        self.placeholderSubject = CurrentValueSubject(textFieldData.placeholder)
        self.isSecureSubject = CurrentValueSubject(textFieldData.isSecure)
        self.keyboardTypeSubject = CurrentValueSubject(textFieldData.keyboardType)
        self.textContentTypeSubject = CurrentValueSubject(textFieldData.textContentType)
        self.visualStateSubject = CurrentValueSubject(textFieldData.visualState)

        // Password visibility initialization
        self.isPasswordVisibleSubject = CurrentValueSubject(false)

        self.prefixText = textFieldData.prefix
        self.isRequired = textFieldData.isRequired
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
                placeholder: "Phone number",
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
                placeholder: "Password",
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
                placeholder: "Email",
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
                placeholder: "Email",
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
                placeholder: "Email",
                visualState: .focused,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
        )
    }
}
