import Foundation
import UIKit
import Combine

/// Mock implementation of BetSummaryRowViewModelProtocol for testing and previews
public final class MockBetSummaryRowViewModel: BetSummaryRowViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetSummaryRowData, Never>
    
    public var dataPublisher: AnyPublisher<BetSummaryRowData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: BetSummaryRowData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(
        title: String = "TITLE",
        value: String = "VALUE",
        isEnabled: Bool = true
    ) {
        let initialData = BetSummaryRowData(
            title: title,
            value: value,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateTitle(_ title: String) {
        let newData = BetSummaryRowData(
            title: title,
            value: currentData.value,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func updateValue(_ value: String) {
        let newData = BetSummaryRowData(
            title: currentData.title,
            value: value,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = BetSummaryRowData(
            title: currentData.title,
            value: currentData.value,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockBetSummaryRowViewModel {
    
    /// Creates a mock view model for potential winnings
    static func potentialWinningsMock() -> MockBetSummaryRowViewModel {
        MockBetSummaryRowViewModel(
            title: "POTENTIAL WINNINGS",
            value: "XAF 0"
        )
    }
    
    /// Creates a mock view model for win bonus
    static func winBonusMock() -> MockBetSummaryRowViewModel {
        MockBetSummaryRowViewModel(
            title: "X% WIN BONUS",
            value: "XAF 0"
        )
    }
    
    /// Creates a mock view model for payout
    static func payoutMock() -> MockBetSummaryRowViewModel {
        MockBetSummaryRowViewModel(
            title: "PAYOUT",
            value: "XAF 0"
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockBetSummaryRowViewModel {
        MockBetSummaryRowViewModel(
            title: "TITLE",
            value: "VALUE",
            isEnabled: false
        )
    }
} 