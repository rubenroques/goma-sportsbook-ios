import Foundation
import UIKit
import Combine

/// Mock implementation of BetslipHeaderViewModelProtocol for testing and previews
public final class MockBetslipHeaderViewModel: BetslipHeaderViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipHeaderData, Never>
    
    // Callback closures
    public var onJoinNowTapped: (() -> Void)?
    public var onLogInTapped: (() -> Void)?
    public var onCloseTapped: (() -> Void)?
    
    public var dataPublisher: AnyPublisher<BetslipHeaderData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipHeaderData {
        return dataSubject.value
    }
    
    // MARK: - Initialization
    public init(state: BetslipHeaderState, isEnabled: Bool = true) {
        let initialData = BetslipHeaderData(state: state, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateState(_ state: BetslipHeaderState) {
        let newData = BetslipHeaderData(state: state, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipHeaderData(state: currentData.state, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockBetslipHeaderViewModel {
    
    /// Creates a mock view model for not logged in state
    static func notLoggedInMock() -> MockBetslipHeaderViewModel {
        MockBetslipHeaderViewModel(state: .notLoggedIn)
    }
    
    /// Creates a mock view model for logged in state
    static func loggedInMock(balance: String = "XAF 25,000") -> MockBetslipHeaderViewModel {
        MockBetslipHeaderViewModel(state: .loggedIn(balance: balance))
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetslipHeaderViewModel {
        MockBetslipHeaderViewModel(state: .notLoggedIn, isEnabled: false)
    }
} 
