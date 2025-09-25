
import Foundation
import Combine
import GomaUI
import ServicesProvider

protocol TransactionHistoryViewModelProtocol {

    // MARK: - Publishers

    var displayStatePublisher: AnyPublisher<TransactionHistoryDisplayState, Never> { get }

    // MARK: - Properties

    var transactionTypePillSelectorViewModel: PillSelectorBarViewModelProtocol { get }

    // MARK: - Callbacks

    var onDismiss: (() -> Void)? { get set }

    // MARK: - Actions

    func loadInitialData()
    func refreshData()
    func selectCategory(_ category: TransactionCategory)
    func selectDateFilter(_ filter: TransactionDateFilter)
    func didTapBack()
}
