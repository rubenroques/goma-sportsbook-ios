import Foundation
import Combine
import UIKit

/// Mock implementation of OddsAcceptanceViewModelProtocol for testing and previews
public final class MockOddsAcceptanceViewModel: OddsAcceptanceViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<OddsAcceptanceData, Never>
    
    public var dataPublisher: AnyPublisher<OddsAcceptanceData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: OddsAcceptanceData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(state: OddsAcceptanceState, labelText: String = LocalizationProvider.string("accept_odds_change"), linkText: String = LocalizationProvider.string("learn_more"), isEnabled: Bool = true) {
        let initialData = OddsAcceptanceData(state: state, labelText: labelText, linkText: linkText, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateState(_ state: OddsAcceptanceState) {
        let newData = OddsAcceptanceData(state: state, labelText: currentData.labelText, linkText: currentData.linkText, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateLabelText(_ text: String) {
        let newData = OddsAcceptanceData(state: currentData.state, labelText: text, linkText: currentData.linkText, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateLinkText(_ text: String) {
        let newData = OddsAcceptanceData(state: currentData.state, labelText: currentData.labelText, linkText: text, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = OddsAcceptanceData(state: currentData.state, labelText: currentData.labelText, linkText: currentData.linkText, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
    
    public func onCheckboxTapped() {
        // Toggle state when checkbox is tapped
        let newState: OddsAcceptanceState = currentData.state == .accepted ? .notAccepted : .accepted
        updateState(newState)
    }
    
    public func onLinkTapped() {
        // Mock implementation - in real app this would navigate to learn more page
        print("Learn More link tapped")
    }
}

// MARK: - Factory Methods
public extension MockOddsAcceptanceViewModel {
    
    /// Creates a mock view model for accepted state
    static func acceptedMock() -> MockOddsAcceptanceViewModel {
        return MockOddsAcceptanceViewModel(state: .accepted)
    }
    
    /// Creates a mock view model for not accepted state
    static func notAcceptedMock() -> MockOddsAcceptanceViewModel {
        return MockOddsAcceptanceViewModel(state: .notAccepted)
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockOddsAcceptanceViewModel {
        return MockOddsAcceptanceViewModel(state: .notAccepted, isEnabled: false)
    }
} 
