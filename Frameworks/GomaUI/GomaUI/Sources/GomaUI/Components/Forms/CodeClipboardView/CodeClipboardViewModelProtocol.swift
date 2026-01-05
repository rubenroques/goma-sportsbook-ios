import Foundation
import Combine


/// Represents the different states of the code clipboard view
public enum CodeClipboardState: Equatable {
    case `default`
    case copied
}

/// Data model for the code clipboard view
public struct CodeClipboardData: Equatable {
    public let state: CodeClipboardState
    public let code: String
    public let labelText: String
    public let isEnabled: Bool
    
    public init(
        state: CodeClipboardState = .default,
        code: String = "",
        labelText: String = LocalizationProvider.string("copy_booking_code"),
        isEnabled: Bool = true
    ) {
        self.state = state
        self.code = code
        self.labelText = labelText
        self.isEnabled = isEnabled
    }
}

/// Protocol defining the interface for CodeClipboardView ViewModels
public protocol CodeClipboardViewModelProtocol {
    /// Publisher for the code clipboard data
    var dataPublisher: AnyPublisher<CodeClipboardData, Never> { get }
    
    /// Current data (for immediate access)
    var currentData: CodeClipboardData { get }
    
    /// Update the code value
    func updateCode(_ code: String)
    
    /// Set the copied state
    func setCopied(_ isCopied: Bool)
    
    /// Set the enabled state
    func setEnabled(_ isEnabled: Bool)
    
    /// Handle copy action
    func onCopyTapped()
} 
