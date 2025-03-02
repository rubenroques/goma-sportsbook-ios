//
//  TransactionTypes.swift
//  
//
//  Created by André Lascas on 11/04/2023.
//

import Foundation

public enum TransactionType: CaseIterable {

    public enum EscrowType: String {
        case ESC_AML
        case ESC_AN_WIN
        case ESC_REVIEW
        case ESC_RG_DEF
        
        public init?(rawValue: String) {
            switch rawValue {
            case "ESC_AML": self = .ESC_AML
            case "ESC_AN_WIN": self = .ESC_AN_WIN
            case "ESC_REVIEW": self = .ESC_REVIEW
            case "ESC_RG_DEF": self = .ESC_RG_DEF
            default: return nil
            }
        }
        
    }
    
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
    case withdrawalReject
    case automatedWithdrawalThreshold
    case automatedWithdrawal
    case depositReturned

    init?(transactionType: String, escrowType: String?) {

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
        case "WD_REJECT": self = .withdrawalReject
        case "ESC_XFER": self = .automatedWithdrawalThreshold
        case "ESC_XFER_SIMPLE": self = .automatedWithdrawal
        case "DP_RBACK": self = .depositReturned
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
        case .withdrawalReject: return "WD_REJECT"
        case .automatedWithdrawalThreshold: return "ESC_XFER"
        case .automatedWithdrawal: return "ESC_XFER_SIMPLE"
        case .depositReturned: return "DP_RBACK"
        }
    }

}
