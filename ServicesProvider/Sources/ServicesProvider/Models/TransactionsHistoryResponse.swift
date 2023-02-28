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
    public var dateTime: String
    public var type: String
    public var amount: Double
    public var postBalance: Double
    public var amountBonus: Double
    public var postBalanceBonus: Double
    public var currency: String
    public var paymentId: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateTime = "dateTime"
        case type = "tranType"
        case amount = "amount"
        case postBalance = "postBalance"
        case amountBonus = "amountBonus"
        case postBalanceBonus = "postBalanceBonus"
        case currency = "currency"
        case paymentId = "paymentId"
    }
}

public struct TransactionHistory {
    public let transactionID: String
    public let time: String
    public let type: String
    public let valueType: TransactionValueType
    public let debit: DebitCredit
    public let credit: DebitCredit
    public let fees: [Fees]
    public let status: String?
    public let transactionReference: String?
    public let id: String?
    public let isRallbackAllowed: Bool?
    public let paymentId: Int?

    public init(transactionID: String, time: String, type: String, valueType: TransactionValueType, debit: DebitCredit, credit: DebitCredit, fees: [Fees], status: String?, transactionReference: String?, id: String?, isRallbackAllowed: Bool?, paymentId: Int?) {
        self.transactionID = transactionID
        self.time = time
        self.type = type
        self.valueType = valueType
        self.debit = debit
        self.credit = credit
        self.fees = fees
        self.status = status
        self.transactionReference = transactionReference
        self.id = id
        self.isRallbackAllowed = isRallbackAllowed
        self.paymentId = paymentId
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

public enum TransactionValueType {
    case won
    case loss
    case neutral
}
