//
//  TransactionTypeMapper.swift
//  Sportsbook
//
//  Created by André Lascas on 03/03/2023.
//

import Foundation
import ServicesProvider

enum TransactionTypeMapper {

    case deposit
    case withdrawal
    case bonusCredited
    case bonusExpired
    case bonusReleased
    case depositCancel
    case withdrawalCancel
    case betPlaced
    case betSettled
    case cashOut
    case refund
    case productBonus
    case manualAdjustment

    init?(transactionType: String) {

        switch transactionType {
        case "DEPOSIT": self = .deposit
        case "WITHDRAWAL": self = .withdrawal
        case "CRE_BONUS": self = .bonusCredited
        case "EXP_BONUS": self = .bonusExpired
        case "BONUS_REL": self = .bonusReleased
        case "DP_CANCEL": self = .depositCancel
        case "WD_CANCEL": self = .withdrawalCancel
        case "GAME_BET": self = .betPlaced
        case "GAME_WIN": self = .betSettled
        case "CASH_OUT": self = .cashOut
        case "REFUND": self = .refund
        case "PRODUC_BON": self = .productBonus
        case "MAN_ADJUST": self = .manualAdjustment
        default: return nil
        }
    }

    var transactionName: String {
        switch self {
        case .deposit: return localized("deposit")
        case .withdrawal: return localized("withdrawal")
        case .bonusCredited: return localized("bonus_credit")
        case .bonusExpired: return localized("bonus_expired")
        case .bonusReleased: return localized("bonus_released")
        case .depositCancel: return localized("deposit_cancel")
        case .withdrawalCancel: return localized("withdrawal_cancel")
        case .betPlaced: return localized("bet_placed")
        case .betSettled: return localized("bet_settled")
        case .cashOut: return localized("cashout")
        case .refund: return localized("refund")
        case .productBonus: return localized("product_bonus")
        case .manualAdjustment: return localized("man_adjust")
        }
    }
}

//class TransactionTypeMapper {
//
//    func getTransactionName(transactionType: String) -> String? {
//
//        switch transactionType {
//        case "DEPOSIT": return localized("deposit")
//        case "WITHDRAWAL": return localized("withdrawal")
//        case "CRE_BONUS": return localized("bonus_credit")
//        case "EXP_BONUS": return localized("bonus_expired")
//        case "BONUS_REL": return localized("bonus_released")
//        case "DP_CANCEL": return localized("deposit_cancel")
//        case "WD_CANCEL": return localized("withdrawal_cancel")
//        case "GAME_BET": return localized("bet_placed")
//        case "GAME_WIN": return localized("bet_settled")
//        case "CASH_OUT": return localized("cashout")
//        case "REFUND": return localized("refund")
//        case "PRODUC_BON": return localized("product_bonus")
//        case "MAN_ADJUST": return localized("man_adjust")
//        default: return nil
//        }
//    }
//
//}
