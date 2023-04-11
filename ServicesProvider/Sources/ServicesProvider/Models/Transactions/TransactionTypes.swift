//
//  TransactionTypes.swift
//  
//
//  Created by André Lascas on 11/04/2023.
//

import Foundation

public enum TransactionTypes: CaseIterable {

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
