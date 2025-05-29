//
//  File.swift
//  Sportsbook
//
//  Created by André Lascas on 22/02/2022.
//

import Foundation

enum LimitType {
    case deposit
    case wagering
    case loss
    
    var identifier: String {
        switch self {
        case .deposit:
            return "Deposit"
        case .wagering:
            return "Wagering"
        case .loss:
            return "Loss"
        }
    }
}
