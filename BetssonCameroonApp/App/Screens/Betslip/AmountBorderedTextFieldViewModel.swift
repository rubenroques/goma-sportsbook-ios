import Foundation
import UIKit
import Combine
import GomaUI

/// Production implementation of BorderedTextFieldViewModelProtocol
/// Specifically configured for amount input in betslip
final class AmountBorderedTextFieldViewModel: BorderedTextFieldViewModelProtocol {

    // MARK: - Properties
    private let textSubject: CurrentValueSubject<String, Never>
    private let placeholderSubject: CurrentValueSubject<String, Never>
    private let isSecureSubject: CurrentValueSubject<Bool, Never>
    private let keyboardTypeSubject: CurrentValueSubject<UIKeyboardType, Never>
    private let returnKeyTypeSubject: CurrentValueSubject<UIReturnKeyType, Never>
    private let textContentTypeSubject: CurrentValueSubject<UITextContentType?, Never>
    private let visualStateSubject: CurrentValueSubject<BorderedTextFieldVisualState, Never>
    private let isPasswordVisibleSubject: CurrentValueSubject<Bool, Never>

    private let data: BorderedTextFieldData

    // MARK: - Publishers
    var textPublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
    }

    var placeholderPublisher: AnyPublisher<String, Never> {
        placeholderSubject.eraseToAnyPublisher()
    }

    var isSecurePublisher: AnyPublisher<Bool, Never> {
        isSecureSubject.eraseToAnyPublisher()
    }

    var keyboardTypePublisher: AnyPublisher<UIKeyboardType, Never> {
        keyboardTypeSubject.eraseToAnyPublisher()
    }

    var returnKeyTypePublisher: AnyPublisher<UIReturnKeyType, Never> {
        returnKeyTypeSubject.eraseToAnyPublisher()
    }

    var textContentTypePublisher: AnyPublisher<UITextContentType?, Never> {
        textContentTypeSubject.eraseToAnyPublisher()
    }

    var visualStatePublisher: AnyPublisher<BorderedTextFieldVisualState, Never> {
        visualStateSubject.eraseToAnyPublisher()
    }

    var isPasswordVisiblePublisher: AnyPublisher<Bool, Never> {
        isPasswordVisibleSubject.eraseToAnyPublisher()
    }

    // MARK: - Synchronous State Access
    var currentText: String {
        textSubject.value
    }

    var currentPlaceholder: String {
        placeholderSubject.value
    }

    var currentIsSecure: Bool {
        isSecureSubject.value
    }

    var currentKeyboardType: UIKeyboardType {
        keyboardTypeSubject.value
    }

    var currentReturnKeyType: UIReturnKeyType {
        returnKeyTypeSubject.value
    }

    var currentTextContentType: UITextContentType? {
        textContentTypeSubject.value
    }

    var currentIsPasswordVisible: Bool {
        isPasswordVisibleSubject.value
    }

    var currentVisualState: BorderedTextFieldVisualState {
        visualStateSubject.value
    }

    var prefixText: String? {
        data.prefix
    }

    var isRequired: Bool {
        data.isRequired
    }

    var usesCustomInput: Bool {
        data.usesCustomInput
    }

    var maxLength: Int? {
        data.maxLength
    }

    var allowedCharacters: CharacterSet? {
        data.allowedCharacters
    }

    // Callback for return key tap
    var onReturnKeyTappedCallback: (() -> Void)?

    // MARK: - Initialization
    init(textFieldData: BorderedTextFieldData) {
        self.data = textFieldData
        self.textSubject = CurrentValueSubject(textFieldData.text)
        self.placeholderSubject = CurrentValueSubject(textFieldData.placeholder)
        self.isSecureSubject = CurrentValueSubject(textFieldData.isSecure)
        self.keyboardTypeSubject = CurrentValueSubject(textFieldData.keyboardType)
        self.returnKeyTypeSubject = CurrentValueSubject(textFieldData.returnKeyType)
        self.textContentTypeSubject = CurrentValueSubject(textFieldData.textContentType)
        self.visualStateSubject = CurrentValueSubject(textFieldData.visualState)
        self.isPasswordVisibleSubject = CurrentValueSubject(false)
    }

    // MARK: - Protocol Methods
    func updateText(_ text: String) {
        textSubject.send(text)
    }

    func setVisualState(_ state: BorderedTextFieldVisualState) {
        visualStateSubject.send(state)
    }

    func togglePasswordVisibility() {
        let isVisible = isPasswordVisibleSubject.value
        isPasswordVisibleSubject.send(!isVisible)
    }

    func updatePlaceholder(_ placeholder: String) {
        placeholderSubject.send(placeholder)
    }

    func onReturnKeyTapped() {
        onReturnKeyTappedCallback?()
    }

    // MARK: - Convenience Methods
    func setFocused(_ focused: Bool) {
        if focused {
            setVisualState(.focused)
        } else {
            // Only change to idle if not in error state
            if case .error = currentVisualState {
                // Keep error state
            } else {
                setVisualState(.idle)
            }
        }
    }

    func setError(_ errorMessage: String) {
        setVisualState(.error(errorMessage))
    }

    func clearError() {
        setVisualState(.idle)
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            setVisualState(.idle)
        } else {
            setVisualState(.disabled)
        }
    }

    // MARK: - Format Validation

    /// Validates decimal number format for amount input.
    /// Ensures only one decimal separator and maximum 2 decimal places.
    func shouldAllowTextChange(from currentText: String, to proposedText: String) -> Bool {
        // Allow empty string (clearing the field)
        if proposedText.isEmpty { return true }

        // Normalize decimal separators (treat , and . as equivalent)
        let normalized = proposedText.replacingOccurrences(of: ",", with: ".")

        // Reject if multiple decimal separators
        let decimalCount = normalized.filter { $0 == "." }.count
        if decimalCount > 1 { return false }

        // Validate decimal places (max 2 for currency)
        if let decimalIndex = normalized.firstIndex(of: ".") {
            let decimalPart = normalized[normalized.index(after: decimalIndex)...]
            if decimalPart.count > 2 { return false }
        }

        return true
    }
}

// MARK: - Factory Methods
extension AmountBorderedTextFieldViewModel {

    /// Creates an AmountBorderedTextFieldViewModel for betslip amount input
    /// - Returns: Configured AmountBorderedTextFieldViewModel with numeric keyboard settings
    static func amountInput() -> AmountBorderedTextFieldViewModel {
        return AmountBorderedTextFieldViewModel(
            textFieldData: BorderedTextFieldData(
                id: "amount",
                text: "",
                placeholder: localized("amount"),
                visualState: .idle,
                keyboardType: .decimalPad,
                returnKeyType: .go,
                textContentType: .flightNumber,
                allowedCharacters: CharacterSet(charactersIn: "0123456789.,")
            )
        )
    }
}
