import Combine
import UIKit

// MARK: - Visual State
public enum BorderedTextFieldVisualState: Equatable {
    case idle                    // Normal unfocused state
    case focused                 // Field is focused
    case error(String)          // Field has error with message
    case disabled               // Field is disabled and non-interactive
}

// MARK: - Data Models
public struct BorderedTextFieldData: Equatable, Hashable {
    public let id: String
    public let text: String
    public let placeholder: String
    public let prefix: String?
    public let isSecure: Bool
    public let isRequired: Bool
    public let usesCustomInput: Bool
    public let visualState: BorderedTextFieldVisualState
    public let keyboardType: UIKeyboardType
    public let returnKeyType: UIReturnKeyType
    public let textContentType: UITextContentType?
    public let maxLength: Int?
    public let allowedCharacters: CharacterSet?

    public init(
        id: String,
        text: String = "",
        placeholder: String,
        prefix: String? = nil,
        isSecure: Bool = false,
        isRequired: Bool = false,
        usesCustomInput: Bool = false,
        visualState: BorderedTextFieldVisualState = .idle,
        keyboardType: UIKeyboardType = .default,
        returnKeyType: UIReturnKeyType = .default,
        textContentType: UITextContentType? = nil,
        maxLength: Int? = nil,
        allowedCharacters: CharacterSet? = nil
    ) {
        self.id = id
        self.text = text
        self.placeholder = placeholder
        self.prefix = prefix
        self.isSecure = isSecure
        self.isRequired = isRequired
        self.usesCustomInput = usesCustomInput
        self.visualState = visualState
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.textContentType = textContentType
        self.maxLength = maxLength
        self.allowedCharacters = allowedCharacters
    }
}

// MARK: - Hashable Conformance for BorderedTextFieldVisualState
extension BorderedTextFieldVisualState: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            hasher.combine("idle")
        case .focused:
            hasher.combine("focused")
        case .error(let message):
            hasher.combine("error")
            hasher.combine(message)
        case .disabled:
            hasher.combine("disabled")
        }
    }
}

// MARK: - View Model Protocol
public protocol BorderedTextFieldViewModelProtocol {
    // Content publishers (for reactive updates)
    var textPublisher: AnyPublisher<String, Never> { get }
    var placeholderPublisher: AnyPublisher<String, Never> { get }
    var isSecurePublisher: AnyPublisher<Bool, Never> { get }
    var keyboardTypePublisher: AnyPublisher<UIKeyboardType, Never> { get }
    var returnKeyTypePublisher: AnyPublisher<UIReturnKeyType, Never> { get }
    var textContentTypePublisher: AnyPublisher<UITextContentType?, Never> { get }

    // Synchronous state access (for immediate rendering - required for snapshot tests)
    var currentText: String { get }
    var currentPlaceholder: String { get }
    var currentIsSecure: Bool { get }
    var currentKeyboardType: UIKeyboardType { get }
    var currentReturnKeyType: UIReturnKeyType { get }
    var currentTextContentType: UITextContentType? { get }
    var currentIsPasswordVisible: Bool { get }

    // Unified visual state publisher and current state access
    var visualStatePublisher: AnyPublisher<BorderedTextFieldVisualState, Never> { get }
    var currentVisualState: BorderedTextFieldVisualState { get }

    // Password visibility publisher (only relevant for secure fields)
    var isPasswordVisiblePublisher: AnyPublisher<Bool, Never> { get }

    // Actions
    func updateText(_ text: String)
    func setVisualState(_ state: BorderedTextFieldVisualState)
    func togglePasswordVisibility()
    func updatePlaceholder(_ placeholder: String)
    func onReturnKeyTapped()

    // Convenience methods for common state transitions
    func setFocused(_ focused: Bool)
    func setError(_ errorMessage: String)
    func clearError()
    func setEnabled(_ enabled: Bool)

    // Other options
    var prefixText: String? { get }
    var isRequired: Bool { get }
    var usesCustomInput: Bool { get }
    var maxLength: Int? { get }
    var allowedCharacters: CharacterSet? { get }

    /// Validates if the proposed text change should be allowed.
    /// Use this for format validation (e.g., ensuring only one decimal separator in numeric fields).
    /// - Parameters:
    ///   - currentText: The current text in the field
    ///   - proposedText: The text that would result from the change
    /// - Returns: true if the change should be allowed, false otherwise
    func shouldAllowTextChange(from currentText: String, to proposedText: String) -> Bool
}

// MARK: - Default Implementations
public extension BorderedTextFieldViewModelProtocol {
    /// Default implementation allows all text changes (backward compatible)
    func shouldAllowTextChange(from currentText: String, to proposedText: String) -> Bool {
        return true
    }
}
