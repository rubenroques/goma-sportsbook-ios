//
//  MockWalletWidgetViewModel.swift
//  GomaUI
//

import Combine
import UIKit

/// Mock implementation of `WalletWidgetViewModelProtocol` for testing.
final public class MockWalletWidgetViewModel: WalletWidgetViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<WalletWidgetDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<WalletWidgetDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    // Internal state
    private var walletData: WalletWidgetData
    
    // MARK: - Initialization
    public init(walletData: WalletWidgetData) {
        self.walletData = walletData
        
        // Create initial display state
        let initialState = WalletWidgetDisplayState(walletData: walletData)
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - WalletWidgetViewModelProtocol
    public func deposit() {
        // This would normally trigger an action in a real implementation
        print("Deposit button tapped")
    }
    
    // MARK: - Public Methods
    public func updateBalance(_ balance: String) {
        walletData = WalletWidgetData(
            id: walletData.id,
            balance: balance,
            depositButtonTitle: walletData.depositButtonTitle
        )
        publishNewState()
    }
    
    // MARK: - Helper Methods
    private func publishNewState() {
        let newState = WalletWidgetDisplayState(walletData: walletData)
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockWalletWidgetViewModel {
    public static var defaultMock: MockWalletWidgetViewModel {
        return MockWalletWidgetViewModel(
            walletData: WalletWidgetData(
                id: .wallet,
                balance: "2,000.00",
                depositButtonTitle: "DEPOSIT"
            )
        )
    }
} 
