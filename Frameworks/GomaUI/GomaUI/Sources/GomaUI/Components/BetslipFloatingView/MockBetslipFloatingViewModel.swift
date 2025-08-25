//
//  MockBetslipFloatingViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 05/08/2025.
//

import Foundation
import UIKit
import Combine

/// Mock implementation of BetslipFloatingViewModelProtocol for testing and previews
public final class MockBetslipFloatingViewModel: BetslipFloatingViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipFloatingData, Never>
    
    // Callback closures
    public var onBetslipTapped: (() -> Void)?
    
    public var dataPublisher: AnyPublisher<BetslipFloatingData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetslipFloatingData {
        return dataSubject.value
    }
    
    // MARK: - Initialization
    public init(state: BetslipFloatingState, isEnabled: Bool = true) {
        let initialData = BetslipFloatingData(state: state, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateState(_ state: BetslipFloatingState) {
        let newData = BetslipFloatingData(state: state, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipFloatingData(state: currentData.state, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockBetslipFloatingViewModel {
    
    /// Creates a mock view model for no tickets state
    static func noTicketsMock() -> MockBetslipFloatingViewModel {
        MockBetslipFloatingViewModel(state: .noTickets)
    }
    
    /// Creates a mock view model for with tickets state
    static func withTicketsMock(
        selectionCount: Int = 2,
        odds: String = "2.50",
        winBoostPercentage: String? = "10%",
        totalEligibleCount: Int = 6
    ) -> MockBetslipFloatingViewModel {
        let state = BetslipFloatingState.withTickets(
            selectionCount: selectionCount,
            odds: odds,
            winBoostPercentage: winBoostPercentage,
            totalEligibleCount: totalEligibleCount
        )
        return MockBetslipFloatingViewModel(state: state)
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetslipFloatingViewModel {
        MockBetslipFloatingViewModel(state: .noTickets, isEnabled: false)
    }
}
