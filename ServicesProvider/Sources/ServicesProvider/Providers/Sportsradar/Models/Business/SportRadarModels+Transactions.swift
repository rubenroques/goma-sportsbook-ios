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
            case transactions = "transactions"
        }
    }

    struct TransactionDetail: Codable {

        var id: Int
        var timestamp: String
        var type: String
        var amount: String
        var postBalance: String
        var amountBonus: String
        var postBalanceBonus: String
        var currency: String

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
}
