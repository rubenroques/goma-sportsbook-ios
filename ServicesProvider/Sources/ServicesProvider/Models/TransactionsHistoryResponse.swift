//
//  TransactionsHistoryResponse.swift
//  
//
//  Created by André Lascas on 13/02/2023.
//

import Foundation

public struct TransactionsHistoryResponse: Codable {

    public var status: String
    public var transactions: [TransactionDetail]?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case transactions = "transactions"
    }
}

public struct TransactionDetail: Codable {

    public var id: Int
    public var timestamp: String
    public var type: String
    public var amount: String
    public var postBalance: String
    public var amountBonus: String
    public var postBalanceBonus: String
    public var currency: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case timestamp = "timestamp"
        case type = "tranType"
        case amount = "amount"
        case postBalance = "postBalance"
        case amountBonus = "amountBonus"
        case postBalanceBonus = "postBalanceBonus"
        case currency = "currency"
    }
}

public struct TransactionHistory {
    public let transactionID: String
    public let time: String
    public let debit: DebitCredit
    public let credit: DebitCredit
    public let fees: [Fees]
    public let status: String?
    public let transactionReference: String?
    public let id: String?
    public let isRallbackAllowed: Bool?

    public init(transactionID: String, time: String, debit: DebitCredit, credit: DebitCredit, fees: [Fees], status: String?, transactionReference: String?, id: String?, isRallbackAllowed: Bool?) {
        self.transactionID = transactionID
        self.time = time
        self.debit = debit
        self.credit = credit
        self.fees = fees
        self.status = status
        self.transactionReference = transactionReference
        self.id = id
        self.isRallbackAllowed = isRallbackAllowed
    }
}

public struct DebitCredit {
    public let currency: String
    public let amount: Double
    public let name: String

    public init(currency: String, amount: Double, name: String) {
        self.currency = currency
        self.amount = amount
        self.name = name
    }
}

public struct Fees {
    public let currency: String
    public let amount: Double

    public init(currency: String, amount: Double) {
        self.currency = currency
        self.amount = amount
    }
}
