//
//  EveryMatrixModelMapper+Transactions.swift
//  ServicesProvider
//
//  Created by Transaction History Implementation on 25/01/2025.
//

import Foundation

extension EveryMatrixModelMapper {

    // MARK: - Banking Transactions Mapping

    static func bankingTransactionsResponse(from internalModel: EveryMatrix.BankingTransactionsResponse) -> BankingTransactionsResponse {
        let pagination = TransactionPagination(
            next: internalModel.pagination.next,
            previous: internalModel.pagination.previous
        )

        let transactions = internalModel.transactions.compactMap { internalModelTransaction in
            bankingTransaction(from: internalModelTransaction)
        }

        return BankingTransactionsResponse(pagination: pagination, transactions: transactions)
    }

    static func bankingTransaction(from internalModel: EveryMatrix.BankingTransaction) -> BankingTransaction? {
        // Map transaction type
        let type: BankingTransactionType
        switch internalModel.type {
        case 0:
            type = .deposit
        case 1:
            type = .withdrawal
        default:
            return nil // Unknown transaction type
        }

        // Parse dates
        guard let createdDate = parseEveryMatrixDate(internalModel.created) else {
            return nil
        }

        // Parse optional completed date
        let completedDate: Date?
        if let completedString = internalModel.completed {
            completedDate = parseEveryMatrixDate(completedString)
        } else {
            completedDate = nil
        }

        return BankingTransaction(
            transId: internalModel.transId,
            created: createdDate,
            completed: completedDate,
            status: internalModel.status,
            type: type,
            currency: internalModel.currency,
            realAmount: internalModel.realAmount,
            debitVendorName: internalModel.debitVendorName,
            creditVendorName: internalModel.creditVendorName,
            creditPayItemType: internalModel.creditPayItemType,
            debitPayItemType: internalModel.debitPayItemType,
            productType: internalModel.productType,
            externalReference: internalModel.externalReference,
            vendorReference: internalModel.vendorReference,
            debitName: internalModel.debitName,
            creditAmount: internalModel.creditAmount,
            creditName: internalModel.creditName,
            creditCurrency: internalModel.creditCurrency,
            rejectionNote: internalModel.rejectionNote
        )
    }

    // MARK: - Wagering Transactions Mapping

    static func wageringTransactionsResponse(from internalModel: EveryMatrix.WageringTransactionsResponse) -> WageringTransactionsResponse {
        let pagination = TransactionPagination(
            next: internalModel.pagination.next,
            previous: internalModel.pagination.previous
        )

        let transactions = internalModel.transactions.compactMap { internalModelTransaction in
            wageringTransaction(from: internalModelTransaction)
        }

        return WageringTransactionsResponse(pagination: pagination, transactions: transactions)
    }

    static func wageringTransaction(from internalModel: EveryMatrix.WageringTransaction) -> WageringTransaction? {
        // Map transaction type
        let type: WageringTransactionType
        switch internalModel.transType {
        case "1":
            type = .bet
        case "2":
            type = .win
        default:
            return nil // Unknown transaction type
        }

        // Parse date
        guard let createdDate = parseEveryMatrixDate(internalModel.ins) else {
            return nil
        }

        return WageringTransaction(
            transId: internalModel.transId,
            userId: internalModel.userId,
            transType: type,
            totalAmount: internalModel.totalAmount,
            realAmount: internalModel.realAmount,
            bonusAmount: internalModel.bonusAmount,
            afterBalanceRealAmount: internalModel.afterBalanceRealAmount,
            afterBalanceBonusAmount: internalModel.afterBalanceBonusAmount,
            balance: internalModel.balance,
            stakeTotal: internalModel.stakeTotal,
            gameId: internalModel.gameId,
            createdDate: createdDate,
            ceGameId: internalModel.ceGameId,
            roundId: internalModel.roundId,
            internalRoundId: internalModel.internalRoundId,
            betType: internalModel.betType,
            transName: internalModel.transName,
            coreTransId: internalModel.coreTransId,
            currencyCode: internalModel.currencyCode
        )
    }

    // MARK: - Date Parsing Helper

    private static func parseEveryMatrixDate(_ dateString: String) -> Date? {
        // EveryMatrix uses ISO 8601 format: "2025-09-25T09:03:25.162Z"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString)
    }
}
