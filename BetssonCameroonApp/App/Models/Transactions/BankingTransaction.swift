//
//  BankingTransaction.swift
//  BetssonCameroonApp
//
//  Created on 25/01/2025.
//

import Foundation

struct BankingTransaction: Hashable, Identifiable {
    let id: String // Using transId as string ID
    let transId: Int64
    let created: Date
    let completed: Date?
    let status: String
    let type: BankingTransactionType
    let currency: String
    let realAmount: Double
    let debitVendorName: String?
    let creditVendorName: String?
    let creditPayItemType: String?
    let debitPayItemType: String?
    let productType: String?
    let externalReference: String?
    let vendorReference: String?
    let debitName: String?
    let creditAmount: Double?
    let creditName: String?
    let creditCurrency: String?
    let rejectionNote: String?

    // Computed properties for normalized display
    var normalizedStatus: BankingTransactionStatus {
        return BankingTransactionStatus.from(rawStatus: status)
    }

    var amountIndicator: String {
        return type.amountIndicator
    }

    /// Display date - uses completed date if available, otherwise created date
    /// Matches web implementation which uses "completed" for banking transactions
    var displayDate: Date {
        return completed ?? created
    }
}

enum BankingTransactionType: Hashable {
    case deposit
    case withdrawal
    case systemDeposit
    case systemWithdrawal

    var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .withdrawal:
            return "Withdrawal"
        case .systemDeposit:
            return "System Deposit"
        case .systemWithdrawal:
            return "System Withdrawal"
        }
    }

    var iconName: String {
        switch self {
        case .deposit, .systemDeposit:
            return "arrow.down.circle"
        case .withdrawal, .systemWithdrawal:
            return "arrow.up.circle"
        }
    }

    var amountIndicator: String {
        switch self {
        case .deposit, .systemDeposit:
            return "+"
        case .withdrawal, .systemWithdrawal:
            return "-"
        }
    }
}
