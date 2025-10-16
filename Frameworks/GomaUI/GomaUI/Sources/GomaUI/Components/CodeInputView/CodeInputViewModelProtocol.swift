import Foundation
import Combine

/// Represents the different states of the code input view
public enum CodeInputState: Equatable {
    case `default`
    case loading
    case error(message: String)
}

/// Data model for the code input view
public struct CodeInputData: Equatable {
    public let state: CodeInputState
    public let code: String
    public let placeholder: String
    public let buttonTitle: String
    public let isButtonEnabled: Bool
    
    public init(
        state: CodeInputState = .default,
        code: String = "",
        placeholder: String = "Enter booking code",
        buttonTitle: String = "Load Betslip",
        isButtonEnabled: Bool = true
    ) {
        self.state = state
        self.code = code
        self.placeholder = placeholder
        self.buttonTitle = buttonTitle
        self.isButtonEnabled = isButtonEnabled
    }
}

/// Protocol defining the interface for CodeInputView ViewModels
public protocol CodeInputViewModelProtocol {
    /// Publisher for the code input data
    var dataPublisher: AnyPublisher<CodeInputData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: CodeInputData { get }
    
    /// Child view models
    var codeTextFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var submitButtonViewModel: ButtonViewModelProtocol { get }
    
    /// Update the code value
    func updateCode(_ code: String)
    
    /// Set the loading state
    func setLoading(_ isLoading: Bool)
    
    /// Set the error state with message
    func setError(_ message: String)
    
    /// Clear the error state (return to default)
    func clearError()
    
    /// Handle button tap
    func onButtonTapped()
    
    /// Callback for submit action; screen-level ViewModel should handle logic
    var onSubmitRequested: ((String) -> Void)? { get set }
} 
