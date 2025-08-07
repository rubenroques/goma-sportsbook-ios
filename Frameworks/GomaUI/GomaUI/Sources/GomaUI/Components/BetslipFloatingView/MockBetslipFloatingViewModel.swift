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
    
    public func onBetslipTapped() {
        // Mock implementation - in real implementation this would handle the tap
        print("Betslip tapped in mock view model")
    }
}

// MARK: - Factory Methods
extension MockBetslipFloatingViewModel {
    
    /// Creates a mock with no tickets state
    public static func noTicketsMock() -> MockBetslipFloatingViewModel {
        return MockBetslipFloatingViewModel(state: .noTickets)
    }
    
    /// Creates a mock with tickets state
    public static func withTicketsMock(
        selectionCount: Int = 1,
        odds: String = "1.55",
        winBoostPercentage: String? = nil,
        totalEligibleCount: Int = 3
    ) -> MockBetslipFloatingViewModel {
        let state = BetslipFloatingState.withTickets(
            selectionCount: selectionCount,
            odds: odds,
            winBoostPercentage: winBoostPercentage,
            totalEligibleCount: totalEligibleCount
        )
        return MockBetslipFloatingViewModel(state: state)
    }
    
    /// Creates a mock with win boost activated
    public static func winBoostActivatedMock() -> MockBetslipFloatingViewModel {
        let state = BetslipFloatingState.withTickets(
            selectionCount: 3,
            odds: "2.45",
            winBoostPercentage: "3%",
            totalEligibleCount: 6
        )
        return MockBetslipFloatingViewModel(state: state)
    }
    
    /// Creates a mock with multiple selections but no win boost
    public static func multipleSelectionsMock() -> MockBetslipFloatingViewModel {
        let state = BetslipFloatingState.withTickets(
            selectionCount: 2,
            odds: "3.20",
            winBoostPercentage: nil,
            totalEligibleCount: 4
        )
        return MockBetslipFloatingViewModel(state: state)
    }
}
