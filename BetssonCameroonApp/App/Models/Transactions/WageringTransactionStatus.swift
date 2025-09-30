//
//  WageringTransactionStatus.swift
//  BetssonCameroonApp
//
//  Created by Transaction History Enhancement on 30/09/2025.
//

import Foundation

enum WageringTransactionStatus: Hashable {
    case placed
    case won
    case cancel
    case batchAmountsDebit
    case batchAmountsCredit

    enum BadgeType {
        case regular
        case success
        case `default`
    }

    var badgeType: BadgeType {
        switch self {
        case .placed:
            return .regular
        case .won:
            return .success
        case .cancel, .batchAmountsDebit, .batchAmountsCredit:
            return .default
        }
    }

    var displayName: String {
        switch self {
        case .placed:
            return "Placed"
        case .won:
            return "Won"
        case .cancel:
            return "Cancel"
        case .batchAmountsDebit:
            return "Batch Amounts Debit"
        case .batchAmountsCredit:
            return "Batch Amounts Credit"
        }
    }

    /// Maps wagering transType to normalized status
    /// Based on web implementation: wageringTransactionStatuses
    /// transType: "1"=Bet, "2"=Win, "3"=Cancel, "4"=BatchAmountsDebit, "5"=BatchAmountsCredit
    static func from(transType: WageringTransactionType) -> WageringTransactionStatus {
        switch transType {
        case .bet:
            return .placed
        case .win:
            return .won
        case .cancel:
            return .cancel
        case .batchAmountsDebit:
            return .batchAmountsDebit
        case .batchAmountsCredit:
            return .batchAmountsCredit
        }
    }
}