//
//  MockBetslipHeaderViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 06/08/2025.
//

import Foundation
import UIKit
import Combine

/// Mock implementation of BetslipHeaderViewModelProtocol for testing and previews
public final class MockBetslipHeaderViewModel: BetslipHeaderViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipHeaderData, Never>
    
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
    
    public func onJoinNowTapped() {
        // Mock implementation - in real implementation this would handle the tap
        print("Join Now tapped in mock view model")
    }
    
    public func onLogInTapped() {
        // Mock implementation - in real implementation this would handle the tap
        print("Log In tapped in mock view model")
    }
    
    public func onCloseTapped() {
        // Mock implementation - in real implementation this would handle the tap
        print("Close tapped in mock view model")
    }
}

// MARK: - Factory Methods
public extension MockBetslipHeaderViewModel {
    
    /// Creates a mock view model for not logged in state
    static func notLoggedInMock() -> MockBetslipHeaderViewModel {
        return MockBetslipHeaderViewModel(state: .notLoggedIn)
    }
    
    /// Creates a mock view model for logged in state
    static func loggedInMock(balance: String = "XAF 2,000.00") -> MockBetslipHeaderViewModel {
        return MockBetslipHeaderViewModel(state: .loggedIn(balance: balance))
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetslipHeaderViewModel {
        return MockBetslipHeaderViewModel(state: .notLoggedIn, isEnabled: false)
    }
} 