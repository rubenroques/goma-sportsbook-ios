//
//  TransactionHistory.swift
//  ShowcaseProd
//
//  Created by Teresa on 17/02/2022.
//

import Foundation

extension EveryMatrix {
    
    struct TransactionsHistoryResponse: Codable {
        var currentPageIndex: Int
        var transactions: [TransactionHistory]
        var totalRecordCount: Int
        var totalPageCount: Int
        var revenue: Int?
        
        enum CodingKeys: String, CodingKey {
            case currentPageIndex = "currentPageIndex"
            case transactions = "transactions"
            case totalRecordCount = "totalRecordCount"
            case totalPageCount = "totalPageCount"
        }
    }

    struct TransactionHistory: Codable {
        let transactionID: String
        let time: String
        let debit: DebitCredit
        let credit: DebitCredit
        let fees: [Fees]
        let status: String?
        let transactionReference: String?
        let id: String?
        let isRallbackAllowed: Bool?
        
        enum CodingKeys: String, CodingKey {
            case transactionID = "transactionID"
            case time = "time"
            case debit = "debit"
            case credit = "credit"
            case fees = "fees"
            case status = "status"
            case transactionReference = "transactionReference"
            case id = "id"
            case isRallbackAllowed = "isRallbackAllowed"
            
        }
    }

    struct DebitCredit: Codable {
        let currency: String
        let amount: Int
        let name: String

        enum CodingKeys: String, CodingKey {
            case currency = "currency"
            case amount = "amount"
            case name = "name"
        }
    }

    struct Fees: Codable {
        let currency: String
        let amount: Int

        enum CodingKeys: String, CodingKey {
            case currency = "currency"
            case amount = "amount"
        }
    }

}
