//
//  TransactionTypeMapper.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2023.
//

import Foundation

enum TransactionTypeMapper {
    case deposit
    case withdrawal
    case bonusCredited
    case bonusExpired
    case depositCancel
    case withdrawalCancel
    case betPlaced
    case betSettled

    init?(transactionType: String) {

        switch transactionType {
        case "DEPOSIT": self = .deposit
        case "WITHDRAWAL": self = .withdrawal
        case "CRE_BONUS": self = .bonusCredited
        case "EXP_BONUS": self = .bonusExpired
        case "DP_CANCEL": self = .depositCancel
        case "WD_CANCEL": self = .withdrawalCancel
        case "GAME_BET": self = .betPlaced
        case "GAME_WIN": self = .betSettled
        default: return nil
        }
    }

    var transactionName: String {
        switch self {
        case .deposit: return localized("deposit")
        case .withdrawal: return localized("withdrawal")
        case .bonusCredited: return localized("bonus_credit")
        case .bonusExpired: return localized("bonus_expired")
        case .depositCancel: return localized("deposit_cancel")
        case .withdrawalCancel: return localized("withdrawal_cancel")
        case .betPlaced: return localized("bet_placed")
        case .betSettled: return localized("bet_settled")
        }
    }
}
