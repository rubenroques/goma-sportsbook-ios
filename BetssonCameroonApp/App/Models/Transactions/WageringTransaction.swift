//
//  WageringTransaction.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
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
}

enum WageringTransactionType: Hashable {
    case bet
    case win

    var displayName: String {
        switch self {
        case .bet:
            return "Bet"
        case .win:
            return "Win"
        }
    }

    var iconName: String {
        switch self {
        case .bet:
            return "minus.circle"
        case .win:
            return "plus.circle"
        }
    }
}