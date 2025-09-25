//
//  UserTransactions.swift
//  ServicesProvider
//
//  Created by Transaction History Implementation on 25/01/2025.
//

import Foundation

// MARK: - Banking Transaction Models

public struct BankingTransactionsResponse {
    public let pagination: TransactionPagination
    public let transactions: [BankingTransaction]

    public init(pagination: TransactionPagination, transactions: [BankingTransaction]) {
        self.pagination = pagination
        self.transactions = transactions
    }
}

public struct BankingTransaction {
    public let transId: Int64
    public let created: Date
    public let completed: Date?
    public let status: String
    public let type: BankingTransactionType
    public let currency: String
    public let realAmount: Double
    public let debitVendorName: String?
    public let creditVendorName: String?
    public let creditPayItemType: String?
    public let debitPayItemType: String?
    public let productType: String?
    public let externalReference: String?
    public let vendorReference: String?
    public let debitName: String?
    public let creditAmount: Double?
    public let creditName: String?
    public let creditCurrency: String?
    public let rejectionNote: String?

    public init(transId: Int64, created: Date, completed: Date?, status: String, type: BankingTransactionType, currency: String, realAmount: Double, debitVendorName: String?, creditVendorName: String?, creditPayItemType: String?, debitPayItemType: String?, productType: String?, externalReference: String?, vendorReference: String?, debitName: String?, creditAmount: Double?, creditName: String?, creditCurrency: String?, rejectionNote: String?) {
        self.transId = transId
        self.created = created
        self.completed = completed
        self.status = status
        self.type = type
        self.currency = currency
        self.realAmount = realAmount
        self.debitVendorName = debitVendorName
        self.creditVendorName = creditVendorName
        self.creditPayItemType = creditPayItemType
        self.debitPayItemType = debitPayItemType
        self.productType = productType
        self.externalReference = externalReference
        self.vendorReference = vendorReference
        self.debitName = debitName
        self.creditAmount = creditAmount
        self.creditName = creditName
        self.creditCurrency = creditCurrency
        self.rejectionNote = rejectionNote
    }
}

public enum BankingTransactionType {
    case deposit
    case withdrawal

    public var displayName: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .withdrawal:
            return "Withdrawal"
        }
    }
}

// MARK: - Wagering Transaction Models

public struct WageringTransactionsResponse {
    public let pagination: TransactionPagination
    public let transactions: [WageringTransaction]

    public init(pagination: TransactionPagination, transactions: [WageringTransaction]) {
        self.pagination = pagination
        self.transactions = transactions
    }
}

public struct WageringTransaction {
    public let transId: String
    public let userId: Int
    public let transType: WageringTransactionType
    public let totalAmount: Double?
    public let realAmount: Double
    public let bonusAmount: Double?
    public let afterBalanceRealAmount: Double?
    public let afterBalanceBonusAmount: Double?
    public let balance: Double?
    public let stakeTotal: Double?
    public let gameId: String?
    public let createdDate: Date
    public let ceGameId: String?
    public let roundId: String?
    public let internalRoundId: String?
    public let betType: Int?
    public let transName: String?
    public let coreTransId: String?
    public let currencyCode: String

    public init(transId: String, userId: Int, transType: WageringTransactionType, totalAmount: Double?, realAmount: Double, bonusAmount: Double?, afterBalanceRealAmount: Double?, afterBalanceBonusAmount: Double?, balance: Double?, stakeTotal: Double?, gameId: String?, createdDate: Date, ceGameId: String?, roundId: String?, internalRoundId: String?, betType: Int?, transName: String?, coreTransId: String?, currencyCode: String) {
        self.transId = transId
        self.userId = userId
        self.transType = transType
        self.totalAmount = totalAmount
        self.realAmount = realAmount
        self.bonusAmount = bonusAmount
        self.afterBalanceRealAmount = afterBalanceRealAmount
        self.afterBalanceBonusAmount = afterBalanceBonusAmount
        self.balance = balance
        self.stakeTotal = stakeTotal
        self.gameId = gameId
        self.createdDate = createdDate
        self.ceGameId = ceGameId
        self.roundId = roundId
        self.internalRoundId = internalRoundId
        self.betType = betType
        self.transName = transName
        self.coreTransId = coreTransId
        self.currencyCode = currencyCode
    }
}

public enum WageringTransactionType {
    case bet
    case win

    public var displayName: String {
        switch self {
        case .bet:
            return "Bet"
        case .win:
            return "Win"
        }
    }
}

// MARK: - Shared Models

public struct TransactionPagination {
    public let next: String?
    public let previous: String?

    public init(next: String?, previous: String?) {
        self.next = next
        self.previous = previous
    }
}