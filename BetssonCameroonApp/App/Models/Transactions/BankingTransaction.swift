//
//  BankingTransaction.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
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
}

enum BankingTransactionType: Hashable {
    case deposit
    case withdrawal

    var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .withdrawal:
            return "Withdrawal"
        }
    }

    var iconName: String {
        switch self {
        case .deposit:
            return "arrow.down.circle"
        case .withdrawal:
            return "arrow.up.circle"
        }
    }
}