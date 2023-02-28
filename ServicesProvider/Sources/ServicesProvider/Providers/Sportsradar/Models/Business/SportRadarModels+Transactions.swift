//
//  SportRadarModels+Transactions.swift
//  
//
//  Created by André Lascas on 13/02/2023.
//

import Foundation

extension SportRadarModels {

    struct TransactionsHistoryResponse: Codable {

        var status: String
        var transactions: [TransactionDetail]?

        enum CodingKeys: String, CodingKey {
            case status = "status"
            case transactions = "transactionList"
        }
    }

    struct TransactionDetail: Codable {

        var id: Int
        var dateTime: String
        var type: String
        var amount: Double
        var postBalance: Double
        var amountBonus: Double
        var postBalanceBonus: Double
        var currency: String
        var paymentId: Int?

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
}
