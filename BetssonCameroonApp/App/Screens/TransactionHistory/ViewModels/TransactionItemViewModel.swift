
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
        return localized("balance") + ": "
    }

    public var balanceAmount: String {
        guard let data = data, let balance = data.balance else { return "" }
        return CurrencyHelper.formatAmountWithCurrency(balance, currency: data.currency)
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

    static func from(transactionHistoryItem: TransactionHistoryItem) -> TransactionItemViewModel {
        var status: GomaUI.TransactionStatus?
        var category: String

        // Determine category and status based on transaction type
        // Matches web implementation: banking shows no badge unless cancelled/pending, wagering shows status badge
        switch transactionHistoryItem.type {
        case .banking(let bankingType):
            category = bankingType.displayName

            // Banking: Only show badge if status is not empty (cancelled or pending)
            // Matches web: bankingTransactionStatuses returns '' for success states
            if !transactionHistoryItem.displayStatus.isEmpty {
                // Map to appropriate status badge
                if transactionHistoryItem.displayStatus.lowercased().contains("cancel") {
                    status = .cancelled
                } else if transactionHistoryItem.displayStatus.lowercased().contains("pending") {
                    status = .pending
                }
            }

        case .wagering(let wageringType):
            category = transactionHistoryItem.description

            // Wagering: Show status badge based on transType (matches web: wageringTransactionStatuses)
            switch wageringType {
            case .bet:
                status = .placed
            case .win:
                status = .won
            case .cancel:
                status = .cancelled
            case .batchAmountsDebit, .batchAmountsCredit:
                status = nil // No specific badge for batch operations
            }
        }

        // Handle special cases like tax
        if transactionHistoryItem.description.lowercased().contains("tax") {
            status = .tax
        }

        let transactionData = TransactionItemData(
            category: category,
            status: status,
            amount: transactionHistoryItem.displayAmount,  // Use displayAmount (totalAmount for wagering)
            currency: transactionHistoryItem.currency,
            transactionId: transactionHistoryItem.id,
            date: transactionHistoryItem.date,
            balance: transactionHistoryItem.balance,
            amountIndicator: transactionHistoryItem.displayAmountIndicator  // Pass indicator from transaction
        )

        return TransactionItemViewModel(data: transactionData)
    }
}
