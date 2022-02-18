//
//  BetslipSetting.swift
//  Sportsbook
//
//  Created by André Lascas on 18/02/2022.
//

import Foundation

enum OddsFormat: Int {
    case europe
    case unitedKingdom
    case usa

    var oddsFormatId: Int {
        switch self {
        case .europe:
            return 1
        case .unitedKingdom:
            return 2
        case .usa:
            return 3
        }
    }
}
