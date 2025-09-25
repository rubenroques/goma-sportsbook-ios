//
//  TransactionItemViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import Foundation
import UIKit
import GomaUI

class TransactionItemViewModel: TransactionItemViewModelProtocol {

    // MARK: - Protocol Properties

    public var data: TransactionItemData?

    // MARK: - Initialization

    init(data: TransactionItemData?) {
        self.data = data
    }

    // MARK: - Protocol Properties

    public var balancePrefix: String {
        return "Balance: "
    }

    public var balanceAmount: String {
        guard let data = data, let balance = data.balance else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        if let formattedNumber = formatter.string(from: NSNumber(value: balance)) {
            return "\(data.currency) \(formattedNumber)"
        }
        return "\(data.currency) \(balance)"
    }

    // MARK: - Protocol Methods

    public func copyTransactionId() {
        guard let transactionId = data?.transactionId else { return }
        UIPasteboard.general.string = transactionId

        // Could add a toast/feedback here in the future
        print("Transaction ID copied: \(transactionId)")
    }
}

// MARK: - Factory Methods

extension TransactionItemViewModel {

    static func from(transactionHistoryItem: TransactionHistoryItem, balance: Double) -> TransactionItemViewModel {
        var status: GomaUI.TransactionStatus?
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

        let transactionData = TransactionItemData(
            category: category,
            status: status,
            amount: transactionHistoryItem.amount,
            currency: transactionHistoryItem.currency,
            transactionId: transactionHistoryItem.id,
            date: transactionHistoryItem.date,
            balance: balance
        )

        return TransactionItemViewModel(data: transactionData)
    }
}
