//
//  EveryMatrix+Transactions.swift
//  ServicesProvider
//
//  Created by Transaction History Implementation on 25/01/2025.
//

import Foundation

extension EveryMatrix {

    // MARK: - Banking Transaction Response Models

    struct BankingTransactionsResponse: Codable {
        let pagination: Pagination
        let transactions: [BankingTransaction]

        enum CodingKeys: String, CodingKey {
            case pagination
            case transactions
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.pagination = try container.decode(Pagination.self, forKey: .pagination)

            // Use FailableDecodable to handle individual transaction decoding failures
            let rawTransactions = try container.decode([FailableDecodable<BankingTransaction>].self, forKey: .transactions)
            self.transactions = rawTransactions.compactMap { $0.content }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(pagination, forKey: .pagination)
            try container.encode(transactions, forKey: .transactions)
        }
    }

    struct BankingTransaction: Codable {
        let transId: Int64
        let created: String
        let completed: String?  // Made optional - might be pending
        let status: String
        let type: Int  // 0 = deposit, 1 = withdrawal
        let currency: String
        let realAmount: Double
        let debitVendorName: String?  // Made optional
        let creditVendorName: String?  // Made optional
        let creditPayItemType: String?  // Made optional
        let debitPayItemType: String?  // Made optional
        let productType: String?  // Made optional
        let externalReference: String?
        let vendorReference: String?
        let debitName: String?  // Made optional
        let creditAmount: Double?  // Made optional
        let creditName: String?  // Made optional
        let creditCurrency: String?  // Made optional
        let rejectionNote: String?  // Made optional
    }

    // MARK: - Wagering Transaction Response Models

    struct WageringTransactionsResponse: Codable {
        let pagination: Pagination
        let transactions: [WageringTransaction]

        enum CodingKeys: String, CodingKey {
            case pagination
            case transactions
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.pagination = try container.decode(Pagination.self, forKey: .pagination)

            // Use FailableDecodable to handle individual transaction decoding failures
            let rawTransactions = try container.decode([FailableDecodable<WageringTransaction>].self, forKey: .transactions)
            self.transactions = rawTransactions.compactMap { $0.content }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(pagination, forKey: .pagination)
            try container.encode(transactions, forKey: .transactions)
        }
    }

    struct WageringTransaction: Codable {
        let transId: String
        let userId: Int
        let transType: String  // "1" = bet, "2" = win
        let totalAmount: Double?  // Made optional
        let realAmount: Double
        let bonusAmount: Double?  // Made optional - might be 0 or missing
        let afterBalanceRealAmount: Double?  // Made optional
        let afterBalanceBonusAmount: Double?  // Made optional
        let balance: Double?  // Made optional
        let stakeTotal: Double?  // Made optional
        let gameId: String?  // Made optional
        let ins: String  // date string - keeping required as it's always present
        let ceGameId: String?  // Made optional
        let roundId: String?  // Made optional
        let internalRoundId: String?  // Made optional
        let betType: Int?  // Made optional
        let transName: String?  // Made optional
        let coreTransId: String?  // Made optional
        let currencyCode: String
    }

    // MARK: - Shared Models

    struct Pagination: Codable {
        let next: String?
        let previous: String?
    }
}