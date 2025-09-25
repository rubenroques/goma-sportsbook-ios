//
//  TransactionItemViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import Foundation
import UIKit
import GomaUI

enum TransactionStatus {
    case won
    case placed
    case tax

    var displayName: String {
        switch self {
        case .won:
            return "Won"
        case .placed:
            return "Placed"
        case .tax:
            return "Tax"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .won:
            return StyleProvider.Color.alertSuccess.withAlphaComponent(0.2)
        case .placed:
            return StyleProvider.Color.highlightTertiary.withAlphaComponent(0.2)
        case .tax:
            return StyleProvider.Color.backgroundPrimary
        }
    }

    var textColor: UIColor {
        switch self {
        case .won:
            return StyleProvider.Color.alertSuccess
        case .placed:
            return StyleProvider.Color.highlightTertiary
        case .tax:
            return StyleProvider.Color.textPrimary
        }
    }
}

struct TransactionItemViewModel {

    // MARK: - Properties

    let category: String
    let status: TransactionStatus?
    let amount: Double
    let currency: String
    let transactionId: String
    let date: Date
    let balance: Double
    let isPositive: Bool

    // MARK: - Initialization

    init(
        category: String,
        status: TransactionStatus? = nil,
        amount: Double,
        currency: String,
        transactionId: String,
        date: Date,
        balance: Double
    ) {
        self.category = category
        self.status = status
        self.amount = amount
        self.currency = currency
        self.transactionId = transactionId
        self.date = date
        self.balance = balance
        self.isPositive = amount >= 0
    }

    // MARK: - Computed Properties

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        let prefix = isPositive ? "+" : "-"
        let absAmount = abs(amount)

        if let formattedNumber = formatter.string(from: NSNumber(value: absAmount)) {
            return "\(prefix)\(currency) \(formattedNumber)"
        }
        return "\(prefix)\(currency) \(absAmount)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd/MM - HH:mm"
        return formatter.string(from: date)
    }

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        if let formattedNumber = formatter.string(from: NSNumber(value: balance)) {
            return "Balance: \(currency) \(formattedNumber)"
        }
        return "Balance: \(currency) \(balance)"
    }

    // MARK: - Actions

    func copyTransactionId() {
        UIPasteboard.general.string = transactionId

        // Could add a toast/feedback here in the future
        print("Transaction ID copied: \(transactionId)")
    }
}

// MARK: - Factory Methods

extension TransactionItemViewModel {

    static func from(transactionHistoryItem: TransactionHistoryItem, balance: Double) -> TransactionItemViewModel {
        var status: TransactionStatus?
        var category: String

        // Determine category and status based on transaction type
        switch transactionHistoryItem.type {
        case .banking(let bankingType):
            category = bankingType.displayName
            status = nil // Banking transactions don't have status badges

        case .wagering(let wageringType):
            switch wageringType {
            case .bet:
                category = transactionHistoryItem.description
                status = .placed
            case .win:
                category = transactionHistoryItem.description
                status = .won
            }
        }

        // Handle special cases like tax
        if transactionHistoryItem.description.lowercased().contains("tax") {
            status = .tax
        }

        return TransactionItemViewModel(
            category: category,
            status: status,
            amount: transactionHistoryItem.amount,
            currency: transactionHistoryItem.currency,
            transactionId: transactionHistoryItem.id,
            date: transactionHistoryItem.date,
            balance: balance
        )
    }
}
