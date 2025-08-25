import Foundation
import Combine
import UIKit

/// Mock implementation of ProgressInfoCheckViewModelProtocol for testing and previews
public final class MockProgressInfoCheckViewModel: ProgressInfoCheckViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<ProgressInfoCheckData, Never>
    
    public var dataPublisher: AnyPublisher<ProgressInfoCheckData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: ProgressInfoCheckData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(state: ProgressInfoCheckState, headerText: String, title: String, subtitle: String, icon: String? = nil, isEnabled: Bool = true) {
        let initialData = ProgressInfoCheckData(state: state, headerText: headerText, title: title, subtitle: subtitle, icon: icon, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateState(_ state: ProgressInfoCheckState) {
        let newData = ProgressInfoCheckData(state: state, headerText: currentData.headerText, title: currentData.title, subtitle: currentData.subtitle, icon: currentData.icon, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateHeaderText(_ text: String) {
        let newData = ProgressInfoCheckData(state: currentData.state, headerText: text, title: currentData.title, subtitle: currentData.subtitle, icon: currentData.icon, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateTitle(_ title: String) {
        let newData = ProgressInfoCheckData(state: currentData.state, headerText: currentData.headerText, title: title, subtitle: currentData.subtitle, icon: currentData.icon, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateSubtitle(_ subtitle: String) {
        let newData = ProgressInfoCheckData(state: currentData.state, headerText: currentData.headerText, title: currentData.title, subtitle: subtitle, icon: currentData.icon, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateIcon(_ icon: String?) {
        let newData = ProgressInfoCheckData(state: currentData.state, headerText: currentData.headerText, title: currentData.title, subtitle: currentData.subtitle, icon: icon, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = ProgressInfoCheckData(state: currentData.state, headerText: currentData.headerText, title: currentData.title, subtitle: currentData.subtitle, icon: currentData.icon, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockProgressInfoCheckViewModel {
    
    /// Creates a mock view model for win boost progress
    static func winBoostMock() -> MockProgressInfoCheckViewModel {
        return MockProgressInfoCheckViewModel(
            state: .incomplete(completedSegments: 1, totalSegments: 3),
            headerText: "You're almost there!",
            title: "Get a 3% Win Boost",
            subtitle: "by adding 2 more legs to your betslip (1.2 min odds).",
            icon: "star.fill"
        )
    }
    
    /// Creates a mock view model for complete state
    static func completeMock() -> MockProgressInfoCheckViewModel {
        return MockProgressInfoCheckViewModel(
            state: .complete,
            headerText: "Congratulations!",
            title: "Win Boost Activated",
            subtitle: "You've earned a 3% Win Boost!",
            icon: "checkmark.circle.fill"
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockProgressInfoCheckViewModel {
        return MockProgressInfoCheckViewModel(
            state: .incomplete(completedSegments: 0, totalSegments: 3),
            headerText: "You're almost there!",
            title: "Get a 3% Win Boost",
            subtitle: "by adding 2 more legs to your betslip (1.2 min odds).",
            icon: "star.fill",
            isEnabled: false
        )
    }
} 
