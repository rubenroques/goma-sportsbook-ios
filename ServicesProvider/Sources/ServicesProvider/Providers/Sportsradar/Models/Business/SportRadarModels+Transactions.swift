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
        var gameTranId: String?
        var reference: String?
        var escrowTranType: String?
        var escrowTranSubType: String?
        var escrowType: String?

        enum CodingKeys: String, CodingKey {
            case id = "id"
            case dateTime = "dateTime"
            case type = "tranType"
            case amount = "amount"
            case amountReal = "amountReal"
            case postBalance = "postBalance"
            case amountBonus = "amountBonus"
            case postBalanceBonus = "postBalanceBonus"
            case currency = "currency"
            case paymentId = "paymentId"
            case gameTranId = "gameTranId"
            case reference = "reference"
            case escrowTranType = "escrowTranType"
            case escrowTranSubType = "escrowTranSubType"
            case escrowType = "escrowType"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<SportRadarModels.TransactionDetail.CodingKeys> = try decoder.container(keyedBy: SportRadarModels.TransactionDetail.CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.dateTime = try container.decode(String.self, forKey: .dateTime)
            self.type = try container.decode(String.self, forKey: .type)
            self.amount = try container.decode(Double.self, forKey: .amount)
            self.postBalance = try container.decode(Double.self, forKey: .postBalance)
            self.amountBonus = try container.decode(Double.self, forKey: .amountBonus)
            self.postBalanceBonus = try container.decode(Double.self, forKey: .postBalanceBonus)
            self.currency = try container.decode(String.self, forKey: .currency)
            self.paymentId = try container.decodeIfPresent(Int.self, forKey: .paymentId)
            self.gameTranId = try container.decodeIfPresent(String.self, forKey: .gameTranId)
            self.reference = try container.decodeIfPresent(String.self, forKey: .reference)
            self.escrowTranType = try container.decodeIfPresent(String.self, forKey: .escrowTranType)
            self.escrowTranSubType = try container.decodeIfPresent(String.self, forKey: .escrowTranSubType)
            self.escrowType = try container.decodeIfPresent(String.self, forKey: .escrowType)
            
            if self.type == "BONUS_REL", let amountReal = try? container.decode(Double.self, forKey: .amountReal) {
                self.amount = amountReal
            }
            
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: SportRadarModels.TransactionDetail.CodingKeys.self)
            try container.encode(self.id, forKey: SportRadarModels.TransactionDetail.CodingKeys.id)
            try container.encode(self.dateTime, forKey: SportRadarModels.TransactionDetail.CodingKeys.dateTime)
            try container.encode(self.type, forKey: SportRadarModels.TransactionDetail.CodingKeys.type)
            try container.encode(self.amount, forKey: SportRadarModels.TransactionDetail.CodingKeys.amount)
            try container.encode(self.postBalance, forKey: SportRadarModels.TransactionDetail.CodingKeys.postBalance)
            try container.encode(self.amountBonus, forKey: SportRadarModels.TransactionDetail.CodingKeys.amountBonus)
            try container.encode(self.postBalanceBonus, forKey: SportRadarModels.TransactionDetail.CodingKeys.postBalanceBonus)
            try container.encode(self.currency, forKey: SportRadarModels.TransactionDetail.CodingKeys.currency)
            try container.encodeIfPresent(self.paymentId, forKey: SportRadarModels.TransactionDetail.CodingKeys.paymentId)
            try container.encodeIfPresent(self.gameTranId, forKey: SportRadarModels.TransactionDetail.CodingKeys.gameTranId)
            try container.encodeIfPresent(self.reference, forKey: SportRadarModels.TransactionDetail.CodingKeys.reference)
            try container.encodeIfPresent(self.escrowTranType, forKey: SportRadarModels.TransactionDetail.CodingKeys.escrowTranType)
            try container.encodeIfPresent(self.escrowTranSubType, forKey: SportRadarModels.TransactionDetail.CodingKeys.escrowTranSubType)
            try container.encodeIfPresent(self.escrowType, forKey: SportRadarModels.TransactionDetail.CodingKeys.escrowType)
        }
        
    }
}
