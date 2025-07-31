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
    public let visualState: BorderedTextFieldVisualState
    public let keyboardType: UIKeyboardType
    public let textContentType: UITextContentType?

    public init(
        id: String,
        text: String = "",
        placeholder: String,
        prefix: String? = nil,
        isSecure: Bool = false,
        visualState: BorderedTextFieldVisualState = .idle,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) {
        self.id = id
        self.text = text
        self.placeholder = placeholder
        self.prefix = prefix
        self.isSecure = isSecure
        self.visualState = visualState
        self.keyboardType = keyboardType
        self.textContentType = textContentType
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
    // Content publishers
    var textPublisher: AnyPublisher<String, Never> { get }
    var placeholderPublisher: AnyPublisher<String, Never> { get }
    var isSecurePublisher: AnyPublisher<Bool, Never> { get }
    var keyboardTypePublisher: AnyPublisher<UIKeyboardType, Never> { get }
    var textContentTypePublisher: AnyPublisher<UITextContentType?, Never> { get }

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

    // Convenience methods for common state transitions
    func setFocused(_ focused: Bool)
    func setError(_ errorMessage: String)
    func clearError()
    func setEnabled(_ enabled: Bool)
    
    // Other options
    var prefixText: String? { get }
}
