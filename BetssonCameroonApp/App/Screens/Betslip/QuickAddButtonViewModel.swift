import Foundation
import Combine
import GomaUI

/// Production implementation of QuickAddButtonViewModelProtocol
/// Used for quick-add amount buttons (100, 250, 500)
final class QuickAddButtonViewModel: QuickAddButtonViewModelProtocol {

    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<QuickAddButtonData, Never>

    var dataPublisher: AnyPublisher<QuickAddButtonData, Never> {
        dataSubject.eraseToAnyPublisher()
    }

    var currentData: QuickAddButtonData {
        dataSubject.value
    }

    var onButtonTapped: (() -> Void)?

    // MARK: - Initialization
    init(amount: Int, isEnabled: Bool = true) {
        let initialData = QuickAddButtonData(
            amount: amount,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
    }

    // MARK: - Protocol Methods
    func updateAmount(_ amount: Int) {
        let newData = QuickAddButtonData(
            amount: amount,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }

    func setEnabled(_ isEnabled: Bool) {
        let newData = QuickAddButtonData(
            amount: currentData.amount,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
extension QuickAddButtonViewModel {

    /// Creates a QuickAddButtonViewModel for adding 100 to bet amount
    static func amount100() -> QuickAddButtonViewModel {
        return QuickAddButtonViewModel(amount: 100)
    }

    /// Creates a QuickAddButtonViewModel for adding 250 to bet amount
    static func amount250() -> QuickAddButtonViewModel {
        return QuickAddButtonViewModel(amount: 250)
    }

    /// Creates a QuickAddButtonViewModel for adding 500 to bet amount
    static func amount500() -> QuickAddButtonViewModel {
        return QuickAddButtonViewModel(amount: 500)
    }
}
