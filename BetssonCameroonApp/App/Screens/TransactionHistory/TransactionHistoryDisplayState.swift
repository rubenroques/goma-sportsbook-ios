//
//  TransactionHistoryDisplayState.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import Foundation
import ServicesProvider

struct TransactionHistoryDisplayState: Equatable {
    let isLoading: Bool
    let error: String?
    let transactions: [TransactionHistoryItem]
    let selectedCategory: TransactionCategory
    let selectedDateFilter: TransactionDateFilter
    let hasMoreData: Bool

    static let initial = TransactionHistoryDisplayState(
        isLoading: false,
        error: nil,
        transactions: [],
        selectedCategory: .all,
        selectedDateFilter: .all,
        hasMoreData: false
    )

    func loading() -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: true,
            error: nil,
            transactions: self.transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
            hasMoreData: self.hasMoreData
        )
    }

    func loaded(transactions: [TransactionHistoryItem], hasMoreData: Bool = false) -> TransactionHistoryDisplayState {
        TransactionHistoryDisplayState(
            isLoading: false,
            error: nil,
            transactions: transactions,
            selectedCategory: self.selectedCategory,
            selectedDateFilter: self.selectedDateFilter,
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
            hasMoreData: self.hasMoreData
        )
    }

    var filteredTransactions: [TransactionHistoryItem] {
        return transactions.filter { transaction in
            switch selectedCategory {
            case .all:
                return true
            case .payments:
                return transaction.type.category == .payments
            case .games:
                return transaction.type.category == .games
            }
        }
    }
}