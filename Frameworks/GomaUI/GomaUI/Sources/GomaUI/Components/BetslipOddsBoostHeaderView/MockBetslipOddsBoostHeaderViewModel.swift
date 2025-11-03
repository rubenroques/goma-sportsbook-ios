import Foundation
import UIKit
import Combine

/// Mock implementation of BetslipOddsBoostHeaderViewModelProtocol for testing and previews
public final class MockBetslipOddsBoostHeaderViewModel: BetslipOddsBoostHeaderViewModelProtocol {

    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetslipOddsBoostHeaderData, Never>

    // Callback closures
    public var onHeaderTapped: (() -> Void)?

    public var dataPublisher: AnyPublisher<BetslipOddsBoostHeaderData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }

    public var currentData: BetslipOddsBoostHeaderData {
        return dataSubject.value
    }

    // MARK: - Initialization
    public init(state: BetslipOddsBoostHeaderState, isEnabled: Bool = true) {
        let initialData = BetslipOddsBoostHeaderData(state: state, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }

    // MARK: - Protocol Methods
    public func updateState(_ state: BetslipOddsBoostHeaderState) {
        let newData = BetslipOddsBoostHeaderData(state: state, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }

    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetslipOddsBoostHeaderData(state: currentData.state, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockBetslipOddsBoostHeaderViewModel {

    /// Creates a mock view model with customizable parameters
    static func activeMock(
        selectionCount: Int = 1,
        totalEligibleCount: Int = 3,
        nextTierPercentage: String? = "3%",
        currentBoostPercentage: String? = nil
    ) -> MockBetslipOddsBoostHeaderViewModel {
        let state = BetslipOddsBoostHeaderState(
            selectionCount: selectionCount,
            totalEligibleCount: totalEligibleCount,
            nextTierPercentage: nextTierPercentage,
            currentBoostPercentage: currentBoostPercentage
        )
        return MockBetslipOddsBoostHeaderViewModel(state: state)
    }

    /// Creates a mock view model for max boost reached state
    static func maxBoostMock() -> MockBetslipOddsBoostHeaderViewModel {
        let state = BetslipOddsBoostHeaderState(
            selectionCount: 3,
            totalEligibleCount: 3,
            nextTierPercentage: nil,
            currentBoostPercentage: "10%"
        )
        return MockBetslipOddsBoostHeaderViewModel(state: state)
    }

    /// Creates a mock view model for disabled state (component visible but disabled)
    static func disabledMock(
        selectionCount: Int = 1,
        totalEligibleCount: Int = 3
    ) -> MockBetslipOddsBoostHeaderViewModel {
        let state = BetslipOddsBoostHeaderState(
            selectionCount: selectionCount,
            totalEligibleCount: totalEligibleCount,
            nextTierPercentage: "3%",
            currentBoostPercentage: nil
        )
        return MockBetslipOddsBoostHeaderViewModel(state: state, isEnabled: false)
    }
}
