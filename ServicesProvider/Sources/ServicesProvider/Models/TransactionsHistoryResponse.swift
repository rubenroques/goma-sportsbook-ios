//
//  TransactionsHistoryResponse.swift
//  
//
//  Created by André Lascas on 13/02/2023.
//

import Foundation

public struct TransactionsHistoryResponse {

    public var status: String
    public var transactions: [TransactionDetail]?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case transactions = "transactions"
    }

    public init(status: String, transactions: [TransactionDetail]?) {
        self.status = status
        self.transactions = transactions
    }
}

public struct TransactionDetail {

    public var id: Int
    public var dateTime: String
    public var type: TransactionType?
    public var amount: Double
    public var postBalance: Double
    public var amountBonus: Double
    public var postBalanceBonus: Double
    public var currency: String
    public var paymentId: Int?
    public var gameTranId: String?
    public var reference: String?
    public var escrowTranType: String?
    public var escrowTranSubType: String?
    public var escrowType: String?

    public init(id: Int, dateTime: String, type: TransactionType? = nil, amount: Double, postBalance: Double, amountBonus: Double, postBalanceBonus: Double, currency: String, paymentId: Int?, gameTranId: String?, reference: String?, escrowTranType: String?, escrowTranSubType: String?, escrowType: String?) {
        self.id = id
        self.dateTime = dateTime
        self.type = type
        self.amount = amount
        self.postBalance = postBalance
        self.amountBonus = amountBonus
        self.postBalanceBonus = postBalanceBonus
        self.currency = currency
        self.paymentId = paymentId
        self.gameTranId = gameTranId
        self.reference = reference
        self.escrowTranType = escrowTranType
        self.escrowTranSubType = escrowTranSubType
        self.escrowType = escrowType
    }
}

public struct TransactionHistory {
    public let transactionID: String
    public let time: String
    public let type: String
    public let transactionType: TransactionType?
    public let valueType: TransactionValueType
    public let debit: DebitCredit
    public let credit: DebitCredit
    public let fees: [Fees]
    public let status: String?
    public let transactionReference: String?
    public let id: String?
    public let isRallbackAllowed: Bool?
    public let paymentId: Int?
    public let reference: String?
    public let escrowTranType: String?
    public let escrowTranSubType: String?
    public let escrowType: String?

    public init(transactionID: String, time: String, type: String, transactionType: TransactionType?, valueType: TransactionValueType, debit: DebitCredit, credit: DebitCredit, fees: [Fees], status: String?, transactionReference: String?, id: String?, isRallbackAllowed: Bool?, paymentId: Int?, reference: String?, escrowTranType: String?, escrowTranSubType: String?, escrowType: String?) {
        self.transactionID = transactionID
        self.time = time
        self.type = type
        self.transactionType = transactionType
        self.valueType = valueType
        self.debit = debit
        self.credit = credit
        self.fees = fees
        self.status = status
        self.transactionReference = transactionReference
        self.id = id
        self.isRallbackAllowed = isRallbackAllowed
        self.paymentId = paymentId
        self.reference = reference
        self.escrowTranType = escrowTranType
        self.escrowTranSubType = escrowTranSubType
        self.escrowType = escrowType
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
