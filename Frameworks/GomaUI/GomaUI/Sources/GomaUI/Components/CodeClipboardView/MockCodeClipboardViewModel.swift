import Foundation
import Combine
import UIKit


/// Mock implementation of CodeClipboardViewModelProtocol for testing and previews
public final class MockCodeClipboardViewModel: CodeClipboardViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<CodeClipboardData, Never>
    
    public var dataPublisher: AnyPublisher<CodeClipboardData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: CodeClipboardData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(
        state: CodeClipboardState = .default,
        code: String = "ABCD1E2",
        labelText: String = LocalizationProvider.string("copy_booking_code"),
        isEnabled: Bool = true
    ) {
        let initialData = CodeClipboardData(
            state: state,
            code: code,
            labelText: labelText,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateCode(_ code: String) {
        let newData = CodeClipboardData(
            state: currentData.state,
            code: code,
            labelText: currentData.labelText,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func setCopied(_ isCopied: Bool) {
        let newState: CodeClipboardState = isCopied ? .copied : .default
        let newData = CodeClipboardData(
            state: newState,
            code: currentData.code,
            labelText: currentData.labelText,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = CodeClipboardData(
            state: currentData.state,
            code: currentData.code,
            labelText: currentData.labelText,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func onCopyTapped() {
        // Mock implementation - in real app this would copy to clipboard
        print("Copy tapped for code: \(currentData.code)")
        
        // Simulate copy action
        setCopied(true)
        
        // Simulate reverting to default state after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.setCopied(false)
        }
    }
}

// MARK: - Factory Methods
public extension MockCodeClipboardViewModel {
    
    /// Creates a mock view model for default state
    static func defaultMock() -> MockCodeClipboardViewModel {
        MockCodeClipboardViewModel()
    }
    
    /// Creates a mock view model for copied state
    static func copiedMock() -> MockCodeClipboardViewModel {
        MockCodeClipboardViewModel(
            state: .copied,
            code: "ABCD1E2"
        )
    }
    
    /// Creates a mock view model with custom code
    static func withCustomCodeMock() -> MockCodeClipboardViewModel {
        MockCodeClipboardViewModel(
            code: "XYZ789"
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockCodeClipboardViewModel {
        MockCodeClipboardViewModel(
            code: "ABCD1E2",
            isEnabled: false
        )
    }
} 
