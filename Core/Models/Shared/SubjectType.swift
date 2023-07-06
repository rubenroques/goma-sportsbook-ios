//
//  SubjectType.swift
//  Sportsbook
//
//  Created by André Lascas on 06/07/2023.
//

import Foundation

enum SubjectType: CaseIterable {

    case register
    case myAccount
    case bonusAndPromotions
    case deposits
    case withdraws
    case responsibleGaming
    case bettingRules
    case other

    var typeValue: String {
        switch self {
        case .register:
            return localized("register")
        case .myAccount:
            return localized("my_account")
        case .bonusAndPromotions:
            return localized("bonus_and_promotions")
        case .deposits:
            return localized("deposits")
        case .withdraws:
            return localized("withdraws")
        case .responsibleGaming:
            return localized("responsible_gaming_title")
        case .bettingRules:
            return localized("betting_rules")
        case .other:
            return localized("other")
        }
    }

    var typeTag: String {
        switch self {
        case .register:
            return "inscription"
        case .myAccount:
            return "mom_compte"
        case .bonusAndPromotions:
            return "bonus_et_promotions"
        case .deposits:
            return "dépôts"
        case .withdraws:
            return "retrait"
        case .responsibleGaming:
            return "jeu_responsable"
        case .bettingRules:
            return "règles_des_paris"
        case .other:
            return "autre"
        }
    }
    
}

