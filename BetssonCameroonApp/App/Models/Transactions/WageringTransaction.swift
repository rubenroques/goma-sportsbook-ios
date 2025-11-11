//
//  WageringTransaction.swift
//  BetssonCameroonApp
//
//  Created on 25/01/2025.
//

import Foundation

struct WageringTransaction: Hashable, Identifiable {
    let id: String // Using transId
    let transId: String
    let userId: Int
    let transType: WageringTransactionType
    let totalAmount: Double?
    let realAmount: Double
    let bonusAmount: Double?
    let afterBalanceRealAmount: Double?
    let afterBalanceBonusAmount: Double?
    let balance: Double?
    let stakeTotal: Double?
    let gameId: String?
    let createdDate: Date
    let ceGameId: String?
    let roundId: String?
    let internalRoundId: String?
    let betType: Int?
    let transName: String?
    let coreTransId: String?
    let currencyCode: String

    // Computed properties for normalized display
    var normalizedStatus: WageringTransactionStatus {
        return WageringTransactionStatus.from(transType: transType)
    }

    /// Amount indicator based on transName (web implementation: transName == 'Credit' ? '+' : '-')
    var amountIndicator: String {
        if let transName = transName, transName.lowercased() == "credit" {
            return "+"
        } else {
            return "-"
        }
    }

    /// Display date - uses createdDate (matches "ins" field in web)
    var displayDate: Date {
        return createdDate
    }

    /// Display amount - uses totalAmount for wagering (matches web implementation)
    var displayAmount: Double {
        return totalAmount ?? realAmount
    }
}

enum WageringTransactionType: Hashable {
    case bet
    case win
    case cancel
    case batchAmountsDebit
    case batchAmountsCredit

    var displayName: String {
        switch self {
        case .bet:
            return localized("bet")
        case .win:
            return localized("win")
        case .cancel:
            return localized("cancel")
        case .batchAmountsDebit:
            return localized("batch_amounts_debit")
        case .batchAmountsCredit:
            return localized("batch_amounts_credit")
        }
    }

    var iconName: String {
        switch self {
        case .bet, .batchAmountsDebit:
            return "minus.circle"
        case .win, .batchAmountsCredit:
            return "plus.circle"
        case .cancel:
            return "xmark.circle"
        }
    }
}
