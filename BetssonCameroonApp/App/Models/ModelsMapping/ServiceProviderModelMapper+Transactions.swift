//
//  ServiceProviderModelMapper+Transactions.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {

    // MARK: - Banking Transactions

    static func bankingTransactions(from response: ServicesProvider.BankingTransactionsResponse) -> [BankingTransaction] {
        return response.transactions.compactMap { bankingTransaction(from: $0) }
    }

    static func bankingTransaction(from spTransaction: ServicesProvider.BankingTransaction) -> BankingTransaction? {
        // Map transaction type
        let type: BankingTransactionType
        switch spTransaction.type {
        case .deposit:
            type = .deposit
        case .withdrawal:
            type = .withdrawal
        }

        return BankingTransaction(
            id: String(spTransaction.transId),
            transId: spTransaction.transId,
            created: spTransaction.created,
            completed: spTransaction.completed,
            status: spTransaction.status,
            type: type,
            currency: spTransaction.currency,
            realAmount: spTransaction.realAmount,
            debitVendorName: spTransaction.debitVendorName,
            creditVendorName: spTransaction.creditVendorName,
            creditPayItemType: spTransaction.creditPayItemType,
            debitPayItemType: spTransaction.debitPayItemType,
            productType: spTransaction.productType,
            externalReference: spTransaction.externalReference,
            vendorReference: spTransaction.vendorReference,
            debitName: spTransaction.debitName,
            creditAmount: spTransaction.creditAmount,
            creditName: spTransaction.creditName,
            creditCurrency: spTransaction.creditCurrency,
            rejectionNote: spTransaction.rejectionNote
        )
    }

    // MARK: - Wagering Transactions

    static func wageringTransactions(from response: ServicesProvider.WageringTransactionsResponse) -> [WageringTransaction] {
        return response.transactions.compactMap { wageringTransaction(from: $0) }
    }

    static func wageringTransaction(from spTransaction: ServicesProvider.WageringTransaction) -> WageringTransaction? {
        // Map transaction type
        let type: WageringTransactionType
        switch spTransaction.transType {
        case .bet:
            type = .bet
        case .win:
            type = .win
        }

        return WageringTransaction(
            id: spTransaction.transId,
            transId: spTransaction.transId,
            userId: spTransaction.userId,
            transType: type,
            totalAmount: spTransaction.totalAmount,
            realAmount: spTransaction.realAmount,
            bonusAmount: spTransaction.bonusAmount,
            afterBalanceRealAmount: spTransaction.afterBalanceRealAmount,
            afterBalanceBonusAmount: spTransaction.afterBalanceBonusAmount,
            balance: spTransaction.balance,
            stakeTotal: spTransaction.stakeTotal,
            gameId: spTransaction.gameId,
            createdDate: spTransaction.createdDate,
            ceGameId: spTransaction.ceGameId,
            roundId: spTransaction.roundId,
            internalRoundId: spTransaction.internalRoundId,
            betType: spTransaction.betType,
            transName: spTransaction.transName,
            coreTransId: spTransaction.coreTransId,
            currencyCode: spTransaction.currencyCode
        )
    }
}