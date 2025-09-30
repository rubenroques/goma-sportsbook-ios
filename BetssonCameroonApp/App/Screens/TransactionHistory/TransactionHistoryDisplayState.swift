
import Foundation
import ServicesProvider

struct TransactionHistoryDisplayState: Equatable {
    let isLoading: Bool
    let error: String?
    let transactions: [TransactionHistoryItem]
    let selectedCategory: TransactionCategory
    let selectedDateFilter: TransactionDateFilter
    let selectedGameType: GameTransactionType  // Level 1 filter for games
    let hasMoreData: Bool

    static let initial = TransactionHistoryDisplayState(
        isLoading: false,
        error: nil,
        transactions: [],
        selectedCategory: .all,
        selectedDateFilter: .all,
        selectedGameType: .all,
        hasMoreData: false
    )

    func loading() -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: true,
            error: nil,
            transactions: self.transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
            selectedGameType: self.selectedGameType,
            hasMoreData: self.hasMoreData
        )
    }

    func loadingWithClearedData() -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: true,
            error: nil,
            transactions: [],  // Clear old data for centered loading indicator
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
            selectedGameType: self.selectedGameType,
            hasMoreData: false
        )
    }

    func loaded(transactions: [TransactionHistoryItem], hasMoreData: Bool = false) -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: false,
            error: nil,
            transactions: transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
            selectedGameType: self.selectedGameType,
            hasMoreData: hasMoreData
        )
    }

    func failed(error: String) -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: false,
            error: error,
            transactions: self.transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
            selectedGameType: self.selectedGameType,
            hasMoreData: false
        )
    }

    func filtered(category: TransactionCategory) -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: self.isLoading,
            error: self.error,
            transactions: self.transactions,
            selectedCategory: category,
            selectedDateFilter: self.selectedDateFilter,
            selectedGameType: .all,  // Reset game type when category changes
            hasMoreData: self.hasMoreData
        )
    }

    func dateFiltered(dateFilter: TransactionDateFilter) -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: self.isLoading,
            error: self.error,
            transactions: self.transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: dateFilter,
            selectedGameType: self.selectedGameType,
            hasMoreData: self.hasMoreData
        )
    }

    func gameTypeFiltered(gameType: GameTransactionType) -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: self.isLoading,
            error: self.error,
            transactions: self.transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
            selectedGameType: gameType,
            hasMoreData: self.hasMoreData
        )
    }

    var filteredTransactions: [TransactionHistoryItem] {
        // First filter by category (Level 0: All/Payments/Games)
        let categoryFiltered: [TransactionHistoryItem]

        switch selectedCategory {
        case .all:
            categoryFiltered = transactions
        case .payments:
            categoryFiltered = transactions.filter { $0.type.category == .payments }
        case .games:
            // Apply game type sub-filter (Level 1: All/Sportsbook/Casino)
            let gameTransactions = transactions.filter { $0.type.category == .games }

            switch selectedGameType {
            case .all:
                return gameTransactions
            case .sportsbook:
                // Filter by gameId == "OddsMatrix2"
                return gameTransactions.filter { $0.gameId == "OddsMatrix2" }
            case .casino:
                // Filter by gameId != "OddsMatrix2" (and gameId exists)
                return gameTransactions.filter {
                    guard let gameId = $0.gameId else { return false }
                    return gameId != "OddsMatrix2"
                }
            }
        }

        return categoryFiltered
    }
}
