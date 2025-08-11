import Foundation
import Combine
import UIKit

/// Mock implementation of NavigationActionViewModelProtocol for testing and previews
public final class MockNavigationActionViewModel: NavigationActionViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<NavigationActionData, Never>
    
    public var dataPublisher: AnyPublisher<NavigationActionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: NavigationActionData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(title: String = "Navigation Action", icon: String? = nil, isEnabled: Bool = true) {
        let initialData = NavigationActionData(title: title, icon: icon, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateTitle(_ title: String) {
        let newData = NavigationActionData(
            title: title,
            icon: currentData.icon,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func updateIcon(_ icon: String?) {
        let newData = NavigationActionData(
            title: currentData.title,
            icon: icon,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = NavigationActionData(
            title: currentData.title,
            icon: currentData.icon,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func onNavigationTapped() {
        // Mock implementation - in real app this would handle navigation
        print("Navigation action tapped: \(currentData.title)")
    }
}

// MARK: - Factory Methods
public extension MockNavigationActionViewModel {
    
    /// Creates a mock view model for "Open Betslip Details"
    static func openBetslipDetailsMock() -> MockNavigationActionViewModel {
        return MockNavigationActionViewModel(
            title: "Open Betslip Details",
            icon: "chevron.right",
            isEnabled: true
        )
    }
    
    /// Creates a mock view model for "Share your Betslip"
    static func shareBetslipMock() -> MockNavigationActionViewModel {
        return MockNavigationActionViewModel(
            title: "Share your Betslip",
            icon: "square.and.arrow.up",
            isEnabled: true
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockNavigationActionViewModel {
        return MockNavigationActionViewModel(
            title: "Disabled Action",
            icon: "chevron.right",
            isEnabled: false
        )
    }
} 
