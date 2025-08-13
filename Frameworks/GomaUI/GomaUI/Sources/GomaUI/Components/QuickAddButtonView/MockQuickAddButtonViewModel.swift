import Foundation
import UIKit
import Combine

/// Mock implementation of QuickAddButtonViewModelProtocol for testing and previews
public final class MockQuickAddButtonViewModel: QuickAddButtonViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<QuickAddButtonData, Never>
    
    // Callback closures
    public var onButtonTapped: (() -> Void)?
    
    public var dataPublisher: AnyPublisher<QuickAddButtonData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: QuickAddButtonData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(
        amount: Int = 100,
        isEnabled: Bool = true
    ) {
        let initialData = QuickAddButtonData(
            amount: amount,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateAmount(_ amount: Int) {
        let newData = QuickAddButtonData(
            amount: amount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = QuickAddButtonData(
            amount: currentData.amount,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockQuickAddButtonViewModel {
    
    /// Creates a mock view model for 100 amount
    static func amount100Mock() -> MockQuickAddButtonViewModel {
        MockQuickAddButtonViewModel(amount: 100)
    }
    
    /// Creates a mock view model for 250 amount
    static func amount250Mock() -> MockQuickAddButtonViewModel {
        MockQuickAddButtonViewModel(amount: 250)
    }
    
    /// Creates a mock view model for 500 amount
    static func amount500Mock() -> MockQuickAddButtonViewModel {
        MockQuickAddButtonViewModel(amount: 500)
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockQuickAddButtonViewModel {
        MockQuickAddButtonViewModel(amount: 100, isEnabled: false)
    }
} 