
import Foundation
import Combine
import GomaUI
import ServicesProvider

final class MockTransactionHistoryViewModel: TransactionHistoryViewModelProtocol {

    // MARK: - Publishers

    @Published private var displayState = TransactionHistoryDisplayState.initial

    var displayStatePublisher: AnyPublisher<TransactionHistoryDisplayState, Never> {
        $displayState.eraseToAnyPublisher()
    }

    // MARK: - Properties

    let transactionTypePillSelectorViewModel: PillSelectorBarViewModelProtocol

    // MARK: - Callbacks

    var onDismiss: (() -> Void)?

    // MARK: - Mock Data

    private static let mockTransactions: [TransactionHistoryItem] = [
        // Wagering transactions with balance
        TransactionHistoryItem(
            id: "#T1023387206402751",
            type: .wagering(.bet),
            date: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
            amount: -1000.0,
            currency: "XAF",
            status: "Completed",
            description: "Football Bet",
            details: "OddsMatrix2",
            iconName: "minus.circle",
            balance: 175456.99
        ),
        TransactionHistoryItem(
            id: "#T1023387206402752",
            type: .wagering(.win),
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            amount: 2500.0,
            currency: "XAF",
            status: "Completed",
            description: "Football Win",
            details: "OddsMatrix2",
            iconName: "plus.circle",
            balance: 177956.99
        ),
        // Banking transactions without balance
        TransactionHistoryItem(
            id: "#T1023387206402753",
            type: .banking(.deposit),
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            amount: 10000.0,
            currency: "XAF",
            status: "Completed",
            description: "Mobile Money Deposit",
            details: "MTN_MOMO",
            iconName: "arrow.down.circle",
            balance: nil
        ),
        TransactionHistoryItem(
            id: "#T1023387206402754",
            type: .banking(.withdrawal),
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            amount: -5000.0,
            currency: "XAF",
            status: "Completed",
            description: "Bank Withdrawal",
            details: "ECOBANK_TRANSFER",
            iconName: "arrow.up.circle",
            balance: nil
        ),
        TransactionHistoryItem(
            id: "#T1023387206402755",
            type: .wagering(.bet),
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            amount: -500.0,
            currency: "XAF",
            status: "Completed",
            description: "Basketball Bet",
            details: "OddsMatrix2",
            iconName: "minus.circle",
            balance: 172456.99
        )
    ]

    // MARK: - Initialization

    init(mockState: MockState = .populated) {
        self.transactionTypePillSelectorViewModel = TransactionTypePillSelectorViewModel()

        setupInitialState(mockState)
    }

    // MARK: - Actions

    func loadInitialData() {
        displayState = displayState.loading()

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.displayState = self?.displayState.loaded(transactions: Self.mockTransactions) ?? .initial
        }
    }

    func refreshData() {
        displayState = displayState.loading()

        // Simulate refresh with slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.displayState = self?.displayState.loaded(transactions: Self.mockTransactions) ?? .initial
        }
    }

    func selectCategory(_ category: TransactionCategory) {
        transactionTypePillSelectorViewModel.selectPill(id: category.rawValue)
    }

    func selectDateFilter(_ filter: TransactionDateFilter) {
        displayState = displayState.dateFiltered(dateFilter: filter)
    }

    func didTapBack() {
        onDismiss?()
    }

    // MARK: - Mock State Setup

    private func setupInitialState(_ mockState: MockState) {
        switch mockState {
        case .empty:
            displayState = displayState.loaded(transactions: [])
        case .loading:
            displayState = displayState.loading()
        case .error:
            displayState = displayState.failed(error: "Failed to load transactions. Please check your internet connection.")
        case .populated:
            displayState = displayState.loaded(transactions: Self.mockTransactions)
        }
    }
}

// MARK: - Mock State Variants

extension MockTransactionHistoryViewModel {

    enum MockState {
        case empty
        case loading
        case error
        case populated
    }

    // MARK: - Static Factory Methods

    static var defaultMock: MockTransactionHistoryViewModel {
        MockTransactionHistoryViewModel(mockState: .populated)
    }

    static var emptyMock: MockTransactionHistoryViewModel {
        MockTransactionHistoryViewModel(mockState: .empty)
    }

    static var loadingMock: MockTransactionHistoryViewModel {
        MockTransactionHistoryViewModel(mockState: .loading)
    }

    static var errorMock: MockTransactionHistoryViewModel {
        MockTransactionHistoryViewModel(mockState: .error)
    }
}
