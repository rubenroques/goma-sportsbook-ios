import Foundation
import Combine
import GomaUI

/// Production implementation of BetSummaryRowViewModelProtocol
/// Used for displaying bet summary rows (odds, potential winnings, win bonus, payout)
final class BetSummaryRowViewModel: BetSummaryRowViewModelProtocol {

    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<BetSummaryRowData, Never>

    var dataPublisher: AnyPublisher<BetSummaryRowData, Never> {
        dataSubject.eraseToAnyPublisher()
    }

    var currentData: BetSummaryRowData {
        dataSubject.value
    }

    // MARK: - Initialization
    init(title: String, value: String, isEnabled: Bool = true) {
        let initialData = BetSummaryRowData(
            title: title,
            value: value,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
    }

    // MARK: - Protocol Methods
    func updateTitle(_ title: String) {
        let newData = BetSummaryRowData(
            title: title,
            value: currentData.value,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }

    func updateValue(_ value: String) {
        let newData = BetSummaryRowData(
            title: currentData.title,
            value: value,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }

    func setEnabled(_ isEnabled: Bool) {
        let newData = BetSummaryRowData(
            title: currentData.title,
            value: currentData.value,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
extension BetSummaryRowViewModel {

    /// Creates a BetSummaryRowViewModel for displaying total odds
    static func odds() -> BetSummaryRowViewModel {
        return BetSummaryRowViewModel(
            title: LocalizationProvider.string("odds").uppercased(),
            value: "0.00"
        )
    }

    /// Creates a BetSummaryRowViewModel for displaying potential winnings
    static func potentialWinnings() -> BetSummaryRowViewModel {
        return BetSummaryRowViewModel(
            title: LocalizationProvider.string("potential_winnings").uppercased(),
            value: "XAF 0"
        )
    }

    /// Creates a BetSummaryRowViewModel for displaying win bonus
    /// Note: Title will be dynamically updated to show percentage (e.g., "WIN BOOST (10%)")
    static func winBonus() -> BetSummaryRowViewModel {
        let noneText = LocalizationProvider.string("none").uppercased()
        return BetSummaryRowViewModel(
            title: "WIN BOOST (\(noneText))",
            value: "XAF 0"
        )
    }

    /// Creates a BetSummaryRowViewModel for displaying payout
    static func payout() -> BetSummaryRowViewModel {
        return BetSummaryRowViewModel(
            title: LocalizationProvider.string("payout").uppercased(),
            value: "XAF 0"
        )
    }
}
