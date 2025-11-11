import Foundation
import Combine
import UIKit


/// Mock implementation of CodeInputViewModelProtocol for testing and previews
public final class MockCodeInputViewModel: CodeInputViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<CodeInputData, Never>
    
    // Child view models
    public let codeTextFieldViewModel: BorderedTextFieldViewModelProtocol
    public let submitButtonViewModel: ButtonViewModelProtocol
    
    public var dataPublisher: AnyPublisher<CodeInputData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: CodeInputData {
        dataSubject.value
    }
    
    public var onSubmitRequested: ((String) -> Void)?
    
    // MARK: - Initialization
    public init(
        state: CodeInputState = .default,
        code: String = "",
        placeholder: String = LocalizationProvider.string("enter_booking_code"),
        buttonTitle: String = LocalizationProvider.string("load_betslip"),
        isButtonEnabled: Bool = true
    ) {
        let initialData = CodeInputData(
            state: state,
            code: code,
            placeholder: placeholder,
            buttonTitle: buttonTitle,
            isButtonEnabled: isButtonEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
        
        // Initialize child view models
        let textFieldData = BorderedTextFieldData(
            id: "code_input",
            text: code,
            placeholder: placeholder,
            visualState: .idle
        )
        self.codeTextFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: textFieldData)
        
        let buttonData = ButtonData(
            id: "submit_button",
            title: buttonTitle,
            style: .solidBackground,
            isEnabled: isButtonEnabled
        )
        self.submitButtonViewModel = MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Protocol Methods
    public func updateCode(_ code: String) {
        let newData = CodeInputData(
            state: currentData.state,
            code: code,
            placeholder: currentData.placeholder,
            buttonTitle: currentData.buttonTitle,
            isButtonEnabled: currentData.isButtonEnabled
        )
        dataSubject.send(newData)
        
        // Update child view model
        codeTextFieldViewModel.updateText(code)
    }
    
    public func setLoading(_ isLoading: Bool) {
        let newState: CodeInputState = isLoading ? .loading : .default
        let newData = CodeInputData(
            state: newState,
            code: currentData.code,
            placeholder: currentData.placeholder,
            buttonTitle: currentData.buttonTitle,
            isButtonEnabled: !isLoading
        )
        dataSubject.send(newData)
        
        // Update child view models
        submitButtonViewModel.setEnabled(!isLoading)
    }
    
    public func setError(_ message: String) {
        let newData = CodeInputData(
            state: .error(message: message),
            code: currentData.code,
            placeholder: currentData.placeholder,
            buttonTitle: currentData.buttonTitle,
            isButtonEnabled: true
        )
        dataSubject.send(newData)
        
        // Update child view models
        codeTextFieldViewModel.setError(message)
        submitButtonViewModel.setEnabled(true)
    }
    
    public func clearError() {
        let newData = CodeInputData(
            state: .default,
            code: currentData.code,
            placeholder: currentData.placeholder,
            buttonTitle: currentData.buttonTitle,
            isButtonEnabled: true
        )
        dataSubject.send(newData)
        
        // Update child view models
        codeTextFieldViewModel.clearError()
        submitButtonViewModel.setEnabled(true)
    }
    
    public func onButtonTapped() {
        
        onSubmitRequested?(currentData.code)
    }
}

// MARK: - Factory Methods
public extension MockCodeInputViewModel {
    
    /// Creates a mock view model for default state
    static func defaultMock() -> MockCodeInputViewModel {
        MockCodeInputViewModel()
    }
    
    /// Creates a mock view model for loading state
    static func loadingMock() -> MockCodeInputViewModel {
        MockCodeInputViewModel(
            state: .loading,
            code: "BA2672",
            isButtonEnabled: false
        )
    }
    
    /// Creates a mock view model for error state
    static func errorMock() -> MockCodeInputViewModel {
        MockCodeInputViewModel(
            state: .error(message: "Booking Code can't be found. It either doesn't exist or expired."),
            code: "BA2672"
        )
    }
    
    /// Creates a mock view model with pre-filled code
    static func withCodeMock() -> MockCodeInputViewModel {
        MockCodeInputViewModel(
            code: "BA2672"
        )
    }
} 
