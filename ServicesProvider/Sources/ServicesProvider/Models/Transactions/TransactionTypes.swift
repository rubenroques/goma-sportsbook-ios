//
//  TransactionTypes.swift
//  
//
//  Created by André Lascas on 11/04/2023.
//

import Foundation

public enum TransactionType: CaseIterable {

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

    var transactionKey: String {
        switch self {
        case .deposit: return "DEPOSIT"
        case .withdrawal: return "WITHDRAWAL"
        case .bonusCredited: return "CRE_BONUS"
        case .bonusExpired: return "EXP_BONUS"
        case .bonusReleased: return "BONUS_REL"
        case .depositCancel: return "DP_CANCEL"
        case .withdrawalCancel: return "WD_CANCEL"
        case .betPlaced: return "GAME_BET"
        case .betSettled: return "GAME_WIN"
        case .cashOut: return "CASH_OUT"
        case .refund: return "REFUND"
        case .productBonus: return "PRODUC_BON"
        case .manualAdjustment: return "MAN_ADJUST"
        }
    }

}
